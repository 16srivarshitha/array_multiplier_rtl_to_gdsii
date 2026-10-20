#!/bin/bash
# usage: bash sta/run_sta.sh [period_ns]   (run from the repo root)
export PERIOD=${1:-10}
: "${PDK_ROOT:?PDK_ROOT is not set}"
mkdir -p sta/reports
for c in tt_025C_1v80 ss_100C_1v60 ff_n40C_1v95; do
  lib=$PDK_ROOT/sky130A/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__$c.lib
  [ -f "$lib" ] || { echo "MISSING liberty file: $lib"; exit 1; }
  rpt=sta/reports/${c}_${PERIOD}ns.rpt
  CORNER=$c sta -no_splash -exit sta/sta.tcl > $rpt 2>&1
  echo "== $c @ ${PERIOD} ns =="
  if grep -q "^Error" $rpt; then grep "^Error" $rpt; continue; fi
  grep -iE "^(wns|tns|worst slack)|min period|fmax" $rpt
done