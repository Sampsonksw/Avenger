#
# Makefile
# ske,2021-07-01
#
NOVAS = ${NOVAS_HOME}/share/PLI/VCS/LINUX64
VCS_OPTS := -full64 -R -Mupdate +v2k -timescale="1ns/10ps" -sverilog -debug_all
VCS_OPTS += +libext+.v+.sv+.vh+.svh+
VCS_OPTS += -P ${NOVAS}/novas.tab ${NOVAS}/pli.a
#VCS_OPTS += -P ${LD_LIBRARY_PATH}/novas.tab  ${LD_LIBRARY_PATH}/pli.a

VERDI_OPTS+= -sverilog +v2k
#VERDI_OPTS+= +libext+.v+.sv+.vh+.svh+

#RISCV_TEST = $(TOP)/core/milano/tests
RISCV_TEST_DIR = $(TOP)/core/milano/tests/base-isa-old/generated
RISCV_TEST_NAME =$(patsubst %.elf,%, $(notdir $(wildcard $(TOP)/core/milano/tests/base-isa-old/generated/*.elf)))
RISCV_VMEM_FILE =$(patsubst %.elf,%.vmem, $(notdir $(wildcard $(TOP)/core/milano/tests/base-isa-old/generated/*.elf))) 
export casename

#vpath %.vmem $(RISCV_TEST_DIR)

debug:
	@echo $(RISCV_VMEM_FILE)
all: run
	@echo "Makefile attention"

#comp:
#	vcs  \
#			$(VCS_OPTS) \
#			-f $(TOP)/tb/tb.f \
#			-top tb \
#			-l comp.log
comp:
		vcs  \
			  $(VCS_OPTS) \
              -f $(TOP)/tb/tb.f \
			  -top testbench \
			  -l comp.log

run: comp
	./simv -l ./logs/$(casename).log +casename=$(casename)

riscv_test: comp $(RISCV_VMEM_FILE)

%:
	cp $(RISCV_TEST_DIR)/$@ ./test.vmem
	./simv -l ./logs/$(subst .vmem,,$@).log +casename=$(subst .vmem,,$@)
	cp $(RISCV_TEST_DIR)/$(subst .vmem,.dump,$@) ./logs/

verdi:
	verdi $(VERDI_OPTS) \
		-f $(TOP)/tb/tb.f \
		-top testbench \
		-ssf testbench.fsdb \
		-nologo &
clean:
	rm -rf *.log simv* *.fsdb csrc ucli.key logs/*
# vim:ft=make
#

