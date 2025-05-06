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

[Nix flake]: https://nixos.wiki/wiki/Flakes
[Nix]: https://nixos.org/download.html
[Flakes]: https://nixos.wiki/wiki/Flakes
[KVM]: https://wiki.archlinux.org/title/KVM
