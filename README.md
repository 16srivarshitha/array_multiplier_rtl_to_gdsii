# 4-bit Array Multiplier: RTL to GDSII (SKY130)

## Team
| Name | Roll number | Parts |
|---|---|---|
| Sri Varshitha Medarametla | 2022102030  | A, C |
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

Tool: OpenSTA 3.1.0, netlist from Part B, SKY130 hd liberty (PDK 1689ac3f…, 2026.08.27) at ss_100C_1v60 / tt_025C_1v80 / ff_n40C_1v95.
Constraints: 10 ns clock, 0.25 ns uncertainty, 2 ns input/output delays (`sta/constraints.sdc`).

| Corner | Setup slack | Hold slack | Min period | Fmax |
|---|---|---|---|---|
| ss | 3.433 ns | 0.807 ns | 6.57 ns | 152 MHz |
| tt | 6.770 ns | 0.275 ns | 3.23 ns | 310 MHz |
| ff | 7.346 ns | 0.078 ns | 1.92 ns | 522 MHz |

All checks pass. Critical path: `b_r[0]` to `p[7]`, 9 stages. Pre-layout, ideal clock, no parasitics.
Full write-up: `sta/reports/PHASE_C_STA.md`. Reproduce: `bash sta/run_sta.sh 10`.

## Part D: Place and route
(to be added: record every run and its CLOCK_PERIOD)
