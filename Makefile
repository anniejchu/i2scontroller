# -Wall turns on all warnings
# -g2012 selects the 2012 version of iVerilog
IVERILOG=iverilog -g2012 -Wall -y./verilog -y./tests -y./music -Y.sv -I./verilog
VVP=vvp
VVP_POST=-fst
VIVADO=vivado -mode batch -source

# # TODO(avinash) - find a better way to do this
# RFILE_SRCS=hdl/register_file.sv hdl/register.sv hdl/decoder*.sv
# # If you are using your own ALU files you should add them here:
# ALU_SRCS=hdl/alu_behavioural.sv hdl/alu_types.sv
# MMU_SRCS=hdl/block_ram.sv
# # RV32I_SRCS=hdl/rv32i_defines.sv hdl/rv32i_system.sv hdl/rv32i_multicycle_core.sv ${RFILE_SRCS} ${ALU_SRCS} ${MMU_SRCS}
# RV32I_SRCS=${RFILE_SRCS} ${ALU_SRCS} ${MMU_SRCS} hdl/rv32i_defines.sv hdl/rv32i_multicycle_core.sv hdl/rv32i_system.sv

I2S_SRCS=verilog/i2s_types.sv verilog/i2s_controller.sv
MAIN_SRCS=${I2S_SRCS} verilog/block_rom.sv verilog/main.sv

# Look up .PHONY rules for Makefiles
.PHONY: clean submission remove_solutions

%.memh : %.wav wav2hex.py
	./wav2hex.py $< -o $@ --verbose --length 25000

test_i2s_controller : tests/test_i2s_controller.sv ${I2S_SRCS}
	${IVERILOG} $^ -o test_i2s_controller.bin && ${VVP} test_i2s_controller.bin ${VVP_POST}

# test_register_file: tests/test_register_file.sv ${RFILE_SRCS}
# 	${IVERILOG} $^ -o test_register_file.bin && ${VVP} test_register_file.bin ${VVP_POST}

# test_distributed_ram: tests/test_distributed_ram.sv hdl/distributed_ram.sv
# 	${IVERILOG} $^ -o test_distributed_ram.bin && ${VVP} test_distributed_ram.bin ${VVP_POST}

# # Modify the -DINITIAL_MEMORY string to change the initial memory.
# test_rv32i_system: tests/test_rv32i_system.sv asm/lw.memh ${RV32I_SRCS}
# 	${IVERILOG} -DINITIAL_MEMORY=\"asm/lw.memh\" tests/test_rv32i_system.sv ${RV32I_SRCS} -s test_rv32i_system -o test_rv32i_system.bin && ${VVP} test_rv32i_system.bin ${VVP_POST}

# waves_main: test_main
# 	gtkwave main.fst -a verilog/main.gtkw

test_main: tests/test_main.sv  music/CantinaBand3_lower.memh ${MAIN_SRCS}
	${IVERILOG} tests/test_main.sv ${MAIN_SRCS} -o test_main.bin && ${VVP} test_main.bin ${VVP_POST}


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