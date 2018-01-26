_color_k   := $(shell echo -e '\033[0;30m')
_color_r   := $(shell echo -e '\033[0;31m')
_color_g   := $(shell echo -e '\033[0;32m')
_color_y   := $(shell echo -e '\033[0;33m')
_color_b   := $(shell echo -e '\033[0;34m')
_color_m   := $(shell echo -e '\033[0;35m')
_color_c   := $(shell echo -e '\033[0;36m')
_color_w   := $(shell echo -e '\033[0;37m')
_color_end := $(shell echo -e '\033[0m')

SDNET  := $(shell command -v sdnet  2> /dev/null)
DOT    := $(shell command -v dot    2> /dev/null)
G++    := $(shell command -v g++    2> /dev/null)
VIVADO := $(shell command -v vivado 2> /dev/null)

SRC     = system.sdnet
MAIN    = DNS
BUSTYPE = axi
TB      = $(MAIN)/$(MAIN).TB/$(MAIN)
IP      = $(MAIN)/$(MAIN)_vivado/$(MAIN)
GRAPH   = $(MAIN)/$(MAIN).png $(MAIN)/$(MAIN)_elaborated.png

.PHONY: all
all: $(MAIN) $(GRAPH) $(TB) $(IP)

$(MAIN): $(SRC)
ifndef SDNET
	$(error $(_color_r)ERROR: Program "sdnet" not found in PATH$(_color_end))
endif
	$(info >> $(_color_c)Compiling SDNet System...$(_color_end))
	@rm -frv $@
	$(SDNET) $< -busType $(BUSTYPE) -workDir .

$(GRAPH): $(MAIN)/run_dot.bash $(GRAPH:%.png=%.dot)
ifndef DOT
	$(error $(_color_r)ERROR: Program "dot" not found in PATH$(_color_end))
endif
	$(info >> $(_color_c)Generating SDNet System Graphs...$(_color_end))
	@rm -frv $@
	cd $(dir $<) && ./$(notdir $<)

$(TB): $(MAIN)/$(MAIN).TB/compile.bash $(MAIN)/$(MAIN).h $(wildcard $(MAIN)/*.TB/*.hpp $(MAIN)/*.TB/*.cpp)
ifndef G++
	$(error $(_color_r)ERROR: Program "g++" not found in PATH$(_color_end))
endif
	$(info >> $(_color_c)Compiling SDNet System C++ Testbench...$(_color_end))
	@rm -frv $@
	cd $(dir $<) && ./$(notdir $<)

$(IP): $(MAIN)/$(MAIN)_vivado_packager.tcl $(MAIN)/$(MAIN).v $(wildcard $(MAIN)/*.HDL/*.v $(MAIN)/*.HDL/*.sv $(MAIN)/*.HDL/*.vp)
ifndef VIVADO
	$(error $(_color_r)ERROR: Program "vivado" not found in PATH$(_color_end))
endif
	$(info >> $(_color_c)Generating SDNet System IP Core...$(_color_end))
	@rm -frv $@
	cd $(dir $<) && $(VIVADO) -mode batch -nojournal -nolog -source $(notdir $<)

.PHONY: clean
clean:
	$(info >> $(_color_y)Cleaning previous build...$(_color_end))
	@rm -frv $(MAIN)

