## This program is a part of a bigger project
## https://github.com/herzeleid02/squashlinux

# TODO: shorten the v_keya creation (just set it in main)
# TODO: create
# TODO: better error handler with output
# TODO: fix comp option (or disable it, lol)

#!/bin/bash

set -o errtrace

build_root="/tmp/iso-$(date +%d%m%Y)-$(tr -dc a-z </dev/urandom | head -c 4)"
chroot_dir=""
output_iso=""
v_keya=""
verbosity=0
arg_mode=0 # 0 == pass args as is; 1 == use options
comp_algo="gzip" # gzip should be default (can be zstd:15)
comp_level="" # not implemented yet
comp_command="" #
grub_make_command="grub-mkstandalone" # can also be "grub2_mkstandalone"

trap "failure_cleanup" 1 2 3 6
trap "failure_cleanup" ERR

function main(){
	while getopts "hvd:o:c:" option; do
	#while getopts ":h" option; do
		case $option in
			h) greeter_help
				exit;;
			v) verbosity=1;;
			d) chroot_dir=$(realpath $OPTARG)
				arg_mode=1;;
			o) output_iso=$(realpath $OPTARG)
				arg_mode=1;;
			c) comp_algo=$OPTARG;;
			\?) greeter_help;;
		esac
	done


	if [ $OPTIND -eq 1 ]; then
		#echo "no options" # debug
		assign_args "$@"
	elif [ $1 = "-v" ] && [ ${arg_mode} == 0 ]; then
		shift 1
		assign_args "$@"
	fi
	arg_parser "$@"

	init_flags
	check_chroot
	check_privileges
	check_dependencies
	check_grub_make_command

	parse_comp

	if [ ${verbosity} == 1 ]; then
		make_iso
	else
		make_iso &> /dev/null
	fi
	
	make_cleanup

}

function arg_parser(){
	if [ -z ${chroot_dir} ] || [ -z ${output_iso} ]; then
		greeter_help
	fi
}

function assign_args(){
		chroot_dir=$(realpath $1 2> /dev/null)
		output_iso=$(realpath $2 2> /dev/null)
}

function greeter_help(){
	echo "tool for building bootable iso image (WIP)"
	echo "Usage:"
	echo "$0 <options>"
	echo "$0 source output"
	echo "$0 -d source -o output"
	echo "$0 -v source output"
	echo "Options:"
	echo "-h	Show help"	
	echo "-v	Verbose output"
	echo "-d	Directory"
	echo "-o	Output filename"
	exit 1
}

function parse_comp(){
	comp_algos=(gzip xz lzo lz4 zstd lzma) ## TODO: add none
	#if [[ ${array[@]} =~ $value ]]

	if [[ ${comp_algo} == "none" ]]; then
		comp_command="-no-compression"
	elif [[ ! " ${comp_algos[@]} " =~ " ${comp_algo} " ]]; then
		echo "Compression algorithm ${comp_algo} is not supported"
		exit 1
	else
		comp_command="-comp ${comp_algo}"
	fi

	if [[ ${verbosity} == "1" ]]; then
		echo ${comp_algos[@]} #debug
		echo "compression algo -- ${comp_algo}" #debug
		echo "${comp_command}" #debug
	fi
}

function make_cleanup(){
	umount ${v_keya} -f ${build_root}/chroot
	rm ${v_keya} -rf ${build_root}
}

function failure_cleanup(){
	make_cleanup
	exit 1
}


function check_privileges() {
	if [[ "$EUID" -ne 0 ]]
  		then echo "Please run as root"
  	exit 1;
	fi
}

### the core functionality begins here



function init_flags(){
	if [ ${verbosity} == 1 ]; then
	v_keya="-v"
	#echo "$v_keya" # debug
	fi
}

function check_chroot(){
	if [ ! -e ${chroot_dir}/bin/sh ] || [ ! -e ${chroot_dir}/boot/vmlinuz ]; then
	echo "No /bin/sh or kernel image found, aborting..."
	exit 1
	fi
}

function check_dependencies(){
	if [ ! -x "$(command -v xorriso)" ] || [ ! -x "$(command -v mksquashfs)" ]; then
	echo "No xorriso or mksquashfs found, aborting..."
	exit 1
	fi
}

function check_grub_make_command(){
	if [ -x "$(command -v grub-mkstandalone)" ]; then 
		grub_make_command="grub-mkstandalone"
	elif [ -x "$(command -v grub2-mkstandalone)" ]; then
		grub_make_command="grub2-mkstandalone"
	else
		echo "No "grub-mkstandalone" or "grub2-mkstandalone" found, aborting..."
		exit 1
	fi
}

# the master nested function -- look below
function make_iso(){
	make_hierarchy
	make_squashfs
	copy_kernel
	boot_menu_grub
	boot_install_grub
	create_iso
}



### functions below are the main functionality of the script



function make_hierarchy(){
	### hacky solution -- i just link the chroot directory instead of rewriting the entire script
	#echo $build_root # debug
	#ln ${v_keya} -s "${chroot_dir}" "${build_root}/chroot" ## ln doesnt work here, u either mount or cp the directory :(
	### WHY cp -- its safer to first copy the chroot and then build the squashfs image: you can modify the OG chroot and it wont break (did cp)
	### WHY mount -- because... it could leave to lesser RAM usage
	### this thing is now redone with mount

	mkdir ${v_keya} -p ${build_root}/{chroot,staging/{EFI/BOOT,boot/grub/x86_64-efi,isolinux,live},tmp}
#	cp -r ${v_keya} ${chroot_dir} ${build_root}/chroot
	mount ${v_keya} --bind ${chroot_dir} ${build_root}/chroot

}

