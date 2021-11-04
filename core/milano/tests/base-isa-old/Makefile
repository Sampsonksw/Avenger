#=======================================================================
# Makefile for riscv-tests/isa
#-----------------------------------------------------------------------

XLEN := 32

src_dir := .

include $(src_dir)/rv32ui/Makefrag
include $(src_dir)/rv32um/Makefrag

default: all

#--------------------------------------------------------------------
# Build rules
#--------------------------------------------------------------------

RISCV_PREFIX ?= riscv32-unknown-elf-
RISCV_GCC ?= $(RISCV_PREFIX)gcc
RISCV_GCC_OPTS ?= -static -mcmodel=medany -fvisibility=hidden -nostdlib -nostartfiles
RISCV_OBJDUMP ?= $(RISCV_PREFIX)objdump --disassemble-all
RISCV_OBJCOPY ?= $(RISCV_PREFIX)objcopy

OUTDIR = ./generated

vpath %.S $(src_dir)

#------------------------------------------------------------
# Build assembly tests

%.dump: % 
	$(RISCV_OBJDUMP) generated/$<.elf > generated/$@
	$(RISCV_OBJCOPY) -O binary generated/$<.elf   generated/$<.bin
	@xxd -l 0x10000 -g 4 -c 4 $(OUTDIR)/$<.bin  > $(OUTDIR)/$<.hex
	@perl  -ne 'if(/:\s(..)(..)(..)(..)\s/){printf("%s%s%s%s\n",  $$4,$$3,$$2,$$1)}' \
	$(OUTDIR)/$<.hex > $(OUTDIR)/$<.vmem

define compile_template

$$($(1)_p_tests): $(1)-p-%: $(1)/%.S
	$$(RISCV_GCC) $(2) $$(RISCV_GCC_OPTS) -I$(src_dir) -T$(src_dir)/link.ld $$< -o generated/$$@.elf
$(1)_tests += $$($(1)_p_tests)

$(1)_tests_dump = $$(addsuffix .dump, $$($(1)_tests))

$(1): $$($(1)_tests_dump)

.PHONY: $(1)

tests += $$($(1)_tests)

endef

$(eval $(call compile_template,rv32ui,-march=rv32i -mabi=ilp32))
$(eval $(call compile_template,rv32um,-march=rv32im -mabi=ilp32))


#tests_verilog = $(addsuffix .verilog, $(tests))
tests_dump = $(addsuffix .dump, $(tests))


#------------------------------------------------------------
# Default

all: $(tests_dump)
	
clean:
	rm -rf generated/*

