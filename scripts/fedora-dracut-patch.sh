#!/bin/sh
# idk if plain POSIX sh can run this...
# really hacky solution, but whatever

kernel_ver=$(rpm -q kernel | sort -V | tail -n 1 | sed 's/kernel-//')

# dracut rule
echo 'add_dracutmodules+="dmsquash-live livenet dmsquash-live dmsquash-live-autooverlay dmsquash-live-ntfs"' > /usr/lib/dracut/dracut.conf.d/11-livenet.conf

dracut --verbose -N --no-hostonly-cmdline --force --kver $kernel_ver
cp /lib/modules/${kernel_ver}/vmlinuz /boot/vmlinuz
# TODO: change debian-ish initrd names to something more sensible :)
cp /boot/initramfs-${kernel_ver}.img /boot/initrd.img
