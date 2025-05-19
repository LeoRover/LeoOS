

{ stdenv }:
stdenv.mkDerivation {
  name = "files";
  src = ./.;
  phases = [ "unpackPhase" "patchPhase" "installPhase" ];

  installPhase = ''
    # Copy the files
    mkdir -p $out
    cp -vr etc usr $out
  '';
}
