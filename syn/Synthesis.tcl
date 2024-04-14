##############################################################
#SCRIPT FOR SPEEDING UP and RECORDING the DLX PROCESSOR SYNTHESIS#
# analyzing and checking vhdl netlist#
# here the analyze command is used for each file from bottom to top #
##############################################################

exec mkdir -p work
exec mkdir -p Reports
exec mkdir -p Design

##############################################################
# 
# Procedure report_slack used to print on terminal the timing results
#
##############################################################

proc report_slack {} {
  echo [format "%-20s %-20s %7s" "From" "To" "Slack"]
     echo "--------------------------------------------------------"
      foreach_in_collection path [get_timing_paths -nworst 100] {
        set slack [get_attribute $path slack]
        set startpoint [get_attribute $path startpoint]
        set endpoint [get_attribute $path endpoint]
        echo [format "%-20s %-20s %s" [get_attribute $startpoint full_name] \
             [get_attribute $endpoint full_name] $slack]
	}
}

##############################################################
# 
# Messages suppression 
#
##############################################################

#suppress useless warning
suppress_message RTDC-60
suppress_message RTDC-5
suppress_message RTDC-115
suppress_message VHDL-290
suppress_message VHDL-13
suppress_message TEST-120
suppress_message VO-11
suppress_message VO-4
suppress_message TIM-134
suppress_message UISN-40

#suppress information messages
suppress_message OPT-319
suppress_message OPT-776
suppress_message OPT-1206
suppress_message OPT-1055
suppress_message TEST-171
suppress_message PWR-806
suppress_message PWR-730

##############################################################
# 
# Analyze all vhd files used by DLX, the top hierarchy file is DLX.vhd
#
##############################################################

