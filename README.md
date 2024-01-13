# SquashLinux

**Warning: This project is WIP**

## About
This repository contains many POSIX `sh` compatible (not yet) utilities for bootstrapping, customizing and getting an .iso file for booting almost any GNU/Linux system distribution.

Most of the utilities here can be used independently as well as a part of a bigger script. This README.md also contains information about some parts of manual setup.

### squashlinux-pull (deprecated)
Utility for pulling and extracting an OCI container (using `podman pull` and `tar`) into a chrootable directory. More versatile and portable than distro-specific bootstap utilities. Also supports experimental `--rootless` option for those who need it (not my buisness).

### `build_iso.sh`
Script copies all the necessary bootloader files from the chroot directory, squashes the chrootable directory and then appends all the components together into one single bootable `.iso` image.

## Notes
### Building an .iso without using extra space with podman and exported tarballs
1. Create a podman container
2. Edit the container environemnt however you want (set the users, install all the necessary software)
3. Use `podman mount`
4. Use the printed out directory as an argument for `build_iso.sh`


## Installation

## Usage

## Project goals
+ Create a set of tools for easy creation of Live USB images based on almost **any** GNU/Linux distribution
+ Provide an easy-to-use tool for bootstrapping several distros
+ Create a way to quickly convert any chrootable rootfs hirerarchy into a bootable Live USB image

## DIY
<!-- (info about squashlinux-pull, but manual) -->

## TODO:
[ ] initrd patcher tool for non-debian distros (or may be the link system for distro-local squashfs loaders)
[ ] rewrite the option parser in `build_iso.sh`
[ ] an option to set the tmp build directory (currently it only resides in `/tmp/`)
[ ] figure out a way to stream the built squashfs directly to the iso or make xorriso build the iso while removing the appended files

## Dependencies
+ podman (for OS image pulling)
+ mksquashfs
+ xorriso
+ grub2
