# SLeOS — Sierra Leone OS
## A Minimal Bootable Operating System Prototype
### Limkokwing University of Creative Technology, Sierra Leone
**COMP 323 – Operating Systems | Group Project (25%)**

---

## 📋 Project Overview

SLeOS is a custom operating system kernel built in C and x86 Assembly, emulated via QEMU.
It demonstrates core OS components and addresses local computing challenges in Sierra Leone
such as low-resource computing, education access, and digital inclusion.

---

## 🏗️ Project Structure

```
sleos/
├── boot/
│   └── boot.asm          ← GRUB Multiboot bootloader (Assembly)
├── kernel/
│   ├── kernel.c          ← Kernel main entry point
│   ├── scheduler.c       ← Process Scheduler (FCFS + Round Robin)
│   └── memory.c          ← Memory Manager (Paging Simulator)
├── drivers/
│   ├── vga.c             ← VGA text mode display driver
│   └── keyboard.c        ← PS/2 keyboard driver (polling)
├── fs/
│   └── fs.c              ← In-memory file system
├── shell/
│   └── shell.c           ← Interactive command shell
├── include/
│   ├── types.h           ← Bare-metal type definitions
│   ├── vga.h
│   ├── keyboard.h
│   ├── scheduler.h
│   ├── memory.h
│   ├── fs.h
│   └── shell.h
├── linker.ld             ← Linker script (load at 0x100000)
└── Makefile              ← Build system
```

---

## ⚙️ Prerequisites

### On Ubuntu/Debian:
```bash
# 1. Install QEMU
sudo apt-get install qemu-system-x86

# 2. Install cross-compiler (REQUIRED for bare-metal x86)
sudo apt-get install gcc-multilib nasm

# 3. For i686-elf-gcc (recommended):
# Option A - use xPack toolchain:
sudo apt-get install wget xz-utils
wget https://github.com/xpack-dev-tools/i686-elf-gcc-xpack/releases/download/v13.2.0-1/xpack-i686-elf-gcc-13.2.0-1-linux-x64.tar.gz
tar -xf xpack-i686-elf-gcc-*.tar.gz
export PATH=$PATH:$(pwd)/xpack-i686-elf-gcc-*/bin

# Option B - build from source (OSDev wiki method):
# https://wiki.osdev.org/GCC_Cross-Compiler
```

### On macOS (with Homebrew):
```bash
brew install qemu nasm
brew install i686-elf-gcc  # or build cross-compiler
```

### On Windows:
- Use WSL2 (Ubuntu) and follow the Ubuntu steps above.

---

## 🔨 Build

```bash
cd sleos

# Build kernel ELF + raw disk image
make

# Or with explicit target
make all
```

This produces:
- `sleos.elf` — ELF kernel binary
- `sleos.img` — Raw flat binary disk image

---

## 🚀 Run (QEMU)

### Method 1: Direct kernel boot (easiest — no bootloader setup needed)
```bash
make run-elf
# or manually:
qemu-system-x86_64 -kernel sleos.elf -m 32M
```

### Method 2: Raw disk image
```bash
make run
# or manually:
qemu-system-x86_64 -drive file=sleos.img,format=raw -m 32M
```

### Method 3: GRUB ISO
```bash
make iso
make run-iso
```

### Debug mode (GDB attached):
```bash
make debug
```

---

## 🖥️ Shell Commands

Once SLeOS boots, you'll see the interactive shell:

```
sleos@limkokwing:~$
```

| Command          | Description                          |
|------------------|--------------------------------------|
| `help`           | Show all commands                    |
| `about`          | About SLeOS                          |
| `clear`          | Clear screen                         |
| `ps`             | Show process table                   |
| `sched-fcfs`     | Run FCFS scheduler demo              |
| `sched-rr`       | Run Round Robin scheduler demo       |
| `mem`            | Show memory map + stats              |
| `mem-demo`       | Run memory manager demo              |
| `ls`             | List files                           |
| `cat <file>`     | Print file contents                  |
| `create <file>`  | Create a new file                    |
| `write <f> <t>`  | Write text to file                   |
| `del <file>`     | Delete a file                        |
| `reboot`         | Halt the system                      |

---

## 🧠 OS Components

### 1. Bootloader (`boot/boot.asm`)
- GRUB Multiboot 1 compliant
- Sets up 16 KB stack
- Calls `kernel_main()` in C

### 2. VGA Driver (`drivers/vga.c`)
- Writes directly to VGA memory at `0xB8000`
- 80×25 text mode
- 16 color support, scrolling, cursor management

### 3. Keyboard Driver (`drivers/keyboard.c`)
- Polling-based PS/2 keyboard input
- US QWERTY scancode mapping
- Shift key support

### 4. Process Scheduler (`kernel/scheduler.c`)
- **FCFS**: Non-preemptive, arrival-ordered
- **Round Robin**: Preemptive, TIME_QUANTUM = 3 ticks
- Calculates waiting time and turnaround time
- Visual context-switch output

### 5. Memory Manager (`kernel/memory.c`)
- 64 page frames × 4 KB = 256 KB simulated RAM
- First-fit contiguous page allocator
- Bitmap-based free/used tracking
- Visual ASCII memory map

### 6. File System (`fs/fs.c`)
- Flat in-memory filesystem
- 16 files max, 512 bytes each
- Operations: create, read, write, delete, list

### 7. Shell (`shell/shell.c`)
- Interactive command-line interpreter
- Command parsing with argument support
- Colored prompt: `sleos@limkokwing:~$`

---

## 🌍 SDG Relevance

- **SDG 4 (Quality Education)**: Demonstrates OS fundamentals for students
- **SDG 9 (Industry & Innovation)**: Local tech innovation in Sierra Leone
- **SDG 10 (Reduced Inequalities)**: Low-resource computing solutions
- **SDG 17 (Partnerships)**: Open-source, reproducible educational tool

---

## 📄 License

MIT License — Open Source

---

## 👥 Team

Limkokwing University of Creative Technology  
Faculty of Information and Communication Technology  
COMP 323 — Operating Systems | March–July 2026
