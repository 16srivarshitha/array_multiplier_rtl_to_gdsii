# usage: CORNER=tt_025C_1v80 PERIOD=10 sta -no_splash -exit sta/sta.tcl
set corner $::env(CORNER)
set lib $::env(PDK_ROOT)/sky130A/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__${corner}.lib

read_liberty $lib
read_verilog synth/mult_array_netlist.v
link_design mult_array
read_sdc sta/constraints.sdc

puts "===== corner $corner, period $::env(PERIOD) ns ====="
report_checks -path_delay max -group_path_count 1 -format full_clock_expanded -digits 3
report_checks -path_delay min -group_path_count 1 -digits 3
report_checks -path_delay max -through [get_pins -hierarchical *RESET_B] -digits 3
report_wns
report_tns
report_worst_slack -max
report_worst_slack -min
report_clock_min_period
report_check_types -max_slew -max_capacitance -violators
