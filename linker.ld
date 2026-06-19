/* ============================================================
 * SLeOS - linker.ld
 * Linker Script for x86 bare-metal kernel
 * Kernel loads at 1 MB (0x100000), standard for PC boot
 * ============================================================ */

ENTRY(_start)

SECTIONS {
    /* Load at 1 MB */
    . = 0x100000;

    /* Multiboot header must be in first 8 KB */
    .multiboot ALIGN(4) : {
        *(.multiboot)
    }

    /* Executable code */
    .text ALIGN(4096) : {
        *(.text)
    }

    /* Read-only data (strings, constants) */
    .rodata ALIGN(4096) : {
        *(.rodata)
    }

    /* Initialized data */
    .data ALIGN(4096) : {
        *(.data)
    }

    /* Uninitialized data (zero-initialized at boot) */
    .bss ALIGN(4096) : {
        *(COMMON)
        *(.bss)
    }

    /* End marker for heap calculation */
    kernel_end = .;
}
