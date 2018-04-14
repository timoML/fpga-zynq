#=======================================================================
# Modified Makefile from riscv-bmarks
#-----------------------------------------------------------------------
# original author: Yunsup Lee (yunsup@cs.berkeley.edu)
# Timo Joas (t.joas@berkeley.edu)
#
# Will always build a 32 bit binary. XLEN=64 indicates to use a 
# riscv64-unknown-elf toolchain by adding appropriate ABI flags.
#

XLEN ?= 32

default: all

src_dir = .


#--------------------------------------------------------------------
# Build rules
#--------------------------------------------------------------------

RISCV_PREFIX ?= riscv$(XLEN)-unknown-elf-
RISCV_GCC ?= $(RISCV_PREFIX)gcc
override RISCV_GCC_OPTS += -DPREALLOCATE=1 -mcmodel=medany -static -std=gnu99 -O2 -ffast-math -fno-common -fno-builtin-printf
RISCV_LINK ?= $(RISCV_GCC) -T $(src_dir)/test.ld $(incs)
RISCV_LINK_OPTS ?= -static -nostdlib -nostartfiles -lm -lgcc -T $(src_dir)/test.ld
RISCV_OBJDUMP ?= $(RISCV_PREFIX)objdump --disassemble-all --disassemble-zeroes --section=.text --section=.text.startup --section=.data

ifeq ($(XLEN),64)
override RISCV_GCC_OPTS += -mabi=ilp32 -march=rv32ima
endif

dtim.elf: $(wildcard $(src_dir)/*)
	$(RISCV_GCC) $(incs) $(RISCV_GCC_OPTS) -o $@ $(wildcard $(src_dir)/*.c) $(wildcard $(src_dir)/*.S) $(RISCV_LINK_OPTS)


#------------------------------------------------------------
# Default

all: dtim.elf



#------------------------------------------------------------
# Clean up

clean:
	rm -rf *.elf
