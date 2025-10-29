include make.mk

.PHONY: load
.INTERMEDIATE: counter_pnr.json counter.json

TARGET=cpu
CST=tangnano9k
#EXCLUDE = %uart_top.v

# Disable mechnism for tests .. etc
FILES=$(filter-out $(EXCLUDE), $(VFILES))
# else
#FILES=$(VFILES)

all: $(TARGET).fs

help:
	@echo "Targets: "
	@echo "    list        -   List 'v' files "
	@echo "    syn         -   Synthesize "
	@echo "    clean       -   Clean intermediaries"
	@echo "    load        -   Load to chip memory "
	@echo "    loadflash   -   Load to cip flash "

list:
	@echo $(FILES)

syn:
	make $(TARGET).json

clean:
	@rm -f $(TARGET).fs
	@rm -f $(TARGET).json
	@rm -f $(TARGET)_pnr.json

# Synthesis
$(TARGET).json: $(FILES)
	yosys -p   "read_verilog $(FILES); \
                synth_gowin -json $(TARGET).json ; "

# Place and Route
$(TARGET)_pnr.json: $(TARGET).json
	$(NEXPR) --json $(TARGET).json --freq 27 --write $(TARGET)_pnr.json \
	--device ${DEVICE} --vopt family=${FAMILY} --vopt cst=${CST}.cst

# Generate Bitstream
$(TARGET).fs: $(TARGET)_pnr.json
	$(GWPACK) -d ${FAMILY} -o $(TARGET).fs $(TARGET)_pnr.json

# Program Board
load: $(TARGET).fs
	$(LOADER) -b ${BOARD} $(TARGET).fs

loadflash: $(TARGET).fs
	$(LOADER) -b ${BOARD} -f $(TARGET).fs

# EOF
