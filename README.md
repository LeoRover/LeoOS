# leo_os
This repository contains an [image-builder] configuration for building LeoOS images (OS images for Raspberry Pi computer running inside Leo Rover). \
For the built, compressed images, visit the [Releases page](https://github.com/LeoRover/leo_os/releases).

# Build stages
The configuration consists of 5 stages, each one creates a valid root filesystem for Raspberry Pi 3/4. The last two stages are exported to bootable SD card images.

Here's a short description and list of changes for each stage:

* **stage0** - A minimal bootable Ubuntu 20.04 64-bit system for Raspberry Pi.
    * Use [multistrap] to bootstrap a root filesystem from Ubuntu and Fictionlab Package Archives.
    * Set regional configuration (locales, timezone, etc.).
    * Copy `config.txt` and `cmdline.txt` boot configuration files for RPi.
* **stage1** - A lightweight working system that is a base for LeoOS but does not contain anything specific to Leo Rover.
    * Add `init_firstboot` script that is called upon first boot of the system and runs scripts from the `/etc/firstboot.d` directory.
    * Add a script to `firtboot` config, which extends the filesystem to fill the SD card space.
    * Install `network-manager` and configure `netplan` to use it as a default renderer.
    * Add a script to `firtboot` config, which generates SSH host keys.
    * Set the hostname to `leo`.
    * Perform some minor system tweaks: enable bash color prompt, install some polkit and udev rules.
    * Create a default user and add him to different groups.
    * Install `rng-tools` package to use RPi Hardware TRNG to feed kernel entropy pool.
    * Install `pi-bluetooth` package to enable the onboard bluetooth module.
    * Install `zram-config` package to dedicate a portion of the RAM memory for swapping.
    * Install drivers for Realtek 88XXau WiFi network USB cards.
* **stage2** - A "ROS-ready" minimal system.
    * Add ROS apt repository.
    * Install some base ROS packages.
    * Install `rosdep` and `catkin-tools` python packages.
    * Initialize `rosdep`.
* **stage3** (`lite` image) - The headless (without a graphical interface) version of LeoOS.
    * Install `hostapd` and `dnsmasq` packages.
    * Configure the network to use the USB WiFi as an Access Point.
    * Add a script to `firstboot` config, which sets a unique Access Point SSID based on last 4 characters of RPi serial number.
    * Add `ap-disable` and `ap-disable` scripts that can be used to Enable/Disable Access Point at runtime.
    * Install ROS packages for Leo Rover.
    * Add robot configuration files under `/etc/ros` directory.
    * Add scripts for starting and stopping Leo Rover ROS functionality
    * Add the `leo` systemd service which start Leo Rover ROS functionality upon boot.
    * Install [leo_ui] and configure a HTTP server to host the Web interface.
    * Configure [update-motd].
* **stage4** (`full` image) - The full version of LeoOS.
    * Install lxqt desktop environment, a web browser and a GUI text editor.
    * Change the default wallpaper.
    * Configure `lightdm` to automatically login to the system.
    * Install ROS desktop packages.
    * Install and configure `xrdp` server (remote desktop).
    * Add a script to `firstboot` configuration, which generates keys for `xrdp`. 

[image-builder]: https://github.com/fictionlab/image-builder
[multistrap]: https://wiki.debian.org/Multistrap
[leo_ui]: https://github.com/LeoRover/leo_ui
[update-motd]: http://manpages.ubuntu.com/manpages/xenial/man5/update-motd.5.html