#Globals
analyze -library WORK -format vhdl {DLX_vhd_fully_synthesizable/000-globals.vhd}
#Components
analyze -library WORK -format vhdl {DLX_vhd_fully_synthesizable/Components/fa.vhd}
analyze -library WORK -format vhdl {DLX_vhd_fully_synthesizable/Components/rca_gen.vhd}
analyze -library WORK -format vhdl {DLX_vhd_fully_synthesizable/Components/fd_gen.vhd}
analyze -library WORK -format vhdl {DLX_vhd_fully_synthesizable/Components/mux21_gen.vhd}
analyze -library WORK -format vhdl {DLX_vhd_fully_synthesizable/Components/mux41_gen.vhd}
analyze -library WORK -format vhdl {DLX_vhd_fully_synthesizable/Components/mux61_gen.vhd}
analyze -library WORK -format vhdl {DLX_vhd_fully_synthesizable/Components/fd_1bit.vhd}
analyze -library WORK -format vhdl {DLX_vhd_fully_synthesizable/Components/and2.vhd}
analyze -library WORK -format vhdl {DLX_vhd_fully_synthesizable/Components/xnor2.vhd}
analyze -library WORK -format vhdl {DLX_vhd_fully_synthesizable/Components/iv_gen.vhd}
analyze -library WORK -format vhdl {DLX_vhd_fully_synthesizable/Components/nand31_gen.vhd}
analyze -library WORK -format vhdl {DLX_vhd_fully_synthesizable/Components/nand41_gen.vhd}
#P4 adder components
analyze -library WORK -format vhdl {DLX_vhd_fully_synthesizable/a.b-DataPath.core/a.b.c-EXECUTION_UNIT.core/a.b.c.a-ALU.core/a.b.c.a.a-P4_ADDER.core/a-carry_gen.vhd}
analyze -library WORK -format vhdl {DLX_vhd_fully_synthesizable/a.b-DataPath.core/a.b.c-EXECUTION_UNIT.core/a.b.c.a-ALU.core/a.b.c.a.a-P4_ADDER.core/b-sum_generator.vhd}
analyze -library WORK -format vhdl {DLX_vhd_fully_synthesizable/a.b-DataPath.core/a.b.c-EXECUTION_UNIT.core/a.b.c.a-ALU.core/a.b.c.a.a-P4_ADDER.core/a.a-G.vhd}
analyze -library WORK -format vhdl {DLX_vhd_fully_synthesizable/a.b-DataPath.core/a.b.c-EXECUTION_UNIT.core/a.b.c.a-ALU.core/a.b.c.a.a-P4_ADDER.core/a.b-PG.vhd}
analyze -library WORK -format vhdl {DLX_vhd_fully_synthesizable/a.b-DataPath.core/a.b.c-EXECUTION_UNIT.core/a.b.c.a-ALU.core/a.b.c.a.a-P4_ADDER.core/a.c-PG_network.vhd}
analyze -library WORK -format vhdl {DLX_vhd_fully_synthesizable/a.b-DataPath.core/a.b.c-EXECUTION_UNIT.core/a.b.c.a-ALU.core/a.b.c.a.a-P4_ADDER.core/b.a-carry_select_block.vhd}
#ALU components
analyze -library WORK -format vhdl {DLX_vhd_fully_synthesizable/a.b-DataPath.core/a.b.c-EXECUTION_UNIT.core/a.b.c.a-ALU.core/a-P4_adder.vhd}
analyze -library WORK -format vhdl {DLX_vhd_fully_synthesizable/a.b-DataPath.core/a.b.c-EXECUTION_UNIT.core/a.b.c.a-ALU.core/b-T2_shifter.vhd}
analyze -library WORK -format vhdl {DLX_vhd_fully_synthesizable/a.b-DataPath.core/a.b.c-EXECUTION_UNIT.core/a.b.c.a-ALU.core/c-comparator.vhd}
analyze -library WORK -format vhdl {DLX_vhd_fully_synthesizable/a.b-DataPath.core/a.b.c-EXECUTION_UNIT.core/a.b.c.a-ALU.core/d-logicals.vhd}
analyze -library WORK -format vhdl {DLX_vhd_fully_synthesizable/a.b-DataPath.core/a.b.c-EXECUTION_UNIT.core/a.b.c.a-ALU.core/e-decoder_alu.vhd}
#EXECUTION UNIT components
analyze -library WORK -format vhdl {DLX_vhd_fully_synthesizable/a.b-DataPath.core/a.b.c-EXECUTION_UNIT.core/a-alu.vhd}
analyze -library WORK -format vhdl {DLX_vhd_fully_synthesizable/a.b-DataPath.core/a.b.c-EXECUTION_UNIT.core/b-booth_multiplier.vhd}
analyze -library WORK -format vhdl {DLX_vhd_fully_synthesizable/a.b-DataPath.core/a.b.c-EXECUTION_UNIT.core/b.a-mux51_encoder.vhd}
#DECODE UNIT components
analyze -library WORK -format vhdl {DLX_vhd_fully_synthesizable/a.b-DataPath.core/a.b.b-DECODE_UNIT.core/cond.vhd}
analyze -library WORK -format vhdl {DLX_vhd_fully_synthesizable/a.b-DataPath.core/a.b.b-DECODE_UNIT.core/IR_decoder.vhd}
analyze -library WORK -format vhdl {DLX_vhd_fully_synthesizable/a.b-DataPath.core/a.b.b-DECODE_UNIT.core/registerfile.vhd}
analyze -library WORK -format vhdl {DLX_vhd_fully_synthesizable/a.b-DataPath.core/a.b.b-DECODE_UNIT.core/sign_extend.vhd}
analyze -library WORK -format vhdl {DLX_vhd_fully_synthesizable/a.b-DataPath.core/a.b.b-DECODE_UNIT.core/zero_detector.vhd}
# DataPath components
analyze -library WORK -format vhdl {DLX_vhd_fully_synthesizable/a.b-DataPath.core/a.b.a-FETCH_UNIT.vhd}
analyze -library WORK -format vhdl {DLX_vhd_fully_synthesizable/a.b-DataPath.core/a.b.b-DECODE_UNIT.vhd}
analyze -library WORK -format vhdl {DLX_vhd_fully_synthesizable/a.b-DataPath.core/a.b.c-EXECUTION_UNIT.vhd}
analyze -library WORK -format vhdl {DLX_vhd_fully_synthesizable/a.b-DataPath.core/a.b.d-MEMORY_UNIT.vhd}
analyze -library WORK -format vhdl {DLX_vhd_fully_synthesizable/a.b-DataPath.core/a.b.e-WRITE_BACK_UNIT.vhd}
analyze -library WORK -format vhdl {DLX_vhd_fully_synthesizable/a.b-DataPath.core/a.b.f-HAZARD_UNIT.vhd}
analyze -library WORK -format vhdl {DLX_vhd_fully_synthesizable/a.b-DataPath.core/a.b.g-FORWARDING_UNIT.vhd}
# DLX Components
analyze -library WORK -format vhdl {DLX_vhd_fully_synthesizable/a.b-DataPath.vhd}
analyze -library WORK -format vhdl {DLX_vhd_fully_synthesizable/a.a-CU_HW.vhd}
# DLX
analyze -library WORK -format vhdl {DLX_vhd_fully_synthesizable/a-DLX.vhd}
##############################################################

