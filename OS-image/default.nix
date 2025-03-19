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
    fictionlab-stamp = "2024-07-22";
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
        sha256 = "sha256-Pu9rjQ3ICsUcYLKpbmluzZXqb2Essaqv/0p96sBSvM0=";
      });
      urlPrefix = "http://files.fictionlab.pl/repo";
    }
  ];

  # Packages that provide programs needed to install other packages
  debs-unpack-closure = import (tools.debClosureGenerator {
    name = "debs-unpack-closure";
    inherit packageLists;
    packages = [
      "base-files"
      "dpkg"
      "libc-bin"
      "dash"
      "coreutils"
      "diffutils"
      "sed"
      "debconf"
      "perl"
    ];
  }) { inherit fetchurl; };

  debs_unpack = pkgs.runCommand "debs-unpack" { } ''
    echo "${toString debs-unpack-closure}" > $out
  '';

  debs-install-closure = import (tools.debClosureGenerator {
    name = "debs-install-closure";
    inherit packageLists;
    packages = [
      "base-passwd"
      "init-system-helpers"
      "grep"
      "base-files"
      "apt"
      "dpkg"
      "libc-bin"
      "bash"
      "dash"
      "coreutils"
      "diffutils"
      "sed"
      "login"
      "passwd"
      "debconf"
      "perl"
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

      # # Boot stuff
      "systemd" # init system
      "systemd-sysv" # provides systemd as /sbin/init
      "libpam-systemd" # makes systemd user sevices work
      "policykit-1" # authorization manager for systemd
      "e2fsprogs" # initramfs wants fsck
      "zstd" # compress kernel using zstd
      "linux-raspi" # kernel
      "initramfs-tools" # hooks for generating an initramfs
      "flash-kernel" # utilities for updating kernel
      "u-boot-tools" # tools for working with u-boot
      "u-boot-rpi" # u-boot for Raspberry Pi
      "linux-firmware-raspi" # Raspberry Pi GPU firmware and bootloaders
      "libraspberrypi-bin" # Raspberry Pi utilities
      "libraspberrypi-dev" # headers for Raspberry Pi VideoCore IV libraries
      "rpi-eeprom" # Raspberry Pi EEPROM utilities

      # # Networking stuff
      # "netplan.io" # network configuration utility
      # "iproute2" # ip cli utilities
      # "iputils-ping" # ping utility
      # "systemd-resolved" # DNS resolver
      # "systemd-timesyncd" # SNTP client
      # "avahi-daemon" # mDNS support
      # "openssh-server" # Remote login
      # "networkd-dispatcher" # Networkd hooks
      # "nginx" # Web server

      # # ROS build tools
      # "ros-dev-tools"
      # "python3-colcon-common-extensions"

      # # ROS base packages
      # "ros-jazzy-ros-base"
    ];
  }) { inherit fetchurl; };

  debs_install = pkgs.runCommand "debs-install" { } ''
    echo "${toString (lib.intersperse "|" debs-install-closure)}" > $out
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

  OSStage1Image = vmTools.runInLinuxVM (stdenv.mkDerivation {
    inherit OSName memSize debs_unpack debs_install;

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
    '';
  });

  OSStage2Image = vmTools.runInLinuxVM (stdenv.mkDerivation {
    inherit OSName memSize;

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
    '';
  });

  OSLiteImage = stdenv.mkDerivation {
    pname = "${OSName}-lite-image";
    version = OSVersion;

    buildCommand = ''
      mkdir -p $out
      diskImage=$out/${OSName}-${OSVersion}-lite.img
      ${pkgs.buildPackages.qemu_kvm}/bin/qemu-img convert -f qcow2 -O raw \
        ${OSStage2Image}/OS.img $diskImage
    '';
  };

in OSLiteImage
