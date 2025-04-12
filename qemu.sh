#!/bin/bash
# shellcheck disable=SC2086,SC2206,SC2054

set -e


#####################
# utility functions #
#####################

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
		partial+=($argument)
	done
	if [ ${#partial[@]} -ne 0 ]; then
		printf "  %s\n" "${partial[*]}"
	fi
}

################################
# parse command line arguments #
################################

expect_value() {
	if [ -z "$2" ]; then
		echo "missing value for $1" >&2
		exit 1
	else
		echo "$2"
	fi
}

QEMU_M="1G"
QEMU_SMP="1"

while [ "$#" -ne 0 ] ; do
	case $1 in
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

expect_value "--img" "$OPT_IMG" >/dev/null
expect_value "--mac" "$OPT_MAC" >/dev/null
expect_value "--qemu-m" "$QEMU_M" >/dev/null
expect_value "--qemu-smp" "$QEMU_SMP" >/dev/null
expect_value "--efivars" "$OPT_EFIVARS" >/dev/null
expect_value "--firmware" "$OPT_FIRMWARE" >/dev/null


##########################
# prepare qemu arguments #
##########################

QEMU_COMMAND=(
	qemu-system-aarch64
	-hda $OPT_IMG
	-machine virt
	-accel hvf
	-cpu max
	-m "$QEMU_M"
	-smp "$QEMU_SMP"
	-nic vmnet-bridged,ifname=en0,mac=$OPT_MAC
)

if [ -n "$OPT_CDROOM" ]; then
	QEMU_COMMAND+=(
		-boot d -cdrom $OPT_CDROOM
	)
fi

if [ -n "$OPT_EFIVARS" ]; then
	QEMU_COMMAND+=(
		-drive if=pflash,format=raw,unit=0,file=$OPT_FIRMWARE
		-drive if=pflash,format=raw,unit=1,file=$OPT_EFIVARS
	)
fi

if [ -n "$OPT_SERIAL" ]; then
	QEMU_COMMAND+=(
		-serial tcp::$OPT_SERIAL,server,nowait \
	)
fi

QEMU_COMMAND+=(
	-nodefaults -nographic
)

print_command "${QEMU_COMMAND[@]}" 
sudo "${QEMU_COMMAND[@]}"
