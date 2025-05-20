

{ stdenv, fetchurl }:
let
  fictionlab-archive-keyring = (fetchurl {
    url = "https://files.fictionlab.pl/repo/fictionlab.gpg";
    sha256 = "sha256-noqi5NcMDrnwMp9JFVUrLJkH65WH9/EDISQIVT8Hnf8=";
  });

in stdenv.mkDerivation {
  name = "files";
  src = ./.;
  phases = [ "unpackPhase" "patchPhase" "installPhase" ];

  installPhase = ''
    # Copy the keyrings
    mkdir -p $out/usr/share/keyrings
    cp -v ${fictionlab-archive-keyring} $out/usr/share/keyrings/fictionlab-archive-keyring.gpg

    # Copy the files
    cp -vr boot etc usr $out
  '';
}
