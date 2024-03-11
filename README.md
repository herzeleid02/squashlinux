# SquashLinux

**Warning: This project is WIP**

<!-- vim-markdown-toc GFM -->

* [About](#about)
    * [`build_iso.sh`](#build_isosh)
* [Building the .iso image](#building-the-iso-image)
    * [Supported operating systems](#supported-operating-systems)
    * [Key configuration](#key-configuration)
    * [Creating chroot using podman](#creating-chroot-using-podman)
    * [Getting the .iso](#getting-the-iso)
* [TODO](#todo)
* [Dependencies](#dependencies)

<!-- vim-markdown-toc -->

## About
This repository contains many POSIX `sh` compatible (not yet) utilities for bootstrapping, customizing and getting an .iso file for booting almost any GNU/Linux system distribution.

Most of the utilities here can be used independently as well as a part of a bigger script. This README.md also contains information about some parts of manual setup.

### `build_iso.sh`
Script copies all the necessary bootloader files from the chroot directory, squashes the chrootable directory and then appends all the components together into one single bootable `.iso` image.

## Building the .iso image

### Supported operating systems
Currently, these OS images have been tested:
+ Debian (11, 12, unstable)
+ Fedora 39

Currently, Arch Linux `mkinitcpio` is not supported by the project, use `dracut` installations instead.

### Key configuration
In order for an image to be bootable, you need to ensure these things:
+ An init system is present (only systemd was tested)
+ Linux kernel and the neccessary modules were installed
+ `vmlinuz` and `initramfs` images were copied\renamed accordingly

While installing the init system is fairly simple, the kernel part is tricky. First, install a preferred kernel image, then you should install the necessary module for live-boot capabilities. The package information is written below. This section does not cover user setup, desktop environment configuration, etc etc. Keep in mind that installing bootloaders in your chroot directory is not necessary.

Names of the neccessary package for live-boot capabilites:
+ Debian-based distros -- `live-boot`
+ EL\Fedoda -- `dracut-live`

After installation of these packages, copy the most recent kernel and initramfs images and name them `vmlinuz` and `initrd.img` (subject for change)

``` 
/boot/vmlinuz
/boot/initrd.img
```

### Creating chroot using podman
Instead of using classic chroot bootstrapping methods, you can create a bootable system using podman containers. <!-- Generic pre-configured images should be stored in `Containerfiles` directory of this repository. -->

The advantages of this method are:
+ `root` access isnt required on any stage of the build procedure
+ Your chroot enviroment can be represented with podman\docker container images and `Containerfile`\`Dockerfile` textfiles, making your live system configurations shareable and declarative.

If you want to build your own custom image, just set up the container like a normal chroot environment (no bootloader installation required), install the necessary software and set up the system like you would normally do, install the kernel and the required modules (mentioned previously). You can `podman commit` your running container to create an podman\docker image that can be ready to be reused. To use the container root as a usable chrootable directory, use `podman unshare` and `podman mount $container_name`, `podman mount` should output the mounted directory of a container, after this you can invoke the tool to assembly the bootable `.iso` file (read further).

### Getting the .iso
Now, use the `build_iso.sh` tool to create a bootable live image. The tool can also be used with `podman unshare` in case you set up your chroot environment using podman.
```
./build_iso.sh -d $chroot_directory -o $name_of_iso_file
```
The tool also supports more options and GNU long style options.

## TODO

- [ ] initrd patcher tool for non-debian distros (or may be the link system for distro-local squashfs loaders)
- [x] Containerfiles
- [x] rewrite the option parser in `build_iso.sh`
- [ ] an option to set the tmp build directory (currently it only resides in `/tmp/`)
- [ ] figure out a way to stream the built squashfs directly to the iso or make xorriso build the iso while removing the appended files

## Dependencies
+ podman (for OS image pulling) (docker was not tested)
+ mksquashfs
+ xorriso
+ grub2
