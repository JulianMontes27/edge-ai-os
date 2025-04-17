# Toolchain prefix (adjust if your toolchain is named differently)
PREFIX = arm-none-eabi-

# Tools
CC = $(PREFIX)gcc
AS = $(PREFIX)as
LD = $(PREFIX)ld
OC = $(PREFIX)objcopy
OD = $(PREFIX)objdump

# Project name
TARGET = kernel

# Source files
SRC_S = startup.s
SRC_C = main.c

# Object files
OBJ_S = $(SRC_S:.s=.o)
OBJ_C = $(SRC_C:.c=.o)
OBJS = $(OBJ_S) $(OBJ_C)

# Output files
ELF = $(TARGET).elf
BIN = $(TARGET).bin
LST = $(TARGET).lst

# Linker script
LDSCRIPT = linker.ld

# CPU specific flags (used by C compiler, assembler)
CPU_FLAGS = -mcpu=cortex-m3 -mthumb

# C Compiler flags (for .c files)
CFLAGS = $(CPU_FLAGS) -Wall -Wextra -nostdlib -ffreestanding -g -O0

# Assembler flags (for .s files)
ASFLAGS = $(CPU_FLAGS) -g

# Linker specific flags (passed via gcc driver)
# -T $(LDSCRIPT): Use our linker script.
# -nostdlib: Prevent linking standard C libraries and startup files.
LDFLAGS = -T $(LDSCRIPT) -nostdlib

# Default target
all: $(BIN) $(LST)

# Rule to link the ELF executable (Using GCC as the driver)
# This approach is better than calling the linker directly because GCC knows how to correctly link code compiled with specific CPU and architecture flags, ensuring compatibility between all parts of your code.
$(ELF): $(OBJS) $(LDSCRIPT)
	# Use gcc to link. It calls ld internally with appropriate flags,
	# potentially including libgcc if needed by compiler intrinsics,
	# while respecting -nostdlib regarding libc and standard startup files.
	# Pass CFLAGS as well so gcc knows the target CPU during linking.
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $(OBJS)
	@echo "LD (via CC) $@"

# Rule to convert ELF to raw binary
$(BIN): $(ELF)
	$(OC) -O binary $< $@
	@echo "OC   $@"

# Rule to generate listing file (optional, but useful)
$(LST): $(ELF)
	$(OD) -D $< > $@
	@echo "OD   $@"

# Rule to compile C files (Uses CFLAGS)
%.o: %.c Makefile
	$(CC) $(CFLAGS) -c $< -o $@
	@echo "CC   $<"

# Rule to assemble assembly files (Uses ASFLAGS)
%.o: %.s Makefile
	$(AS) $(ASFLAGS) $< -o $@
	@echo "AS   $<"

# Clean rule
clean:
	rm -f $(OBJS) $(ELF) $(BIN) $(LST)
	@echo "Cleaned build files."

# QEMU rule to run the kernel
qemu: $(BIN)
	qemu-system-arm -M lm3s6965evb -kernel $(BIN) -nographic

# QEMU debug rule
qemu-debug: $(BIN)
	qemu-system-arm -M lm3s6965evb -kernel $(BIN) -nographic -serial stdio -S -gdb tcp::1234

# Phony targets
.PHONY: all clean qemu qemu-debug