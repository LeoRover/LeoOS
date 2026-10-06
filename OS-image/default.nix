{
  OSName,
  OSVersion,
  buildSystem,
  imageBuilder,
  pkgs,
  fetchurl,
  ...
}:
let
  imageSize = 8192;
  memSize = 4096;

  files-lite = pkgs.callPackage ./files-lite { };

  files-full = pkgs.callPackage ./files-full { };

  scripts = pkgs.callPackage ./scripts { inherit files-lite files-full imageBuilder; };

  debClosureGenerator = imageBuilder.mkDebClosureGenerator;

  packageLists =
    let
      noble-updates-stamp = "20260522T120000Z";
      ros2-stamp = "2026-04-13";
      fictionlab-stamp = "2026-05-23";
    in
    [
      {
        name = "noble-main";
        packagesFile = (
          fetchurl {
            url = "https://ports.ubuntu.com/dists/noble/main/binary-arm64/Packages.xz";
            sha256 = "sha256-ShkB5hJPsKER9d/8j1wUR09Eni7Ppx8urwspkX7bU/k=";
          }
        );
        urlPrefix = "https://ports.ubuntu.com";
      }
      {
        name = "noble-universe";
        packagesFile = (
          fetchurl {
            url = "https://ports.ubuntu.com/dists/noble/universe/binary-arm64/Packages.xz";
            sha256 = "sha256-bfIwz1z+vL1Z5OJxO47tB9wKrtZvtHHr8EbLcMywcnU=";
          }
        );
        urlPrefix = "https://ports.ubuntu.com";
      }
      {
        name = "noble-restricted";
        packagesFile = (
          fetchurl {
            url = "https://ports.ubuntu.com/dists/noble/restricted/binary-arm64/Packages.xz";
            sha256 = "sha256-Hf5OUUcjmkVHNty7zJKjdw3iRpA9O1ZnWWAjRejBp5c=";
          }
        );
        urlPrefix = "https://ports.ubuntu.com";
      }
      {
        name = "noble-updates-main";
        packagesFile = (
          fetchurl {
            url = "http://snapshot.ubuntu.com/ubuntu/${noble-updates-stamp}/dists/noble-updates/main/binary-arm64/Packages.xz";
            sha256 = "sha256-E4h2sfOt/O6hcCrh9TRJmVKQWYxP3AY9nUSe4eiLITs=";
          }
        );
        urlPrefix = "http://snapshot.ubuntu.com/ubuntu/${noble-updates-stamp}";
      }
      {
        name = "noble-updates-universe";
        packagesFile = (
          fetchurl {
            url = "http://snapshot.ubuntu.com/ubuntu/${noble-updates-stamp}/dists/noble-updates/universe/binary-arm64/Packages.xz";
            sha256 = "sha256-4T4ifnZFWdpYotDEbjpkQLOkm8eZ/y1YYZmHTUw4Ek8=";
          }
        );
        urlPrefix = "http://snapshot.ubuntu.com/ubuntu/${noble-updates-stamp}";
      }
      {
        name = "noble-updates-restricted";
        packagesFile = (
          fetchurl {
            url = "http://snapshot.ubuntu.com/ubuntu/${noble-updates-stamp}/dists/noble-updates/restricted/binary-arm64/Packages.xz";
            sha256 = "sha256-p3vkH2/ZbqlbTdrlLu8TcIbbDb61+zFHiV7T9ra6MbQ=";
          }
        );
        urlPrefix = "http://snapshot.ubuntu.com/ubuntu/${noble-updates-stamp}";
      }
      {
        name = "ros2";
        packagesFile = (
          fetchurl {
            url = "http://snapshots.ros.org/jazzy/${ros2-stamp}/ubuntu/dists/noble/main/binary-arm64/Packages.bz2";
            sha256 = "sha256-Yw5+pMwfp+dH3zGvwmBSTf8AkxDBDrrRAguf4kY/dUE=";
          }
        );
        urlPrefix = "http://snapshots.ros.org/jazzy/${ros2-stamp}/ubuntu";
      }
      {
        name = "fictionlab";
        packagesFile = (
          fetchurl {
            url = "https://archive.fictionlab.pl/dists/noble/snapshots/${fictionlab-stamp}/main/binary-arm64/Packages.gz";
            sha256 = "sha256-WN2ppWV0Um32deMlV9yAPA8SvbCmhDejqFbtZ9WNUhM=";
          }
        );
        urlPrefix = "https://archive.fictionlab.pl";
      }
    ];

  debsClosure = import (debClosureGenerator {
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
      "needrestart" # block automatic restart of services

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
      "rtw88-dkms" # Realtek WiFi driver

      "---"

      # STAGE 2 - ROS base packages

      # Added here to fix a problem with deb closure generator which cannot properly
      # resolve dependencies like "python3-distro (>= 1.4.0) | python3 (<< 3.8)"
      "python3-distro"

      "ros2-apt-source" # Configures sources for ROS 2 repo
      # "ros-dev-tools" # ROS development tools (rosdep, colcon, vcs etc.)
      # The newest ROS snapshot is missing ros-dev-tools, so we install its dependencies instead
      "build-essential"
      "cmake"
      "python3-setuptools"
      "python3-bloom"
      "python3-colcon-common-extensions"
      "python3-colcon-mixin"
      "python3-rosdep"
      "python3-vcstool"
      "wget"

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
      "ros-jazzy-aruco-opencv" # For aruco tracking
      "whiptail" # For leo-config TUI

      "---"

      # STAGE 4 - Desktop packages
      "xorg" # X11 server
      "xserver-xorg-video-fbdev" # X11 framebuffer driver
      "lxqt" # Desktop environment
      "openbox" # Window manager
      "lightdm" # Display manager
      "lightdm-gtk-greeter" # Greeter for lightdm
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

  exportStage = stageNr: builtins.elemAt debsClosure stageNr;

  debsStage0 = exportStage 0;
  debsStage1 = exportStage 1;
  debsStage2 = exportStage 2;
  debsStage3 = exportStage 3;
  debsStage4 = exportStage 4;

  vmPrepareCommand =
    if buildSystem != "aarch64-linux" then
      ''
        echo "Mounting binfmt_misc"
        ${pkgs.util-linux}/bin/mount binfmt_misc -t binfmt_misc /proc/sys/fs/binfmt_misc

        echo "Registering aarch64 binfmt"
        magic="\x7fELF\x02\x01\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\xb7\x00"
        mask="\xff\xff\xff\xff\xff\xff\xff\x00\xff\xff\xff\xff\xff\xff\x00\xff\xfe\xff\xff\xff"
        echo ":aarch64:M::$magic:$mask:${pkgs.pkgsStatic.qemu-user}/bin/qemu-aarch64:PF" \
          > /proc/sys/fs/binfmt_misc/register
      ''
    else
      "";

  imageStages = imageBuilder.mkImageStageChain {
    name = OSName;
    inherit imageSize memSize;
    vmSetup = vmPrepareCommand;
    stages = [
      {
        name = "stage1";
        outputName = "OSStage1Image";
        script = scripts.stage1;
        env = { inherit debsStage0 debsStage1; };
        debInputs = [
          debsStage0
          debsStage1
        ];
      }
      {
        name = "stage2";
        outputName = "OSStage2Image";
        script = scripts.stage2;
        env = {
          debsStage = debsStage2;
        };
        debInputs = [ debsStage2 ];
      }
      {
        name = "stage3";
        outputName = "OSStage3Image";
        script = scripts.stage3;
        env = {
          debsStage = debsStage3;
        };
        debInputs = [ debsStage3 ];
      }
      {
        name = "stage4";
        outputName = "OSStage4Image";
        script = scripts.stage4;
      }
      {
        name = "stage5";
        outputName = "OSStage5Image";
        script = scripts.stage5;
        env = { debsStage = debsStage4; };
        debInputs = [ debsStage4 ];
      }
      {
        name = "stage6";
        outputName = "OSStage6Image";
        script = scripts.stage6;
      }
    ];
  };
in
rec {
  OSStage1Image = imageStages.OSStage1Image;
  OSStage2Image = imageStages.OSStage2Image;
  OSStage3Image = imageStages.OSStage3Image;
  OSStage4Image = imageStages.OSStage4Image;
  OSStage5Image = imageStages.OSStage5Image;
  OSStage6Image = imageStages.OSStage6Image;

  OSLiteImage = imageBuilder.mkQcow2ImageStage {
    pname = "${OSName}-lite-image";
    version = OSVersion;
    inherit memSize;
    previousImage = OSStage4Image;
    script = scripts.stageFinal;
    vmSetup = vmPrepareCommand;
    env = {
      inherit OSName OSVersion;
      OSVariant = "lite";
    };
  };

  OSLiteRawImage = imageBuilder.mkRawImage {
    image = OSLiteImage;
    osName = OSName;
    osVersion = OSVersion;
    variant = "lite";
  };

  OSLiteCompressedImage = imageBuilder.mkCompressedImage {
    image = OSLiteRawImage;
    osName = OSName;
    osVersion = OSVersion;
    variant = "lite";
  };

  OSFullImage = imageBuilder.mkQcow2ImageStage {
    pname = "${OSName}-full-image";
    version = OSVersion;
    inherit memSize;
    previousImage = OSStage6Image;
    script = scripts.stageFinal;
    vmSetup = vmPrepareCommand;
    env = {
      inherit OSName OSVersion;
      OSVariant = "full";
    };
  };

  OSFullRawImage = imageBuilder.mkRawImage {
    image = OSFullImage;
    osName = OSName;
    osVersion = OSVersion;
    variant = "full";
  };

  OSFullCompressedImage = imageBuilder.mkCompressedImage {
    image = OSFullRawImage;
    osName = OSName;
    osVersion = OSVersion;
    variant = "full";
  };
}
