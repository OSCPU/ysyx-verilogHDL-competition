BUILD_DIR = $(abspath ./build)
BIN = $(BUILD_DIR)/seg_test

VSRCS = vsrc/seg.v test/seg_test.v
CSRCS = test/seg_test.cc

HAS_NVBOARD = false

# check available Python interpreter
PYTHON := $(shell command -v python3 2>/dev/null || command -v python 2>/dev/null)
ifeq ($(PYTHON),)
$(error No Python interpreter found)
endif

$(shell mkdir -p $(BUILD_DIR))

# rules for NVBoard
ifeq ($(HAS_NVBOARD), true)

# constraint file
SEG_AUTO_BIND = $(abspath $(BUILD_DIR)/auto_bind_seg.cc)
$(SEG_AUTO_BIND): test/seg_test.nxdc
	@$(PYTHON) $(NVBOARD_HOME)/scripts/auto_pin_bind.py $^ $@

include $(NVBOARD_HOME)/scripts/nvboard.mk

VERILATOR_EXTRA_FLAGS += +define+HAS_NVBOARD=1
VERILATOR_EXTRA_FLAGS += -CFLAGS -DHAS_NVBOARD=1
VERILATOR_EXTRA_FLAGS += $(addprefix -CFLAGS , $(addprefix -I, $(INC_PATH)))
VERILATOR_EXTRA_FLAGS += $(addprefix -CFLAGS , $(CXXFLAGS)) 
VERILATOR_EXTRA_FLAGS += $(addprefix -LDFLAGS , $(LDFLAGS))
CSRCS += $(SEG_AUTO_BIND)

endif

$(BIN): $(VSRCS) $(CSRCS) $(NVBOARD_ARCHIVE)
	$(call git_commit, "compile seg test")
	@verilator --top-module seg_test \
		--cc --exe --build \
		--autoflush \
		--Mdir $(BUILD_DIR) \
		-o $(BIN) \
		$(VSRCS) $(CSRCS) $(NVBOARD_ARCHIVE) \
		$(VERILATOR_EXTRA_FLAGS)

# run test
ifeq ($(HAS_NVBOARD), true)

test: $(BIN)
	$(call git_commit, "run seg test with NVBoard")
	@$(BIN)

else

test: $(BIN)
	$(call git_commit, "run seg test without NVBoard")
	@$(BIN) | $(PYTHON) test/seg_display.py

endif

.PHONY: default clean test

COMB_LOCK_HOME = $(shell git rev-parse --show-toplevel)
include $(COMB_LOCK_HOME)/scripts/tracer.mk
