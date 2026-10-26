# 4-bit Array Multiplier: RTL to GDSII (SKY130)

## Team
| Name | Roll number | Parts |
|---|---|---|
| Sri Varshitha Medarametla | 2022102030 | A, C |
| Sasidhar Varada | 2024702015 | B, D |

Tools: IIC-OSIC-TOOLS Docker image, SKY130 PDK version 1689ac3f (2026.08.27),
standard cell library sky130_fd_sc_hd.

## Part A: RTL simulation
```
iverilog -g2012 -o sim tb/tb_mult.v rtl/full_adder.v rtl/mult_array.v
vvp sim
gtkwave mult.vcd
```
Result: `PASS: 256 vectors checked, 0 errors`

Error test: `sum` in `rtl/full_adder.v` was temporarily changed to `a ^ b`, and the
same two commands were run again.
Result: `FAIL: 256 vectors checked, 95 errors`. The change was then undone.

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

## Part C: Static timing analysis
Constraints as given in the assignment: typical corner tt_025C_1v80, 1.0 ns input
and output delays, ideal clock.
```
sta sta/sta.tcl                  # T = 10 ns
PERIOD=2.98 sta sta/sta.tcl      # re-check at T = Tmin
sta sta/sta.tcl                  # final run at T = 10 ns writes sta/mult_array_timing.rpt
```
Worst setup slack at T = 10 ns: 7.020 ns
Tmin = 10 - 7.020 = 2.98 ns, Fmax = 1000 / 2.98 = 335.6 MHz
Slack at T = 2.98 ns: approximately 0
Critical path: input register `b_r[0]` to output register `p[6]`.

### Additional analysis: stricter constraints, three corners
Run with `sta/constraints.sdc`: 10 ns clock, 0.25 ns uncertainty, 2 ns input/output delays.

| Corner | Setup slack | Hold slack | Min period | Fmax |
|---|---|---|---|---|
| ss | 3.433 ns | 0.807 ns | 6.57 ns | 152 MHz |
| tt | 6.770 ns | 0.275 ns | 3.23 ns | 310 MHz |
| ff | 7.346 ns | 0.078 ns | 1.92 ns | 522 MHz |

All checks pass. Pre-layout, ideal clock, no parasitics.
Full write-up: `sta/reports/PHASE_C_STA.md`.

## Part D: Place and route
```
cd pnr
librelane --pdk sky130A --scl sky130_fd_sc_hd --manual-pdk config.json
```
CLOCK_PERIOD started at 1.2 x Tmin = 3.58 ns, rounded up to 4.0 ns. It was raised
by 0.5 ns after each run that failed timing at the slow corner (ss_100C_1v60).

| Run | CLOCK_PERIOD (ns) | Worst setup slack (ns) | Result |
|---|---|---|---|
| 1 | 4.0 | negative | FAIL |
| 2 | 4.5 | negative | FAIL |
| 3 | 5.0 | -0.957 | FAIL |
| 4 | 5.5 | -0.456 | FAIL |
| 5 | 6.0 | -0.128 | FAIL |
| 6 | 6.5 | -0.157 | FAIL |
| 7 | 7.0 | +0.076 | PASS |

Final run: 0 DRC errors, 0 LVS errors, 1901 cells, core area 17759.5 um^2,
wirelength 2340 um. Post-route Fmax = 1000 / (7.0 - 0.076) = 144.4 MHz.
`pnr/metrics.json` and `pnr/mult_array.gds` are copied from that run's `final/` folder:
```
cp runs/<final-run>/final/metrics.json .
cp runs/<final-run>/final/gds/mult_array.gds .
```

Note: the first attempts accidentally used the container's default PDK (IHP SG13G2).
They were discarded, and the flow was re-run with `--pdk sky130A`.
