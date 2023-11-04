## Build a fedora-coreos SD card for Raspberry Pis
EFI_VERSION      ?= 1.34
FIRMWARE_VERSION ?= 1.20230405

COREOS_STREAM ?= stable
COREOS_ARCH   ?= aarch64
IGNITION_URL  ?= https://jmanero.github.io/ignition-config/pi.ign.json

CACHE += .cache/RPi4_UEFI_Firmware_v$(EFI_VERSION).zip
CACHE += .cache/firmware-$(FIRMWARE_VERSION).tar.gz
CACHE += .cache/fedora-coreos.txt

.PHONY: cache
cache: $(CACHE)

.PHONY: install
install: $(CACHE)
ifndef DEVICE
	$(error install bust be invoked with a DEVICE variable; e.g. make install DEVICE=/dev/sdb)
endif

	-umount $(DEVICE)[[:digit:]]
	wipefs -a $(DEVICE)

	coreos-installer install --image-file $(shell cat .cache/fedora-coreos.txt) --ignition-url $(IGNITION_URL) $(DEVICE)
	
	-partx -a $(DEVICE)
	mkdir -p mnt/boot/efi
	mount $(DEVICE)2 mnt/boot/efi
	
	unzip -o -d mnt/boot/efi/ .cache/RPi4_UEFI_Firmware_v$(EFI_VERSION).zip
	tar --strip-components 2 -xvzf .cache/firmware-$(FIRMWARE_VERSION).tar.gz -C mnt/boot/efi 'firmware-$(FIRMWARE_VERSION)/boot/overlays/*' firmware-$(FIRMWARE_VERSION)/boot/bcm2711-rpi-4-b.dtb
	cp efi-$(EFI_VERSION)/* mnt/boot/efi/

	umount mnt/boot/efi

.PHONY: clean
clean:
ifdef DEVICE
	-umount $(DEVICE)[[:digit:]]
endif
	rm -rf mnt

.PHONY: clobber
clobber: clean
	rm -rf .cache

.cache/RPi4_UEFI_Firmware_v$(EFI_VERSION).zip:
	mkdir -p $(@D)
	curl -L -o $@ https://github.com/pftf/RPi4/releases/download/v$(EFI_VERSION)/RPi4_UEFI_Firmware_v$(EFI_VERSION).zip
	unzip -v $@

.cache/firmware-$(FIRMWARE_VERSION).tar.gz:
	mkdir -p $(@D)
	curl -L -o $@ https://github.com/raspberrypi/firmware/archive/refs/tags/$(FIRMWARE_VERSION).tar.gz
	tar -tvzf $@

.cache/fedora-coreos.txt:
	mkdir -p $(@D)
	coreos-installer download --directory $(@D) --platform metal --architecture $(COREOS_ARCH) --stream $(COREOS_STREAM) > $@
