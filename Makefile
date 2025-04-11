usage:
	@./usage.sh
.PHONY: usage

## Extract data.tar
data:
	tar -xf data.tar

build:
	@mkdir -p $@

build/owned.vdi: build data/owned.zip
	unzip -DD -o data/owned.zip -d build

## Extract owned.qcow2
owned.qcow2: build/owned.vdi
	qemu-img convert -f vdi -O qcow2 build/owned.vdi owned.qcow2
