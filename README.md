# 4-bit Array Multiplier: RTL to GDSII (SKY130)

## Team
| Name | Roll number | Parts |
|---|---|---|
| TEAMMATE NAME | TEAMMATE ROLL NO | A, C |
| Sasidhar Varada | 2024702015 | B, D |

## Part A: RTL simulation
```
iverilog -g2012 -o sim tb/tb_mult.v rtl/full_adder.v rtl/mult_array.v
vvp sim
gtkwave mult.vcd
```
Result: `PASS: 256 vectors checked, 0 errors`

## Part B: Synthesis
```
yosys -c synth/synth.tcl
```
Gate-level simulation:
```
CELLS=$PDK_ROOT/sky130A/libs.ref/sky130_fd_sc_hd/verilog
iverilog -g2012 -DFUNCTIONAL -DUNIT_DELAY=#1 -o gls tb/tb_mult.v $CELLS/primitives.v $CELLS/sky130_fd_sc_hd.v synth/mult_array_netlist.v
vvp gls
```
Result: `PASS: 256 vectors checked, 0 errors`

Note: the testbench originally checked `p` 1 ns after the clock edge. In the netlist
simulation the flip-flops also update 1 ns after the edge (UNIT_DELAY=#1), so every
result was read one vector late. The check was moved to 2 ns after the edge (`#2`).

## Part C: STA
(to be added)

## Part D: Place and route
(to be added: record every run and its CLOCK_PERIOD)
