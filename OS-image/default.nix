{ OSName, OSVersion, buildSystem, lib, pkgs, fetchurl, stdenv, vmTools, ... }:
let
  imageSize = 8192;
  memSize = 4096;

  tools = import ./tools.nix { inherit lib pkgs; };

  files-lite = pkgs.callPackage ./files-lite { };

  files-full = pkgs.callPackage ./files-full { };

  scripts = pkgs.callPackage ./scripts { inherit files-lite files-full; };

  packageLists = let
    noble-updates-stamp = "20250602T120000Z";
    ros2-stamp = "2025-04-30";
    fictionlab-stamp = "2025-06-02";
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
        sha256 = "sha256-/mxMpLmvEVnQy1mBidu/CjritRWbwLZapiOAa47CmS0=";
      });
      urlPrefix = "http://snapshot.ubuntu.com/ubuntu/${noble-updates-stamp}";
    }
    {
      name = "noble-updates-universe";
      packagesFile = (fetchurl {
        url =
          "http://snapshot.ubuntu.com/ubuntu/${noble-updates-stamp}/dists/noble-updates/universe/binary-arm64/Packages.xz";
        sha256 = "sha256-Xb26lohXYcOgRDeJxaOx9aG5iktPvXMeAEITmzusr7c=";
      });
      urlPrefix = "http://snapshot.ubuntu.com/ubuntu/${noble-updates-stamp}";
    }
    {
      name = "noble-updates-restricted";
      packagesFile = (fetchurl {
        url =
          "http://snapshot.ubuntu.com/ubuntu/${noble-updates-stamp}/dists/noble-updates/restricted/binary-arm64/Packages.xz";
        sha256 = "sha256-KMGAmhReDMOv947X6CcEoftL6qFxjuKhGxZmMZXUvyk=";
      });
      urlPrefix = "http://snapshot.ubuntu.com/ubuntu/${noble-updates-stamp}";
    }
    {
      name = "ros2";
      packagesFile = (fetchurl {
        url =
          "http://snapshots.ros.org/jazzy/${ros2-stamp}/ubuntu/dists/noble/main/binary-arm64/Packages.bz2";
        sha256 = "sha256-ptB10XQM+JgpAv/thF5JAzE04WTU1nMOd6QO04zHj9E=";
      });
      urlPrefix = "http://snapshots.ros.org/jazzy/${ros2-stamp}/ubuntu";
    }
    {
      name = "fictionlab";
      packagesFile = (fetchurl {
        url =
          "https://archive.fictionlab.pl/dists/noble/snapshots/${fictionlab-stamp}/main/binary-arm64/Packages.gz";
        sha256 = "sha256-ES7VzUuyyKWltj2rQuZ4FVnnvm2C5UGKm8KjRTfPO+4=";
      });
      urlPrefix = "https://archive.fictionlab.pl";
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
      "ncurses-base" # terminfo to let applications talk to terminals better
      "bash-completion"
      "htop"
      "fdisk"
      "git"
      "tmux" # terminal multiplexer
      "i2c-tools" # tools for working with I2C devices
      "zram-config" # kernel module and userspace tools for zram
      "usbutils" # tools for working with USB devices
      "man-db" # tools for reading manual pages

      ## Boot stuff
      "systemd" # init system
      "systemd-sysv" # provides systemd as /sbin/init
      "libpam-systemd" # makes systemd user sevices work
      "dbus" # IPC used by various applications
      "dbus-user-session" # to talk with systemd user services
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
      "wpasupplicant" # supplicant for managing Wi-Fi connections
      "hostapd" # Access Point daemon
      "dnsmasq" # DHCP and DNS servers
      "nftables" # firewall (for masquerade NAT)
      "avahi-daemon" # mDNS support
      "openssh-server" # Remote login
      "nginx" # Web server
      "bridge-utils" # bridge management utilities
      "bluez" # Bluetooth stack
      "hostname" # hostname management
      "rtl88xxau-dkms" # Realtek WiFi driver

      "---"

      # STAGE 2 - ROS base packages

      # Added here to fix a problem with deb closure generator which cannot properly
      # resolve dependencies like "python3-distro (>= 1.4.0) | python3 (<< 3.8)"
      "python3-distro"

      "ros2-apt-source" # Configures sources for ROS 2 repo
      "ros-dev-tools" # ROS development tools (rosdep, colcon, vcs etc.)
      "ros-jazzy-ros-base" # ROS base packages

      "---"

      # STAGE 3 - Leo-specific packages
      "python3-rpi-lgpio" # Replacement for RPi.GPIO which supports RPi 5
      "python3-stm32loader" # Tool for flashing LeoCore
      "leo-ui" # Web UI for controlling Leo Rover
      "ros-jazzy-leo-robot" # Leo Rover ROS packages
      "ros-jazzy-leo-camera" # hidden dependency of leo_robot
      "ros-jazzy-compressed-image-transport" # image transport plugin that provides compressed image streams
      "ros-jazzy-micro-ros-agent" # For talking with LeoCore

      "---"

      # STAGE 4 - Desktop packages
      "xorg" # X11 server
      "xserver-xorg-video-fbdev" # X11 framebuffer driver
      "lxqt" # Desktop environment
      "openbox" # Window manager
      "lightdm" # Display manager
      "lightdm-mini-greeter" # Greeter for lightdm
      "accountsservice" # User account management
      "blueman" # Bluetooth manager
      "pulseaudio-module-bluetooth" # Bluetooth audio support
      "network-manager-gnome" # Network configuration editor
      "nm-tray" # Network manager tray applet
      "gvfs" # Trash support
      "lubuntu-artwork" # LXQt theme
      "papirus-icon-theme" # LXQt icon theme
      "kde-style-breeze" # LXQt color scheme
      "breeze-cursor-theme" # LXQt cursor theme
      "firefox-esr" # Web browser
      "tigervnc-scraping-server" # VNC server
      "ros-jazzy-desktop" # ROS desktop packages
      "ros-jazzy-leo-desktop" # Leo-specific ROS desktop packages
    ];
  }) { inherit fetchurl; };

  exportStage = stageNr:
    pkgs.runCommand "debs-stage${toString stageNr}" { } ''
      echo "${
        toString (lib.intersperse "|" (builtins.elemAt debsClosure stageNr))
      }" > $out
    '';

  debsStage0 = exportStage 0;
  debsStage1 = exportStage 1;
  debsStage2 = exportStage 2;
  debsStage3 = exportStage 3;
  debsStage4 = exportStage 4;

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
    version = "";

    preVM = ''
      mkdir -p $out
      diskImage=$out/OS.img
      ${pkgs.buildPackages.qemu_kvm}/bin/qemu-img create -f qcow2 $diskImage "${
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
    version = "";

    preVM = ''
      mkdir -p $out
      diskImage=$out/OS.img
      ${pkgs.buildPackages.qemu_kvm}/bin/qemu-img create \
        -o backing_file=${OSStage1Image}/OS.img,backing_fmt=qcow2 \
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
    version = "";

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
    version = "";

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

  OSStage5Image = vmTools.runInLinuxVM (stdenv.mkDerivation {
    inherit OSName memSize debsStage4;

    pname = "${OSName}-stage5-image";
    version = "";

    preVM = ''
      mkdir -p $out
      diskImage=$out/OS.img
      ${pkgs.buildPackages.qemu_kvm}/bin/qemu-img create \
        -o backing_file=${OSStage4Image}/OS.img,backing_fmt=qcow2 \
        -f qcow2 $diskImage
    '';

    buildCommand = ''
      ${vmPrepareCommand}
      ${scripts.stage5}/build.sh

      mkdir -p $out/nix-support
      echo ${OSStage4Image}/OS.img > $out/nix-support/backing_image
    '';
  });

  OSStage6Image = vmTools.runInLinuxVM (stdenv.mkDerivation {
    inherit OSName memSize debsStage4;

    pname = "${OSName}-stage6-image";
    version = "";

    preVM = ''
      mkdir -p $out
      diskImage=$out/OS.img
      ${pkgs.buildPackages.qemu_kvm}/bin/qemu-img create \
        -o backing_file=${OSStage5Image}/OS.img,backing_fmt=qcow2 \
        -f qcow2 $diskImage
    '';

    buildCommand = ''
      ${vmPrepareCommand}
      ${scripts.stage6}/build.sh

      mkdir -p $out/nix-support
      echo ${OSStage5Image}/OS.img > $out/nix-support/backing_image
    '';
  });

  OSLiteImage = vmTools.runInLinuxVM (stdenv.mkDerivation rec {
    inherit OSName OSVersion memSize;
    OSVariant = "lite";

    pname = "${OSName}-${OSVariant}-image";
    version = OSVersion;

    preVM = ''
      mkdir -p $out
      diskImage=$out/OS.img
      ${pkgs.buildPackages.qemu_kvm}/bin/qemu-img create \
        -o backing_file=${OSStage4Image}/OS.img,backing_fmt=qcow2 \
        -f qcow2 $diskImage
    '';

    buildCommand = ''
      ${vmPrepareCommand}
      ${scripts.stageFinal}/build.sh

      mkdir -p $out/nix-support
      echo ${OSStage4Image}/OS.img > $out/nix-support/backing_image
    '';
  });

  OSLiteCompressedImage = stdenv.mkDerivation rec {
    OSVariant = "lite";

    pname = "${OSName}-${OSVariant}-compressed-image";
    version = OSVersion;

    buildCommand = ''
      mkdir -p $out
      diskImage=$out/${OSName}-${OSVersion}-lite.img
      ${pkgs.buildPackages.qemu_kvm}/bin/qemu-img convert -f qcow2 -O raw \
        ${OSLiteImage}/OS.img $diskImage

      LAST_SECTOR=$(${pkgs.parted}/bin/parted $diskImage -ms unit s print | tail -n +3 | cut -d: -f3 | sed 's/s//' | sort -n | tail -1)
      SECTOR_SIZE=512
      DISK_SIZE=$(( (LAST_SECTOR + 1) * SECTOR_SIZE ))

      ${pkgs.buildPackages.qemu_kvm}/bin/qemu-img resize --shrink -f raw $diskImage $DISK_SIZE

      echo "Compressing the image"
      ${pkgs.xz}/bin/xz -T0 --compress --extreme $diskImage

      mkdir -p $out/nix-support
      echo ${OSLiteImage}/OS.img > $out/nix-support/source_image
    '';
  };

  OSFullImage = vmTools.runInLinuxVM (stdenv.mkDerivation rec {
    inherit OSName OSVersion memSize;
    OSVariant = "full";

    pname = "${OSName}-${OSVariant}-image";
    version = OSVersion;

    preVM = ''
      mkdir -p $out
      diskImage=$out/OS.img
      ${pkgs.buildPackages.qemu_kvm}/bin/qemu-img create \
        -o backing_file=${OSStage6Image}/OS.img,backing_fmt=qcow2 \
        -f qcow2 $diskImage
    '';

    buildCommand = ''
      ${vmPrepareCommand}
      ${scripts.stageFinal}/build.sh

      mkdir -p $out/nix-support
      echo ${OSStage6Image}/OS.img > $out/nix-support/backing_image
    '';
  });

  OSFullCompressedImage = stdenv.mkDerivation rec {
    OSVariant = "full";

    pname = "${OSName}-${OSVariant}-compressed-image";
    version = OSVersion;

    buildCommand = ''
      mkdir -p $out
      diskImage=$out/${OSName}-${OSVersion}-${OSVariant}.img
      ${pkgs.buildPackages.qemu_kvm}/bin/qemu-img convert -f qcow2 -O raw \
        ${OSFullImage}/OS.img $diskImage

      LAST_SECTOR=$(${pkgs.parted}/bin/parted $diskImage -ms unit s print | tail -n +3 | cut -d: -f3 | sed 's/s//' | sort -n | tail -1)
      SECTOR_SIZE=512
      DISK_SIZE=$(( (LAST_SECTOR + 1) * SECTOR_SIZE ))

      ${pkgs.buildPackages.qemu_kvm}/bin/qemu-img resize --shrink -f raw $diskImage $DISK_SIZE

      echo "Compressing the image"
      ${pkgs.xz}/bin/xz -T0 --compress --extreme $diskImage

      mkdir -p $out/nix-support
      echo ${OSFullImage}/OS.img > $out/nix-support/source_image
    '';
  };
}
