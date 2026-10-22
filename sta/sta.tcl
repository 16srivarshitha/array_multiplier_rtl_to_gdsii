# Usage: sta sta/sta.tcl                 (T = 10 ns, typical corner)
#        PERIOD=<Tmin> sta sta/sta.tcl   (re-check at Tmin)
if {[info exists ::env(CORNER)]} {set corner $::env(CORNER)} else {set corner tt_025C_1v80}
if {[info exists ::env(PERIOD)]} {set T $::env(PERIOD)} else {set T 10}
set lib $::env(PDK_ROOT)/sky130A/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__${corner}.lib

# 1. Read the cell timing library
read_liberty $lib
# 2. Read and link the netlist
read_verilog synth/mult_array_netlist.v
link_design mult_array
# 3. Clock with period T (ns)
create_clock -name clk -period $T [get_ports clk]
# 4. Input arrival time
set_input_delay 1.0 -clock clk [delete_from_list [all_inputs] [get_ports clk]]
# 5. Output required time
set_output_delay 1.0 -clock clk [all_outputs]

puts "===== corner $corner, period $T ns ====="
# 6. Worst setup slack
report_worst_slack -max
# 7. Save the critical path report
report_checks -path_delay max -digits 3 > sta/mult_array_timing.rpt

# Extra checks
report_checks -path_delay min -group_path_count 1 -digits 3
report_wns
report_tns
report_worst_slack -min
report_clock_min_period
report_check_types -max_slew -max_capacitance -violators
exit
