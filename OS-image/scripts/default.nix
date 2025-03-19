{ files, pkgs, stdenv, makeWrapper }: {
  stage1 = stdenv.mkDerivation {
    name = "scripts-stage1";
    src = ./.;
    nativeBuildInputs = [ makeWrapper ];
    phases = [ "unpackPhase" "installPhase" "postFixup" ];
    installPhase = ''
      mkdir -p $out
      cp -vr $src/buildStage1.sh $out/build.sh
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
      --set NIX_STORE_DIR ${builtins.storeDir}
    '';
  };

  stage2 = stdenv.mkDerivation {
    name = "scripts-stage2";
    src = ./.;
    nativeBuildInputs = [ makeWrapper ];
    phases = [ "unpackPhase" "installPhase" "postFixup" ];
    installPhase = ''
      mkdir -p $out
      cp -vr $src/buildStage2.sh $out/build.sh
    '';
    postFixup = ''
      wrapProgram $out/build.sh \
      --set PATH "${
        with pkgs;
        lib.makeBinPath [ coreutils systemd util-linux ]
      }" \
      --set FILES_DIR ${files} \
      --set UDEVD "${pkgs.systemd}/lib/systemd/systemd-udevd"
    '';
  };
}
