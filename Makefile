.PHONY: all clean

ASFLAGS			=
CFREEFLAGS		= -std=gnu99 -ffreestanding -O2 -Wall -Wextra
CXXFREEFLAGS	= -std=c++14 -ffreestanding -O2 -Wall -Wextra -fno-exceptions -fno-rtti
ARCHITECTURE	= i386

SRC_DIR			= src
OBJS			= $(SRC_DIR)/obj
ARCH			= $(SRC_DIR)/arch/$(ARCHITECTURE)
COMMON_DIR		= $(SRC_DIR)/common
OUT_DIR			= out

CROSS_BIN		= cross/bin
CC				= $(CROSS_BIN)/i686-elf-gcc
CXX				= $(CROSS_BIN)/i686-elf-g++
AS				= $(CROSS_BIN)/i686-elf-as
QEMU			= qemu-system-i386

MKDIR_MSG		= " MKDIR	"
AS_MSG			= " AS	"
CC_MSG			= " CC	"
CXX_MSG			= " CXX	"
QEMU_MSG		= " QEMU	"
RM_MSG			= " RM	"
INFO_MSG		= " INFO	"
FAIL_MSG		= " FAIL	"

OUTPUT_NAME		= $(OUT_DIR)/myos.bin

all: dirs kernel test

dirs: obj_dir out_dir

obj_dir:
	@mkdir -p $(OBJS)
	@echo $(MKDIR_MSG) $(OBJS)

out_dir:
	@mkdir -p $(OUT_DIR)
	@echo $(MKDIR_MSG) $(OUT_DIR)

kernel:
	@$(AS) $(ARCH)/boot.s -o $(OBJS)/boot.o $(ASFLAGS)
	@echo $(AS_MSG) $(ARCH)/boot.s

	@$(CXX) -c $(COMMON_DIR)/kernel.cpp -o $(OBJS)/kernel.o $(CXXFREEFLAGS)
	@echo $(CXX_MSG) $(COMMON_DIR)/kernel.cpp

	@$(CC) -T $(ARCH)/linker.ld -o $(OUTPUT_NAME) -ffreestanding -O2 -nostdlib $(OBJS)/boot.o $(OBJS)/kernel.o -lgcc
	@echo $(CC_MSG) $(OBJS)/boot.o $(OBJS)/kernel.o

	@echo $(INFO_MSG) Finished. Kernel is at $(OUTPUT_NAME)

test:
	@grub-file --is-x86-multiboot $(OUTPUT_NAME) || (echo $(FAIL_MSG) grub-file $$?; exit 1)

clean:
	@rm -r $(OBJS)
	@echo $(RM_MSG) $(OBJS)/

	@rm -r $(OUT_DIR)
	@echo $(RM_MSG) $(OUT_DIR)/

qemu: all
	@$(QEMU) -kernel $(OUTPUT_NAME)