function make_squashfs(){
	mksquashfs \
    "${build_root}/chroot" \
    "${build_root}/staging/live/filesystem.squashfs" \
    -e boot \
    ${comp_command}

}

function copy_kernel(){
	cp ${v_keya} "${build_root}/chroot/boot"/vmlinuz* \
		"${build_root}/staging/live/" && \
	cp ${v_keya} "${build_root}/chroot/boot"/initrd* \
	"${build_root}/staging/live/"
}

function boot_menu_grub(){
cat <<'EOF' > "${build_root}/staging/boot/grub/grub.cfg"
insmod part_gpt
insmod part_msdos
insmod fat
insmod iso9660

insmod all_video
insmod font

set default="0"
set timeout=30

# If X has issues finding screens, experiment with/without nomodeset.

menuentry "Linux Live [EFI/GRUB]" {
    search --no-floppy --set=root --label DEBLIVE
    linux ($root)/live/vmlinuz boot=live
    initrd ($root)/live/initrd.img
}

menuentry "Linux Live [EFI/GRUB] (nomodeset)" {
    search --no-floppy --set=root --label DEBLIVE
    linux ($root)/live/vmlinuz boot=live nomodeset
    initrd ($root)/live/initrd.img
}
EOF
	cp ${v_keya} "${build_root}/staging/boot/grub/grub.cfg" "${build_root}/staging/EFI/BOOT/"

## something weird
cat <<'EOF' > "${build_root}/tmp/grub-embed.cfg"
if ! [ -d "$cmdpath" ]; then
    # On some firmware, GRUB has a wrong cmdpath when booted from an optical disc.
    # https://gitlab.archlinux.org/archlinux/archiso/-/issues/183
    if regexp --set=1:isodevice '^(\([^)]+\))\/?[Ee][Ff][Ii]\/[Bb][Oo][Oo][Tt]\/?$' "$cmdpath"; then
        cmdpath="${isodevice}/EFI/BOOT"
    fi
fi
configfile "${cmdpath}/grub.cfg"
EOF

}

function boot_install_grub(){
	# TODO: remove i386(?)
	${grub_make_command} -O i386-efi \
    --modules="linux search part_gpt part_msdos fat iso9660" \
    --locales="" \
    --themes="" \
    --fonts="" \
    --output="${build_root}/staging/EFI/BOOT/BOOTIA32.EFI" \
    "boot/grub/grub.cfg=${build_root}/tmp/grub-embed.cfg"
	${grub_make_command} -O x86_64-efi \
    --modules="linux search part_gpt part_msdos fat iso9660" \
    --locales="" \
    --themes="" \
    --fonts="" \
    --output="${build_root}/staging/EFI/BOOT/BOOTx64.EFI" \
    "boot/grub/grub.cfg=${build_root}/tmp/grub-embed.cfg"

	# TODO: change `cd` to something more graceful
	(cd "${build_root}/staging" && \
    dd if=/dev/zero of=efiboot.img bs=1M count=20 && \
    mkfs.vfat efiboot.img && \
    mmd -i efiboot.img ::/EFI ::/EFI/BOOT && \
    mcopy -vi efiboot.img \
        "${build_root}/staging/EFI/BOOT/BOOTIA32.EFI" \
        "${build_root}/staging/EFI/BOOT/BOOTx64.EFI" \
        "${build_root}/staging/boot/grub/grub.cfg" \
        ::/EFI/BOOT/
)

	# grub bios
	${grub_make_command} \
    --format=i386-pc \
    --install-modules="linux normal iso9660 biosdisk memdisk search tar ls" \
    --modules="linux normal iso9660 biosdisk search" \
    --locales="" \
    --fonts="" \
    --output="${build_root}/staging/grub-bios-core.img" \
    "boot/grub/grub.cfg=${build_root}/staging/boot/grub/grub.cfg"

cat \
    /usr/lib/grub/i386-pc/cdboot.img \
    ${build_root}/staging/grub-bios-core.img \
> ${build_root}/staging/bios.img 
	rm ${v_keya} "${build_root}/staging/grub-bios-core.img"
}

function create_iso(){
	xorriso \
    -as mkisofs \
    -iso-level 3 \
    -full-iso9660-filenames \
    -volid "DEBLIVE" \
    -eltorito-boot \
        boot/grub/bios.img \
        -no-emul-boot \
        -boot-load-size 4 \
        -boot-info-table \
        --eltorito-catalog boot/grub/boot.cat \
    --grub2-boot-info \
    --grub2-mbr /usr/lib/grub/i386-pc/boot_hybrid.img \
    -eltorito-alt-boot \
        -e EFI/efiboot.img \
        -no-emul-boot \
    -append_partition 2 0xef ${build_root}/staging/efiboot.img \
    -output "${output_iso}" \
    -graft-points \
        "${build_root}/staging" \
        /boot/grub/bios.img=${build_root}/staging/bios.img \
        /EFI/efiboot.img=${build_root}/staging/efiboot.img
}

    #-append_partition 2 C12A7328-F81F-11D2-BA4B-00A0C93EC93B ${build_root}/staging/efiboot.img \
    # i replaced big EFI GUID to this `0xEF` thing (old xorriso hack, newer xorriso builds work just fine) (the older page had this too, apparently)


main "$@"
