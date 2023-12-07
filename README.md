# SquashLinux

**Warning: This project is WIP**

## About
This repository contains many POSIX `sh` compatible (not yet) utilities for bootstrapping, customizing and getting an .iso file for booting almost any GNU/Linux system distribution.

Most of the utilities here can be used independently as well as a part of a bigger script. This README.md also contains information about some parts of manual setup.

### squashlinux-pull
Utility for pulling and extracting an OCI container (using `podman pull` and `tar`) into a chrootable directory. More versatile and portable than distro-specific bootstap utilities. Also supports experimental `--rootless` option for those who need it (not my buisness).


## Installation

## Usage

## Project goals
+ Create a set of tools for easy creation of Live USB images based on almost **any** GNU/Linux distribution
+ Provide an easy-to-use tool for bootstrapping several distros
+ Create a way to quickly convert any chrootable rootfs hirerarchy into a bootable Live USB image

## DIY
<!-- (info about squashlinux-pull, but manual) -->

## Dependencies
+ podman (for OS image pulling)
+ mksquashfs
+ xorriso
+ grub2
