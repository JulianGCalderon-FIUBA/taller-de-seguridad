usage:
	@./usage.sh
.PHONY: usage

## Extract data.tar
data:
	tar -xf data.tar

data/%:
	@echo "missing: $@"
	@exit 1

build:
	@mkdir -p $@

build/owned.vdi: build data/owned.zip
	unzip -DD -o data/owned.zip -d build

## Extract owned.qcow2
owned.qcow2: build/owned.vdi
	qemu-img convert -f vdi -O qcow2 build/owned.vdi owned.qcow2

build/kali-x86-disk001.vmdk: build data/kali-x86.ova
	tar -mvxf data/kali-x86.ova -C build

## Extract kali-x86.qcow2
kali-x86.qcow2: build/kali-x86-disk001.vmdk
	qemu-img convert -f vmdk -O qcow2 build/kali-x86-disk001.vmdk kali-x86.qcow2

kali_efivars.fd:
	dd "of=$@" if=/dev/zero bs=1M count=64 >/dev/null 2>&1
.PRECIOUS: kali_efivars.fd

## Generate kali.qcow2 (aarch64)
kali.qcow2: data/kali-arm64.iso data/edk2-aarch64-code.fd kali_efivars.fd
	qemu-img create $@ 30G -f qcow2
	@./qemu.sh --img $@ \
		--qemu-m 8G --qemu-smp 8 \
		--cdroom data/kali-arm64.iso \
		--firmware data/edk2-aarch64-code.fd \
		--efivars kali_efivars.fd \
		--mac 12:3:45:67:89:1 \
		--serial 4444
.PRECIOUS: kali.qcow2

## Backup kali image
backup-kali: kali.qcow2 kali_efivars.fd
	zip backup.zip kali.qcow2 kali_efivars.fd
.PHONY: backup-kali
