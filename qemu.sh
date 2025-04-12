#!/bin/bash

set -e


#####################
# utility functions #
#####################

fail() {
	echo "$*" >&2
	exit 1
}

expect_value() {
	if [ -z "$2" ]; then
		fail "missing value for $1"
	else
		echo "$2"
	fi
}

print_command() {
	echo "$1"
	local partial=()
	for argument in "${@:2}"; do
		case $argument in -*)
			if [ ${#partial[@]} -ne 0 ]; then
				printf "  %s\n" "${partial[*]}"
			fi
			partial=()
		esac
		partial+=("$argument")
	done
	if [ ${#partial[@]} -ne 0 ]; then
		printf "  %s\n" "${partial[*]}"
	fi
}

################################
# parse command line arguments #
################################

OPT_ARCH="aarch64"
QEMU_M="1G"
QEMU_SMP="1"
OPT_GUI=false
OPT_VGA=false

while [ "$#" -ne 0 ] ; do
	case $1 in
		"--arch")
			OPT_ARCH=$(expect_value "$@")
			shift
			;;
		"--img")
			OPT_IMG=$(expect_value "$@")
			shift
			;;
		"--efivars")
			OPT_EFIVARS=$(expect_value "$@")
			shift
			;;
		"--firmware")
			OPT_FIRMWARE=$(expect_value "$@")
			shift
			;;
		"--cdroom")
			OPT_CDROOM=$(expect_value "$@")
			shift
			;;
		"--serial")
			OPT_SERIAL=$(expect_value "$@")
			shift
			;;
		"--gui")
			OPT_GUI=true
			;;
		"--vga")
			OPT_VGA=true
			;;
		"--mac")
			OPT_MAC=$(expect_value "$@")
			shift
			;;
		"--qemu-m")
			QEMU_M=$(expect_value "$@")
			shift
			;;
		"--qemu-smp")
			QEMU_SMP=$(expect_value "$@")
			shift
			;;
		*) break ;;
	esac
	shift
done

expect_value "--arch" "$OPT_ARCH" >/dev/null
expect_value "--img" "$OPT_IMG" >/dev/null
expect_value "--mac" "$OPT_MAC" >/dev/null
expect_value "--qemu-m" "$QEMU_M" >/dev/null
expect_value "--qemu-smp" "$QEMU_SMP" >/dev/null

if [ "$OPT_ARCH" = "aarch64" ]; then
	expect_value "--efivars" "$OPT_EFIVARS" >/dev/null
	expect_value "--firmware" "$OPT_FIRMWARE" >/dev/null
fi


##########################
# prepare qemu arguments #
##########################

case "$OPT_ARCH" in
	aarch64)
		QEMU_COMMAND=(
			qemu-system-aarch64
			-machine virt
			-accel hvf
			-cpu max
		)
		;;
	x86_64)
		QEMU_COMMAND=(
			qemu-system-x86_64
			-cpu max
		)
		;;
	*) fail "unsupported arch: $OPT_ARCH"
esac

QEMU_COMMAND+=(
	-hda "$OPT_IMG"
	-m "$QEMU_M"
	-smp "$QEMU_SMP"
	-nic "vmnet-bridged,ifname=en0,mac=$OPT_MAC"
	-nodefaults
)

if [ -n "$OPT_CDROOM" ]; then
	QEMU_COMMAND+=(
		-boot d -cdrom "$OPT_CDROOM"
	)
fi

if [ -n "$OPT_EFIVARS" ]; then
	QEMU_COMMAND+=(
		-drive "if=pflash,format=raw,unit=0,file=$OPT_FIRMWARE"
		-drive "if=pflash,format=raw,unit=1,file=$OPT_EFIVARS"
	)
fi

if [ -n "$OPT_SERIAL" ]; then
	QEMU_COMMAND+=(
		-serial "tcp::$OPT_SERIAL,server,nowait"
	)
fi

if [ "$OPT_GUI" = true ]; then
	QEMU_COMMAND+=(
		-nodefaults
		-device "nec-usb-xhci,id=usb-bus"
		-device "usb-tablet,bus=usb-bus.0"
		-device "usb-mouse,bus=usb-bus.0"
		-device "usb-kbd,bus=usb-bus.0"
		-device "virtio-gpu-pci"
	)
elif [ "$OPT_VGA" = true ]; then
	QEMU_COMMAND+=(
		-vga "std"
	)
else
	QEMU_COMMAND+=(
		-nodefaults
		-nographic
	)
fi


print_command "${QEMU_COMMAND[@]}" 
sudo "${QEMU_COMMAND[@]}"
