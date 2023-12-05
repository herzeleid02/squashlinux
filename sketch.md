# squashlinux (sfslinux)

+ bootstrap (regular bootstrap from additional scripts) (deprecated and superseded by pull)
+ pull (pull the tar from podman and unpack it... more choice for distros)
+ chroot (chroot with additional options for graphics and other fancy stuff to use) (better function -- enter/setup)
+ two key elements:
    + patch (to be renamed) (initrd building tool) (i should probably steal debian initrd scripts from live-boot or something) (i also think that the patcher should be uhh an embedded function or something) (?)
    + build-iso (to be renamed)

## concept of usage
pull
enter (or setup) -- sets up users, networking and locale
build-iso

## notes
+ the initrd and vmlinuz image should have a `*-live` prefix since the tool might be used on /
+ use docker-dir format (and use it in /tmp/ somewhere)
+ you should also try making an option for writeable space after than(actually no, diy)
+ patcher should be in isobuild program and it should delete the temporary live copies and initrd


## pull (uses podman for saving tars) (or export)
```
--image, -i
--no-copy-id (dont copy id)
--quiet, -q 
```

## bootstrap (deprecate it, meh)
```
--distro, -d
--no-copy-id (dont copy id)
bootstrap --no-copy-id --distro debian10
```


## build-iso (subject for renaming)
```
--help, -h
--verbose -v 
-o --output-iso (to be changed)
--directory, -d (chrootable directory)
--compression (comp alrorithm) (should be set like zstd:4) (for example)
--make-iso (make iso i guess)
~~--squashfs-only (option to make... bad idea... just diy)~~
--force (skip the vmlinuz and initrd checks)
--tmpdir= (tempdirectory)
~~--squashfile=(maybe it should manage squashfiles, actually no, diy)~~
--bootloader (hybrid, bios, efi, ia32-efi, x86_64-efi)

variables for it

build_root="/tmp/iso-$(date +%d%m%Y)-$(tr -dc a-z </dev/urandom | head -c 4)"
chroot_dir=""
output_iso=""
v_keya=""
verbosity=0
arg_mode=0 # 0 == pass args as is; 1 == use options
comp_algo="gzip" # gzip should be default (can be zstd:15)
comp_level="" # (or just make fucking
comp_command="" #
grub_make_command="grub-mkstandalone" # can also be "grub2_mkstandalone"
```

