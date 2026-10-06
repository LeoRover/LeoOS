{ files-lite, files-full, imageBuilder, pkgs }:
let
  mkScript = imageBuilder.mkScript;
in
{
  stage1 = mkScript {
    name = "scripts-stage1";
    src = ./buildStage1.sh;
    packages = with pkgs; [
      coreutils
      dosfstools
      dpkg
      e2fsprogs
      gnutar
      parted
      systemd
      util-linux
    ];
  };

  stage2 = imageBuilder.mkInstallDebsScript {
    name = "scripts-stage2";
    environment = {
      BOOT_MOUNT = "/boot/firmware";
    };
  };

  stage3 = imageBuilder.mkInstallDebsScript {
    name = "scripts-stage3";
    environment = {
      BOOT_MOUNT = "/boot/firmware";
    };
  };

  stage4 = mkScript {
    name = "scripts-stage4";
    src = ./buildStage4.sh;
    packages = with pkgs; [ coreutils gnused systemd util-linux ];
    environment = {
      FILES_DIR = files-lite;
      UDEVD = "${pkgs.systemd}/lib/systemd/systemd-udevd";
    };
  };

  stage5 = imageBuilder.mkInstallDebsScript {
    name = "scripts-stage5";
    environment = {
      BOOT_MOUNT = "/boot/firmware";
    };
  };

  stage6 = mkScript {
    name = "scripts-stage6";
    src = ./buildStage6.sh;
    packages = with pkgs; [ coreutils gnused util-linux ];
    environment = { FILES_DIR = files-full; };
  };

  stageFinal = imageBuilder.mkFinalizeImageScript {
    name = "scripts-stageFinal";
    environment = { BOOT_MOUNT = "/boot/firmware"; };
  };
}
