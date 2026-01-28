#!/usr/bin/env bash
set -euo pipefail

# WARNING: AI Slop
# Update sha256 values for fetchurl Packages files in a Nix file.
# Default target: OS-image/default.nix
# Requires: nix-prefetch-url, nix (for nix hash convert)

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")"/.. && pwd)"
target_file="$repo_root/OS-image/default.nix"
dry_run=false
list_only=false

usage() {
  cat <<EOF
Usage: $(basename "$0") [-f <nix-file>] [--dry-run] [--list]

Options:
  -f, --file <path>   Path to Nix file (default: OS-image/default.nix)
  --dry-run           Show planned replacements, do not modify file
  --list              List discovered URLs and current sha256s without fetching

Examples:
  $(basename "$0")                      # update all sha256 entries
  $(basename "$0") --dry-run            # preview changes only
  $(basename "$0") --list               # list URLs and current hashes
  $(basename "$0") -f path/to/file.nix  # operate on a custom Nix file
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -f|--file)
      shift
      [[ $# -gt 0 ]] || { echo "Missing argument for --file" >&2; exit 2; }
      target_file="$1"
      ;;
    --dry-run)
      dry_run=true
      ;;
    --list)
      list_only=true
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage
      exit 2
      ;;
  esac
  shift
done

if [[ ! -f "$target_file" ]]; then
  echo "Target file not found: $target_file" >&2
  exit 1
fi

if [[ "$list_only" != true ]]; then
  command -v nix-prefetch-url >/dev/null 2>&1 || {
    echo "nix-prefetch-url is required" >&2
    exit 1
  }
  command -v nix >/dev/null 2>&1 || {
    echo "nix (for 'nix hash convert') is required" >&2
    exit 1
  }
fi

# Extract mapping of sha256 line numbers, current sha256, and URLs from fetchurl blocks
map_file="$(mktemp)"
trap 'rm -f "$map_file"' EXIT

awk '
  BEGIN { in_block=0; url=""; sha=""; expect_url=0 }
  /packagesFile[[:space:]]*=\s*\(fetchurl[[:space:]]*\{/ { in_block=1; url=""; sha=""; expect_url=0; next }
  in_block && /url[[:space:]]*=/ {
    # handle url on same or next line
    expect_url=1
    if (match($0, /"([^"]+)"/, m)) { url=m[1]; expect_url=0 }
    next
  }
  in_block && expect_url==1 {
    if (match($0, /"([^"]+)"/, m)) { url=m[1]; expect_url=0 }
  }
  in_block && /sha256[[:space:]]*=/ {
    # capture quoted sha
    if (match($0, /sha256[[:space:]]*=\s*"([^"]+)"/, m)) { sha=m[1] }
    # output: line_number|current_sha|url
    printf "%d|%s|%s\n", NR, sha, url
    next
  }
  in_block && /\}\);/ { in_block=0; url=""; sha=""; expect_url=0; next }
' "$target_file" > "$map_file"

if [[ "$list_only" == true ]]; then
  echo "Discovered fetchurl entries in $target_file:" >&2
  while IFS='|' read -r lineno cur_sha url; do
    printf -- "- line %s: url=%s\n  current sha256=%s\n" "$lineno" "$url" "$cur_sha"
  done < "$map_file"
  exit 0
fi

tmp_out="$(mktemp)"
cp "$target_file" "$tmp_out"

changes=0
errors=0

# Read stamp variables from the Nix file (e.g., noble-updates-stamp, ros2-stamp, fictionlab-stamp)
declare -A stamps
while IFS= read -r line; do
  case "$line" in
    *-stamp*=*)
      key_part="${line%%=*}"
      # trim leading/trailing whitespace robustly
      key_part="$(printf '%s' "$key_part" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
      # extract quoted value
      val_part="${line#*\"}"
      val_part="${val_part%%\"*}"
      if [[ -n "$key_part" && -n "$val_part" ]]; then
        stamps["$key_part"]="$val_part"
      fi
      ;;
  esac
done < "$target_file"

# Debug: print parsed stamp variables when dry-run or list-only for visibility
if [[ "$dry_run" == true || "$list_only" == true ]]; then
  for k in "${!stamps[@]}"; do
    echo "Stamp: $k=${stamps[$k]}" >&2
  done
fi

exec 3< "$map_file"
set +e
while IFS='|' read -r lineno cur_sha url <&3; do
  if [[ -z "$url" ]]; then
    echo "Skipping line $lineno: no URL found" >&2
    ((errors++))
    continue
  fi

  # Resolve any ${var} placeholders using parsed stamp values
  resolved_url="$url"
  for key in "${!stamps[@]}"; do
    pattern="\${$key}"
    value="${stamps[$key]}"
    echo "Subst: pattern=$pattern value=$value" >&2
    resolved_url="${resolved_url//${pattern}/$value}"
  done
  echo "Resolved URL: $resolved_url" >&2
  if [[ "$resolved_url" == *"\${"* ]]; then
    echo "Unresolved placeholder in URL: $url" >&2
  fi

  echo "Prefetching: $resolved_url" >&2
  if ! nix32_hash=$(nix-prefetch-url "$resolved_url" 2>/dev/null); then
    echo "Failed to prefetch $url" >&2
    ((errors++))
    continue
  fi
  echo "Prefetched nix32: $nix32_hash" >&2
  if ! sri_hash=$(nix hash convert --hash-algo sha256 --from nix32 --to sri "$nix32_hash" 2>/dev/null); then
    echo "Failed to convert hash for $url" >&2
    ((errors++))
    continue
  fi
  echo "Converted SRI: $sri_hash" >&2

  if [[ "$dry_run" == true ]]; then
    echo "Would update line $lineno: sha256 = \"$cur_sha\"; -> sha256 = \"$sri_hash\";" >&2
  else
    # Replace the sha256 line at the exact line number
    if sed -i "${lineno}s|sha256 = \".*\";|sha256 = \"${sri_hash}\";|" "$tmp_out"; then
      echo "Updated line $lineno" >&2
      ((changes++))
    else
      echo "Failed to update line $lineno" >&2
      ((errors++))
    fi
  fi
done < "$map_file"
set -e

if [[ "$dry_run" == true ]]; then
  echo "Dry-run complete. No changes written." >&2
  exit 0
fi

if [[ $changes -gt 0 ]]; then
  mv "$tmp_out" "$target_file"
  echo "Updated $changes sha256 entrie(s) in: $target_file"
else
  rm -f "$tmp_out"
  echo "No changes made."
fi

if [[ $errors -gt 0 ]]; then
  echo "Completed with $errors error(s). Some entries may not have been updated." >&2
fi