# elaborate the design without external parameters
elaborate DLX -architecture STRUCTURAL -library WORK
set_wire_load_model -name 5K_hvratio_1_4

#set current design DLX
current_design DLX

# create clock
set ClockName "CLK"
#########################
### clock constraints ###
#########################
create_clock -name $ClockName -period 5 CLK
compile

# save reports
report_timing > ./Reports/DLX_timing_report_nopt.rpt
report_area > ./Reports/DLX_area_report_nopt.rpt
report_power > ./Reports/DLX_power_report_nopt.rpt
report_clock > ./Reports/DLX_clock_report_nopt.rpt

# save files
write -hierarchy -format ddc -output ./Design/DLX_nopt.ddc
write -hierarchy -format vhdl -output ./Design/DLX_nopt.vhdl
write -hierarchy -format verilog -output ./Design/DLX_nopt.v
write_sdc ./Design/DLX_nopt.sdc

##############################################################
set MAX_PATH [ get_timing_paths -delay_type max -nworst 1  -include_hierarchical_pins ]

#calculating the value of max_path in ns
foreach_in_collection path $MAX_PATH   { 
        set mpi 0.0
    foreach_in_collection point [ get_attribute $path points ] {
 	set mpi [ get_attribute $point arrival ]
        }
}
#########################
# end of not- optimized area
#########################

# set a 10% lower required time( float )  than maxpath
set REQUIRED_TIME [ expr $mpi*0.90 ]

#########################
### clock constraints ###
#########################
create_clock -name $ClockName -period $REQUIRED_TIME CLK
set_max_delay $REQUIRED_TIME -from [all_inputs] -to [all_outputs]
set_fix_hold $ClockName

set max_transition_time 0.01
set_max_transition $max_transition_time [all_outputs]
set_min_delay 0.20 -from [all_inputs] -to [all_outputs]
set_input_delay 0.15 -clock $ClockName [all_inputs]
set_output_delay 0.15 -clock $ClockName [all_outputs]

optimize_registers -clock $ClockName  -minimum_period_only
set_fix_hold $ClockName

# optimize
compile_ultra -scan -timing_high_effort_script -no_autoungroup -gate_clock
# save report
report_timing > ./Reports/DLX_timing_report_topt10.rpt
report_area > ./Reports/DLX_area_report_topt10.rpt
report_power > ./Reports/DLX_power_report_topt10.rpt
report_clock > ./Reports/DLX_clock_report_topt10.rpt

# saving files
write -hierarchy -format ddc -output ./Design/dlx_topt_10.ddc
write -hierarchy -format vhdl -output ./Design/dlx_topt_10.vhdl
write -hierarchy -format verilog -output ./Design/dlx_topt_10.v
#write_sdc ./output_netlist/dlx_irsize32_pcsize32_10.sdc

#try an higher optimization

#set a 20% lower required time( float )  than maxpath
set REQUIRED_TIME [ expr $mpi*0.80 ]
#########################
### clock constraints ###
#########################
create_clock -name $ClockName -period $REQUIRED_TIME CLK
set_max_delay $REQUIRED_TIME -from [all_inputs] -to [all_outputs]
set_fix_hold $ClockName

