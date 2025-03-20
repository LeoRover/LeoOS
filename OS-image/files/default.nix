

{ OSName, OSVersion, stdenv, fetchurl }:
let
  ros-archive-keyring = (fetchurl {
    url = "https://raw.githubusercontent.com/ros/rosdistro/master/ros.key";
    sha256 = "sha256-OkyNWeOg+7Ks8ziZS2ECxbqhcHHEzJf1ILSCppf4pP4=";
  });
  fictionlab-archive-keyring = (fetchurl {
    url = "https://files.fictionlab.pl/repo/fictionlab.gpg";
    sha256 = "sha256-noqi5NcMDrnwMp9JFVUrLJkH65WH9/EDISQIVT8Hnf8=";
  });

in stdenv.mkDerivation {
  name = "files";
  src = ./.;
  phases = [ "unpackPhase" "patchPhase" "installPhase" ];

  patchPhase = ''
    sed -i "s|@OS_NAME@|${OSName}|g" etc/custom-os-release
    sed -i "s|@OS_VERSION@|${OSVersion}|g" etc/custom-os-release
  '';

  installPhase = ''
    # Copy the keyrings
    mkdir -p $out/usr/share/keyrings
    cp -v ${ros-archive-keyring} $out/usr/share/keyrings/ros-archive-keyring.gpg
    cp -v ${fictionlab-archive-keyring} $out/usr/share/keyrings/fictionlab-archive-keyring.gpg

    # Copy the files
    cp -vr boot etc usr $out
  '';
}
