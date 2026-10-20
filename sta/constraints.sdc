# Pre-layout SDC for mult_array. PERIOD (ns) comes from the environment.
set period $::env(PERIOD)

create_clock -name clk -period $period [get_ports clk]
set_clock_uncertainty 0.25 [get_clocks clk]

# I/O budget: 20% of the period on each side
set io_delay [expr {0.2 * $period}]
set_input_delay  $io_delay -clock clk [get_ports {a[*] b[*] rst_n}]
set_output_delay $io_delay -clock clk [get_ports {p[*]}]

set_driving_cell -lib_cell sky130_fd_sc_hd__buf_2 -pin X [get_ports {a[*] b[*] rst_n}]
set_load 0.05 [get_ports {p[*]}]
