

{ stdenv }:
stdenv.mkDerivation {
  name = "files";
  src = ./.;
  phases = [ "unpackPhase" "patchPhase" "installPhase" ];

  installPhase = ''
    # Copy the files
    cp -vr etc $out
  '';
}
