{ OSName, OSVersion, buildSystem, lib, pkgs, fetchurl, stdenv, vmTools, ... }:
let
  imageSize = 8192;
  memSize = 4096;

  tools = import ./tools.nix { inherit lib pkgs; };

  files = pkgs.callPackage ./files { inherit OSName OSVersion; };

  scripts = pkgs.callPackage ./scripts { inherit files; };

  packageLists = let
    noble-updates-stamp = "20250317T120000Z";
    ros2-stamp = "2025-01-20";
    fictionlab-stamp = "2025-04-04";
  in [
    {
      name = "noble-main";
      packagesFile = (fetchurl {
        url =
          "https://ports.ubuntu.com/dists/noble/main/binary-arm64/Packages.xz";
        sha256 = "sha256-ShkB5hJPsKER9d/8j1wUR09Eni7Ppx8urwspkX7bU/k=";
      });
      urlPrefix = "https://ports.ubuntu.com";
    }
    {
      name = "noble-universe";
      packagesFile = (fetchurl {
        url =
          "https://ports.ubuntu.com/dists/noble/universe/binary-arm64/Packages.xz";
        sha256 = "sha256-bfIwz1z+vL1Z5OJxO47tB9wKrtZvtHHr8EbLcMywcnU=";
      });
      urlPrefix = "https://ports.ubuntu.com";
    }
    {
      name = "noble-restricted";
      packagesFile = (fetchurl {
        url =
          "https://ports.ubuntu.com/dists/noble/restricted/binary-arm64/Packages.xz";
        sha256 = "sha256-Hf5OUUcjmkVHNty7zJKjdw3iRpA9O1ZnWWAjRejBp5c=";
      });
      urlPrefix = "https://ports.ubuntu.com";
    }
    {
      name = "noble-updates-main";
      packagesFile = (fetchurl {
        url =
          "http://snapshot.ubuntu.com/ubuntu/${noble-updates-stamp}/dists/noble-updates/main/binary-arm64/Packages.xz";
        sha256 = "sha256-3JmF+P22Vez9jrH8kqBXgFGR46j9Ui9QBjYtYxTLYZU=";
      });
      urlPrefix = "http://snapshot.ubuntu.com/ubuntu/${noble-updates-stamp}";
    }
    {
      name = "noble-updates-universe";
      packagesFile = (fetchurl {
        url =
          "http://snapshot.ubuntu.com/ubuntu/${noble-updates-stamp}/dists/noble-updates/universe/binary-arm64/Packages.xz";
        sha256 = "sha256-B4TkhivRo+5Xr60cpWY2U/KXBDedjLrvNlh+UOVgqnc=";
      });
      urlPrefix = "http://snapshot.ubuntu.com/ubuntu/${noble-updates-stamp}";
    }
    {
      name = "noble-updates-restricted";
      packagesFile = (fetchurl {
        url =
          "http://snapshot.ubuntu.com/ubuntu/${noble-updates-stamp}/dists/noble-updates/restricted/binary-arm64/Packages.xz";
        sha256 = "sha256-/CFo3ikHgW7AGJwbaZvNZT3IHwFUBG8d1+1hzs/7eo0=";
      });
      urlPrefix = "http://snapshot.ubuntu.com/ubuntu/${noble-updates-stamp}";
    }
    {
      name = "ros2";
      packagesFile = (fetchurl {
        url =
          "http://snapshots.ros.org/jazzy/${ros2-stamp}/ubuntu/dists/noble/main/binary-arm64/Packages.bz2";
        sha256 = "sha256-Iay9j+u+96apUQRl3jmE4kBaXFk+1ubz2PUcI4YjZug=";
      });
      urlPrefix = "http://snapshots.ros.org/jazzy/${ros2-stamp}/ubuntu";
    }
    {
      name = "fictionlab";
      packagesFile = (fetchurl {
        url =
          "http://files.fictionlab.pl/repo/dists/noble/snapshots/${fictionlab-stamp}/main/binary-arm64/Packages.gz";
        sha256 = "sha256-mk5lNCaXiKesboi4LyLbhqDhFF2fxxPArRFKTZj4RGM=";
      });
      urlPrefix = "http://files.fictionlab.pl/repo";
    }
  ];

  debsClosure = import (tools.debClosureGenerator {
    name = "debs-closure";
    inherit packageLists;
    packages = [
      # STAGE 0 - predependencies
      "base-passwd"
      "base-files"
      "init-system-helpers"
      "dpkg"
      "libc-bin"
      "dash"
      "coreutils"
      "diffutils"
      "sed"
      "debconf"
      "perl"

      "---"

      # STAGE 1 - base packages
      "grep"
      "apt"
      "bash"
      "login"
      "passwd"
      "findutils"
      "curl"
      "patch"
      "locales"
      "util-linux"
      "file"
      "bsdutils"
      "less"
      "nano"
      "vim"
      "sudo"
      "dbus" # IPC used by various applications
      "ncurses-base" # terminfo to let applications talk to terminals better
      "bash-completion"
      "htop"
      "fdisk"

      ## Boot stuff
      "systemd" # init system
      "systemd-sysv" # provides systemd as /sbin/init
      "libpam-systemd" # makes systemd user sevices work
      "policykit-1" # authorization manager for systemd
      "e2fsprogs" # initramfs hook wants fsck
      "zstd" # initramfs hook wants zstd (or gzip)
      "initramfs-tools" # hook and tools for generating an initramfs
      "flash-kernel" # utilities for updating kernel
      "u-boot-tools" # needed for flash-kernel
      "linux-raspi" # kernel for Raspberry Pi
      "linux-firmware-raspi" # Raspberry Pi GPU firmware and bootloaders
      "libraspberrypi-bin" # Raspberry Pi utilities
      "libraspberrypi-dev" # headers for Raspberry Pi VideoCore IV libraries
      "rpi-eeprom" # Raspberry Pi EEPROM utilities

      ## Networking stuff
      "netplan.io" # network configuration utility
      "iproute2" # ip cli utilities
      "iputils-ping" # ping utility
      "systemd-resolved" # DNS resolver
      "systemd-timesyncd" # SNTP client
      "network-manager" # network management daemon (nmtui)
      "avahi-daemon" # mDNS support
      "openssh-server" # Remote login
      "nginx" # Web server
      "rtw88-dkms" # Realtek WiFi driver

      "---"

      # STAGE 2 - ROS base packages
      "ros-dev-tools"
      "python3-colcon-common-extensions"
      "ros-jazzy-ros-base"

      "---"

      # STAGE 3 - Leo-specific packages
      "python3-stm32loader"
      "leo-ui"
      "ros-jazzy-leo-robot"
      "ros-jazzy-leo-camera"
      "ros-jazzy-micro-ros-agent"
    ];
  }) { inherit fetchurl; };

  debsStage0 = pkgs.runCommand "debs-stage0" { } ''
    echo "${
      toString (lib.intersperse "|" (builtins.elemAt debsClosure 0))
    }" > $out
  '';

  debsStage1 = pkgs.runCommand "debs-stage1" { } ''
    echo "${
      toString (lib.intersperse "|" (builtins.elemAt debsClosure 1))
    }" > $out
  '';

  debsStage2 = pkgs.runCommand "debs-stage2" { } ''
    echo "${
      toString (lib.intersperse "|" (builtins.elemAt debsClosure 2))
    }" > $out
  '';

  debsStage3 = pkgs.runCommand "debs-stage3" { } ''
    echo "${
      toString (lib.intersperse "|" (builtins.elemAt debsClosure 3))
    }" > $out
  '';

  vmPrepareCommand = if buildSystem != "aarch64-linux" then ''
    echo "Mounting binfmt_misc"
    ${pkgs.util-linux}/bin/mount binfmt_misc -t binfmt_misc /proc/sys/fs/binfmt_misc

    echo "Registering aarch64 binfmt"
    magic="\x7fELF\x02\x01\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\xb7\x00"
    mask="\xff\xff\xff\xff\xff\xff\xff\x00\xff\xff\xff\xff\xff\xff\x00\xff\xfe\xff\xff\xff"
    echo ":aarch64:M::$magic:$mask:${pkgs.pkgsStatic.qemu-user}/bin/qemu-aarch64:PF" \
      > /proc/sys/fs/binfmt_misc/register
  '' else
    "";