set max_transition_time 0.01
set_max_transition $max_transition_time [all_outputs]
set_min_delay 0.20 -from [all_inputs] -to [all_outputs]
set_input_delay 0.15 -clock $ClockName [all_inputs]
set_output_delay 0.15 -clock $ClockName [all_outputs]

optimize_registers -clock $ClockName  -minimum_period_only
set_fix_hold $ClockName


# optimize
# enable the scan insetion and clock gating
compile_ultra -scan -timing_high_effort_script -no_autoungroup -gate_clock

# save report
report_timing > ./Reports/DLX_timing_report_topt20.rpt
report_area > ./Reports/DLX_area_report_topt20.rpt
report_power > ./Reports/DLX_power_report_topt20.rpt
report_clock > ./Reports/DLX_clock_report_topt20.rpt
# saving files
write -hierarchy -format ddc -output ./Design/dlx_topt_20.ddc
write -hierarchy -format vhdl -output ./Design/dlx_topt_20.vhdl
write -hierarchy -format verilog -output ./Design/dlx_topt_20.v

#try an higher optimization

#set a 30% lower required time( float )  than maxpath
set REQUIRED_TIME [ expr $mpi*0.70 ]
#########################
### clock constraints ###
#########################
create_clock -name $ClockName -period $REQUIRED_TIME CLK
set_max_delay $REQUIRED_TIME -from [all_inputs] -to [all_outputs]
set_fix_hold $ClockName

set max_transition_time 0.01
set_max_transition $max_transition_time [all_outputs]
set_min_delay 0.20 -from [all_inputs] -to [all_outputs]
set_input_delay 0.15 -clock $ClockName [all_inputs]
set_output_delay 0.15 -clock $ClockName [all_outputs]

optimize_registers -clock $ClockName  -minimum_period_only
set_fix_hold $ClockName


# optimize
# enable the scan insetion and evaluation of impact
compile_ultra -scan -timing_high_effort_script -no_autoungroup -gate_clock

# save report
report_timing > ./Reports/DLX_timing_report_topt30.rpt
report_area > ./Reports/DLX_area_report_topt30.rpt
report_power > ./Reports/DLX_power_report_topt30.rpt
report_clock > ./Reports/DLX_clock_report_topt30.rpt
# saving files
write -hierarchy -format ddc -output ./Design/dlx_topt_30.ddc
write -hierarchy -format vhdl -output ./Design/dlx_topt_30.vhdl
write -hierarchy -format verilog -output ./Design/dlx_topt_30.v
#write_sdc ./output_netlist/dlx_irsize32_pcsize32_10.sdc


#set a 50% lower required time( float )  than maxpath
set REQUIRED_TIME [ expr $mpi*0.50 ]
#########################
### clock constraints ###
#########################
create_clock -name $ClockName -period $REQUIRED_TIME CLK
set_max_delay $REQUIRED_TIME -from [all_inputs] -to [all_outputs]
set_fix_hold $ClockName

set max_transition_time 0.01
set_max_transition $max_transition_time [all_outputs]
set_min_delay 0.20 -from [all_inputs] -to [all_outputs]
set_input_delay 0.15 -clock $ClockName [all_inputs]
set_output_delay 0.15 -clock $ClockName [all_outputs]

optimize_registers -clock $ClockName  -minimum_period_only
set_fix_hold $ClockName


# optimize
# enable the scan insetion and evaluation of impact
compile_ultra -scan -timing_high_effort_script -no_autoungroup -gate_clock

# save report
report_timing > ./Reports/DLX_timing_report_topt50.rpt
report_area > ./Reports/DLX_area_report_topt50.rpt
report_power > ./Reports/DLX_power_report_topt50.rpt
report_clock > ./Reports/DLX_clock_report_topt50.rpt
# saving files
write -hierarchy -format ddc -output ./Design/dlx_topt_50.ddc
write -hierarchy -format vhdl -output ./Design/dlx_topt_50.vhdl
write -hierarchy -format verilog -output ./Design/dlx_topt_50.v
report_slack
#remove the exit command if the gui is used
exit
