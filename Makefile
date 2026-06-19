# ============================================================
# SLeOS - Makefile
# Sierra Leone OS Build System
# ============================================================

# ---- Toolchain ----
CC      = i686-elf-gcc
AS      = nasm
LD      = i686-elf-gcc

# If i686-elf-gcc not available, fall back to standard gcc with flags
# CC    = gcc
# LD    = gcc

# ---- Flags ----
CFLAGS  = -m32 \
          -std=gnu99 \
          -ffreestanding \
          -fno-stack-protector \
          -fno-builtin \
          -nostdlib \
          -nostdinc \
          -Wall \
          -Wextra \
          -O2 \
          -Iinclude

ASFLAGS = -f elf32

LDFLAGS = -m32 \
          -ffreestanding \
          -nostdlib \
          -T linker.ld

# ---- Output ----
TARGET  = sleos.img
KERNEL  = sleos.elf

# ---- Source Files ----
C_SOURCES = kernel/kernel.c     \
            kernel/scheduler.c  \
            kernel/memory.c     \
            drivers/vga.c       \
            drivers/keyboard.c  \
            fs/fs.c             \
            shell/shell.c

ASM_SOURCES = boot/boot.asm

# ---- Object Files ----
C_OBJECTS   = $(C_SOURCES:.c=.o)
ASM_OBJECTS = $(ASM_SOURCES:.asm=.o)
ALL_OBJECTS = $(ASM_OBJECTS) $(C_OBJECTS)

# ============================================================
# Default target: build kernel ELF and flat binary image
# ============================================================
all: $(TARGET)
	@echo ""
	@echo "=================================================="
	@echo " SLeOS build complete!"
	@echo " Run with: qemu-system-x86_64 -drive file=$(TARGET),format=raw"
	@echo "=================================================="

# ---- Link ----
$(KERNEL): $(ALL_OBJECTS)
	$(LD) $(LDFLAGS) -o $@ $(ALL_OBJECTS) -lgcc
	@echo "[LINK] $@"

# ---- Create flat binary image (raw disk image) ----
$(TARGET): $(KERNEL)
	objcopy -O binary $(KERNEL) $@
	@echo "[IMG ] $@"

# ---- Compile C files ----
%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@
	@echo "[CC  ] $<"

# ---- Assemble ASM files ----
%.o: %.asm
	$(AS) $(ASFLAGS) $< -o $@
	@echo "[ASM ] $<"

# ============================================================
# GRUB-based ISO (alternative boot method)
# ============================================================
iso: $(KERNEL)
	mkdir -p iso/boot/grub
	cp $(KERNEL) iso/boot/sleos.elf
	echo 'set timeout=0'            > iso/boot/grub/grub.cfg
	echo 'set default=0'           >> iso/boot/grub/grub.cfg
	echo 'menuentry "SLeOS" {'     >> iso/boot/grub/grub.cfg
	echo '  multiboot /boot/sleos.elf' >> iso/boot/grub/grub.cfg
	echo '  boot'                  >> iso/boot/grub/grub.cfg
	echo '}'                       >> iso/boot/grub/grub.cfg
	grub-mkrescue -o sleos.iso iso
	@echo "[ISO ] sleos.iso ready"

# ============================================================
# Run targets
# ============================================================

# Run raw image
run: $(TARGET)
	qemu-system-x86_64 -drive file=$(TARGET),format=raw -m 32M

# Run ELF directly via multiboot
run-elf: $(KERNEL)
	qemu-system-x86_64 -kernel $(KERNEL) -m 32M

# Run ISO
run-iso: sleos.iso
	qemu-system-x86_64 -cdrom sleos.iso -m 32M

# Debug mode (opens GDB server on port 1234)
debug: $(KERNEL)
	qemu-system-x86_64 -kernel $(KERNEL) -m 32M -s -S &
	gdb $(KERNEL) -ex "target remote :1234"

# ============================================================
# Utility
# ============================================================
clean:
	@rm -f $(ALL_OBJECTS) $(KERNEL) $(TARGET)
	@rm -rf iso sleos.iso
	@echo "[CLEAN] Done"

info:
	@echo "CC      = $(CC)"
	@echo "CFLAGS  = $(CFLAGS)"
	@echo "Sources = $(C_SOURCES) $(ASM_SOURCES)"

.PHONY: all clean run run-elf run-iso debug iso info
