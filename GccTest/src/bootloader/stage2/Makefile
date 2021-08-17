BUILD_DIR?=build/
ASM?=nasm
ASMFLAGS?=-f elf32
CC?=gcc
CFLAGS?=-ffreestanding -nostdlib -std=c99
LINK?=gcc
LINKFLAGS?=-T script.ld -nostdlib
LINKLIBS=-lgcc

SOURCES_C=$(wildcard *.c)
SOURCES_ASM=$(wildcard *.asm)
OBJECTS_C=$(patsubst %.c, $(BUILD_DIR)/stage2/c/%.o, $(SOURCES_C))
OBJECTS_ASM=$(patsubst %.asm, $(BUILD_DIR)/stage2/asm/%.o, $(SOURCES_ASM))

.PHONY: all stage2 clean always

all: stage2

stage2: $(BUILD_DIR)/stage2.bin

$(BUILD_DIR)/stage2.bin: $(OBJECTS_ASM) $(OBJECTS_C)
	$(LINK) $(LINKFLAGS) -Wl,-Map $(BUILD_DIR)/stage2.map -o $@ $^ $(LINKLIBS)

$(BUILD_DIR)/stage2/c/%.o: %.c always
	$(CC) $(CFLAGS) -c -o $@ $<

$(BUILD_DIR)/stage2/asm/%.o: %.asm always
	$(ASM) $(ASMFLAGS) -o $@ $<

always:
	mkdir -p $(BUILD_DIR)/stage2/c
	mkdir -p $(BUILD_DIR)/stage2/asm

clean:
	rm -f $(BUILD_DIR)/stage2.bin