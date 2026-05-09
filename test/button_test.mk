BUILD_DIR = $(abspath ./build)
BIN = $(BUILD_DIR)/seg_test

VSRCS = vsrc/seg.v vsrc/button.v test/button_test.v
CSRCS = test/button_test.cc

# check available Python interpreter
PYTHON := $(shell command -v python3 2>/dev/null || command -v python 2>/dev/null)
ifeq ($(PYTHON),)
$(error No Python interpreter found)
endif

$(shell mkdir -p $(BUILD_DIR))

# constraint file
SEG_AUTO_BIND = $(abspath $(BUILD_DIR)/auto_bind_button.cc)
$(SEG_AUTO_BIND): test/button_test.nxdc
	@$(PYTHON) $(NVBOARD_HOME)/scripts/auto_pin_bind.py $^ $@

include $(NVBOARD_HOME)/scripts/nvboard.mk

VERILATOR_EXTRA_FLAGS += +define+HAS_NVBOARD=1
VERILATOR_EXTRA_FLAGS += -CFLAGS -DHAS_NVBOARD=1
VERILATOR_EXTRA_FLAGS += $(addprefix -CFLAGS , $(addprefix -I, $(INC_PATH)))
VERILATOR_EXTRA_FLAGS += $(addprefix -CFLAGS , $(CXXFLAGS)) 
VERILATOR_EXTRA_FLAGS += $(addprefix -LDFLAGS , $(LDFLAGS))
CSRCS += $(SEG_AUTO_BIND)

$(BIN): $(VSRCS) $(CSRCS) $(NVBOARD_ARCHIVE)
	$(call git_commit, "compile button test")
	@verilator --top-module button_test \
		--cc --exe --build \
		--autoflush \
		--Mdir $(BUILD_DIR) \
		-o $(BIN) \
		$(VSRCS) $(CSRCS) $(NVBOARD_ARCHIVE) \
		$(VERILATOR_EXTRA_FLAGS)

test: $(BIN)
	$(call git_commit, "run button test")
	@$(BIN)

.PHONY: default clean test

COMB_LOCK_HOME = $(shell git rev-parse --show-toplevel)
include $(COMB_LOCK_HOME)/scripts/tracer.mk