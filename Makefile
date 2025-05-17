usage:
	@./usage.sh
.PHONY: usage


############
# COMMANDS #
############

## Generate kali.qcow2 (aarch64)
generate-kali: data/kali-arm64.iso data/edk2-aarch64-code.fd
	dd "of=kali-efivars.fd" if=/dev/zero bs=1M count=64 >/dev/null 2>&1
	qemu-img create kali.qcow2 30G -f qcow2
	@./qemu.sh --img $@ \
		--qemu-m 8G --qemu-smp 8 \
		--cdroom data/kali-arm64.iso \
		--firmware data/edk2-aarch64-code.fd \
		--efivars kali-efivars.fd \
		--mac 12:3:45:67:89:1 \
		--serial 4444
.PHONY: generate-kali

## Backup kali image
backup-kali:
	zip backup.zip kali.qcow2 kali-efivars.fd
.PHONY: backup-kali

## Run kali image
run-kali:
	@./qemu.sh --img kali.qcow2 \
		--qemu-m 8G --qemu-smp 8 \
		--firmware data/edk2-aarch64-code.fd \
		--efivars kali-efivars.fd \
		--mac 12:3:45:67:89:1 \
		--serial 4444 \
		--gui
.PHONY: run-kali

## Run owned image
run-owned: owned.qcow2
	@./qemu.sh --img owned.qcow2 \
		--arch x86_64 \
		--qemu-m 1G --qemu-smp 1 \
		--mac 12:3:45:67:89:2 \
		--vga
.PHONY: run-owned

## Run metasploitable image
run-metasploitable: metasploitable.qcow2
	@./qemu.sh --img metasploitable.qcow2 \
		--arch x86_64 \
		--qemu-m 1G --qemu-smp 1 \
		--mac 12:3:45:67:89:3 \
		--vga
.PHONY: run-owned

run-xyz: xyz.qcow2
	@./qemu.sh --img xyz.qcow2 \
		--arch x86_64 \
		--qemu-m 8G --qemu-smp 8 \
		--mac 12:3:45:67:89:4 \
		--vga
.PHONY: xyz

## Connect to serial port
serial:
	socat -,rawer tcp:localhost:4444,forever
.PHONY: serial

#################
# INTERMEDIATES #
#################
	
data/%:
	@echo "missing: $@"
	@exit 1

build:
	@mkdir -p $@

build/owned.vdi: build data/owned.zip
	unzip -DD -o data/owned.zip -d build

build/kali-x86-disk001.vmdk: build data/kali-x86.ova
	tar -mvxf data/kali-x86.ova -C build

build/xyz-disk001.vmdk: build data/xyz.ova
	tar -mvxf data/xyz.ova -C build

owned.qcow2: build/owned.vdi
	qemu-img convert -f vdi -O qcow2 build/owned.vdi owned.qcow2

xyz.qcow2: build/xyz-disk001.vmdk
	qemu-img convert -f vmdk -O qcow2 build/xyz-disk001.vmdk xyz.qcow2

metasploitable.qcow2: data/metasploitable.vmdk
	qemu-img convert -f vmdk -O qcow2 data/metasploitable.vmdk metasploitable.qcow2
