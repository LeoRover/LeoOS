{ files, pkgs, stdenv, makeWrapper }:
stdenv.mkDerivation {
  name = "scripts";
  src = ./.;
  nativeBuildInputs = [ makeWrapper ];
  phases = [ "unpackPhase" "installPhase" "postFixup" ];
  installPhase = ''
    mkdir -p $out
    cp -vr $src/build.sh $out
  '';
  postFixup = ''
    wrapProgram $out/build.sh \
    --set PATH "${
      with pkgs;
      lib.makeBinPath [
        coreutils
        dosfstools
        dpkg
        e2fsprogs
        gnutar
        parted
        systemd
        util-linux
      ]
    }" \
    --set FILES_DIR ${files} \
    --set NIX_STORE_DIR ${builtins.storeDir} \
    --set UDEVD "${pkgs.systemd}/lib/systemd/systemd-udevd"
  '';
}
