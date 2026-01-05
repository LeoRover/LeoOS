# LeoOS
LeoOS is a Debian-based Operating System distribution for the single-board computer running inside Leo Rover (currently Raspberry Pi 4B). It uses Ubuntu and Fictionlab package archives, comes with a ROS distribution, preconfigured network, a desktop environment, a service for starting base functionalities at boot, and many more.

This repository contains a [Nix flake] for building LeoOS images (OS images for Raspberry Pi computer running inside Leo Rover). \
For the built, compressed images, visit the [Releases page](https://github.com/LeoRover/LeoOS/releases).

## Versions
The major version (the first part in the three-part version number) is tied to the Ubuntu and ROS distributions the OS is based on. For now, the version semantics look as follows:
* 2.0.0 and up - Ubuntu 24.04 Noble Numbat and ROS 2 Jazzy
* 1.0.0 and up - Ubuntu 20.04 Focal Fossa and ROS Noetic
* Before 1.0.0 - Ubuntu 18.04 Bionic Beaver and ROS Melodic

## Building
### Pre-requisites
* [Nix] with [Flakes] enabled
* (optional) Hardware that supports [KVM] (e.g. Intel VT-x or AMD-V) for much faster builds due to hardware virtualization.
* (optional) ARM64 machine for faster builds. Otherwise, the image will be built in QEMU emulation mode, which is slower.

### Prepare the environment
First, check if your system supports KVM (Kernel-based Virtual Machine). \
You can check if KVM is available by running:
```bash
ls /dev/kvm
```
If it is not available, you may need to enable virtualization in the BIOS/UEFI settings.

You also need to ensure Nix is able to use KVM. To check this, run:
```bash
nix shell nixpkgs#qemu_kvm --command qemu-system-x86_64 -machine accel=kvm -cpu host -nographic -nodefaults -S
```
If you see a permission denied error, you need to allow access to `/dev/kvm`:
```bash
sudo chmod o+rw /dev/kvm
```

Also, make sure you have sufficient disk space available for the build. \
The compressed image is around 1.5 GB, but the build process requires more space for intermediate [Nix derivations] outputs. \
At least 20 GB of free space is recommended.

### Build the image
To build the image, run the following command:
```bash
nix build -Lv .#OSLiteCompressedImage
```
This will build the image and place it in the `result` directory. \
The first time you run this command, it will take a while to build the image, as it will download all the dependencies. \
Subsequent builds will be faster, as Nix caches the dependencies.

## Flashing the image
To flash the compressed image to an SD card, you can use the following command. Replace `/dev/sdX` with the actual device name of your SD card.

**WARNING: This will erase all data on the SD card!**

```bash
xz -dc ./result/LeoOS-<version>-<variant>.img.xz | sudo dd of=/dev/sdX bs=4M status=progress
```

Alternatively, you can use programs like [balenaEtcher] to flash the image.

[Nix flake]: https://nixos.wiki/wiki/Flakes
[Nix]: https://nixos.org/download.html
[Flakes]: https://nixos.wiki/wiki/Flakes
[KVM]: https://wiki.archlinux.org/title/KVM
[Nix derivations]: https://wiki.nixos.org/wiki/Derivations
[balenaEtcher]: https://etcher.balena.io
