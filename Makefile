# -Wall turns on all warnings
# -g2012 selects the 2012 version of iVerilog
IVERILOG=iverilog -g2012 -Wall -y./verilog -y./tests -Y.sv -I./verilog
VVP=vvp
VVP_POST=-fst
VIVADO=vivado -mode batch -source

I2S_SRCS=verilog/i2s_controller.sv
MAIN_SRCS=${I2S_SRCS} verilog/block_rom.sv verilog/main.sv

# Look up .PHONY rules for Makefiles
.PHONY: clean submission remove_solutions

%.memh : %.wav wav2hex.py
	./wav2hex.py $< -o $@ --verbose --length 45000

test_i2s_controller : tests/test_i2s_controller.sv ${I2S_SRCS}
	${IVERILOG} $^ -o test_i2s_controller.bin && ${VVP} test_i2s_controller.bin ${VVP_POST}

test_main: tests/test_main.sv  music/CantinaBand3_lower.memh ${MAIN_SRCS}
	${IVERILOG} tests/test_main.sv ${MAIN_SRCS} -o test_main.bin && ${VVP} test_main.bin ${VVP_POST}

waves_main: test_main
	gtkwave main.fst -a verilog/main.gtkw

main.bit:  $(MAIN_SRCS) build.tcl
	@echo "########################################"
	@echo "#### Building FPGA bitstream        ####"
	@echo "########################################"
	${VIVADO} build.tcl

program_fpga_vivado: main.bit build.tcl program.tcl
	@echo "########################################"
	@echo "#### Programming FPGA (Vivado)      ####"
	@echo "########################################"
	${VIVADO} program.tcl

program_fpga_digilent: main.bit build.tcl
	@echo "########################################"
	@echo "#### Programming FPGA (Digilent)    ####"
	@echo "########################################"
	djtgcfg enum
	djtgcfg prog -d CmodA7 -i 0 -f main.bit


# Call this to clean up all your generated files
clean:
	rm -f *.bin *.vcd *.fst vivado*.log *.jou vivado*.str *.log *.checkpoint *.bit *.html *.xml
	rm -rf .Xil
	rm -rf __pycache__
	rm music/*.memh

# Call this to generate your submission zip file.
submission:
	zip submission.zip Makefile *.sv README.md docs/* *.tcl *.xdc tests/*.sv *.pdf
