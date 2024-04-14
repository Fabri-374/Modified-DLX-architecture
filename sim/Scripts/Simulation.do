vsim -gui -t ns work.DLX_tb -voptargs=+acc
add wave -r /*
run 150 ns
wave zoom full
mem save -o registerfile.mem -f {} /dlx_tb/test/datapath_inst/DECODE_UNIT_inst/REG_FILE/REGISTERS
mem save -o dramdata.mem -f {} /dlx_tb/test/dram_inst/dram_mem