in rec {
  OSStage1Image = vmTools.runInLinuxVM (stdenv.mkDerivation {
    inherit OSName memSize debsStage0 debsStage1;

    pname = "${OSName}-stage1-image";
    version = OSVersion;

    preVM = ''
      mkdir -p $out
      diskImage=$out/OS.img
      ${pkgs.buildPackages.qemu_kvm}/bin/qemu-img create -f raw $diskImage "${
        toString imageSize
      }M"
    '';

    buildCommand = ''
      ${vmPrepareCommand}
      ${scripts.stage1}/build.sh

      mkdir -p "$out/nix-support"
      echo ${toString [ debsStage0 debsStage1 ]} > $out/nix-support/deb-inputs
    '';
  });

  OSStage2Image = vmTools.runInLinuxVM (stdenv.mkDerivation {
    inherit OSName memSize debsStage2;

    pname = "${OSName}-stage2-image";
    version = OSVersion;

    preVM = ''
      mkdir -p $out
      diskImage=$out/OS.img
      ${pkgs.buildPackages.qemu_kvm}/bin/qemu-img create \
        -o backing_file=${OSStage1Image}/OS.img,backing_fmt=raw \
        -f qcow2 $diskImage
    '';

    buildCommand = ''
      ${vmPrepareCommand}
      ${scripts.stage2}/build.sh

      mkdir -p $out/nix-support
      echo ${OSStage1Image}/OS.img > $out/nix-support/backing_image
      echo ${debsStage2} > $out/nix-support/deb-inputs
    '';
  });

  OSStage3Image = vmTools.runInLinuxVM (stdenv.mkDerivation {
    inherit OSName memSize debsStage3;

    pname = "${OSName}-stage3-image";
    version = OSVersion;

    preVM = ''
      mkdir -p $out
      diskImage=$out/OS.img
      ${pkgs.buildPackages.qemu_kvm}/bin/qemu-img create \
        -o backing_file=${OSStage2Image}/OS.img,backing_fmt=qcow2 \
        -f qcow2 $diskImage
    '';

    buildCommand = ''
      ${vmPrepareCommand}
      ${scripts.stage3}/build.sh

      mkdir -p $out/nix-support
      echo ${OSStage2Image}/OS.img > $out/nix-support/backing_image
      echo ${debsStage3} > $out/nix-support/deb-inputs
    '';
  });

  OSStage4Image = vmTools.runInLinuxVM (stdenv.mkDerivation {
    inherit OSName memSize;

    pname = "${OSName}-stage4-image";
    version = OSVersion;

    preVM = ''
      mkdir -p $out
      diskImage=$out/OS.img
      ${pkgs.buildPackages.qemu_kvm}/bin/qemu-img create \
        -o backing_file=${OSStage3Image}/OS.img,backing_fmt=qcow2 \
        -f qcow2 $diskImage
    '';

    buildCommand = ''
      ${vmPrepareCommand}
      ${scripts.stage4}/build.sh

      mkdir -p $out/nix-support
      echo ${OSStage3Image}/OS.img > $out/nix-support/backing_image
    '';
  });

  OSLiteImage = stdenv.mkDerivation {
    pname = "${OSName}-lite-image";
    version = OSVersion;

    buildCommand = ''
      mkdir -p $out
      diskImage=$out/${OSName}-${OSVersion}-lite.img
      ${pkgs.buildPackages.qemu_kvm}/bin/qemu-img convert -f qcow2 -O raw \
        ${OSStage4Image}/OS.img $diskImage

      echo "Compressing the image"
      ${pkgs.zstd}/bin/zstd -T0 --rm --ultra -20 $diskImage

      mkdir -p $out/nix-support
      echo ${OSStage4Image}/OS.img > $out/nix-support/source_image
    '';
  };
}
