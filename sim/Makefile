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

all:run
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

run:comp
	./simv -l sim.log

verdi:
	verdi $(VERDI_OPTS) \
		-f $(TOP)/tb/tb.f \
		-top testbench \
		-ssf testbench.fsdb \
		-nologo &
clean:
	rm -rf *.log simv* *.fsdb csrc verdiLog ucli.key novas.*
# vim:ft=make
#
