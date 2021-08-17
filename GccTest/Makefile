TOOLCHAIN_BIN=$(TOOLCHAIN)/bin
TOOLCHAIN_PREFIX?=i686-elf

export ASM=nasm
export CC=$(TOOLCHAIN_BIN)/$(TOOLCHAIN_PREFIX)-gcc
export LINK=$(TOOLCHAIN_BIN)/$(TOOLCHAIN_PREFIX)-gcc

export SRC_DIR=src
export TOOLS_DIR=tools
export BUILD_DIR=build

.PHONY: all floppy_image kernel bootloader clean always tools_fat run debug

all: floppy_image

#
# Floppy image
#
floppy_image: $(BUILD_DIR)/main_floppy.img

$(BUILD_DIR)/main_floppy.img: bootloader kernel
	echo "Building image..."
	dd if=/dev/zero of=$(BUILD_DIR)/main_floppy.img bs=512 count=2880 status=none
	mkfs.fat -F 12 -n "NBOS" $(BUILD_DIR)/main_floppy.img
	dd if=$(BUILD_DIR)/stage1.bin of=$(BUILD_DIR)/main_floppy.img conv=notrunc status=none
	mcopy -i $(BUILD_DIR)/main_floppy.img -mv $(BUILD_DIR)/stage2.bin "::stage2.bin"
	mcopy -i $(BUILD_DIR)/main_floppy.img -mv $(BUILD_DIR)/kernel.bin "::kernel.bin"
	mcopy -i $(BUILD_DIR)/main_floppy.img -smv image/* "::"

#
# Bootloader
#
bootloader: stage1 stage2

stage1: $(BUILD_DIR)/stage1.bin

$(BUILD_DIR)/stage1.bin: always
	$(MAKE) -C $(SRC_DIR)/bootloader/stage1 BUILD_DIR=$(abspath $(BUILD_DIR))

stage2: $(BUILD_DIR)/stage2.bin

$(BUILD_DIR)/stage2.bin: always
	$(MAKE) -C $(SRC_DIR)/bootloader/stage2 BUILD_DIR=$(abspath $(BUILD_DIR))

#
# Kernel
#
kernel: $(BUILD_DIR)/kernel.bin

$(BUILD_DIR)/kernel.bin: always
	$(MAKE) -C $(SRC_DIR)/kernel BUILD_DIR=$(abspath $(BUILD_DIR))

#
# Always
#
always:
	mkdir -p $(BUILD_DIR)

#
# Clean
#
clean:
	$(MAKE) -C $(SRC_DIR)/bootloader/stage1 BUILD_DIR=$(abspath $(BUILD_DIR)) clean
	$(MAKE) -C $(SRC_DIR)/bootloader/stage2 BUILD_DIR=$(abspath $(BUILD_DIR)) clean
	$(MAKE) -C $(SRC_DIR)/kernel BUILD_DIR=$(abspath $(BUILD_DIR)) clean
	rm -rf $(BUILD_DIR)/*

#
# Run
#
run:
	qemu-system-i386 -fda $(BUILD_DIR)/main_floppy.img

#
# Debug
#
debug:
	bochs -f bochs_config