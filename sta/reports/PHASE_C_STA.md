# Part C: Timing Analysis, in Simple Terms

## What we did

A chip's flip-flops grab data on every tick of a clock. Between two flip-flops, the signal has to travel through logic gates, and that takes time. Static timing analysis (STA) checks, without running any test inputs, whether every signal gets where it needs to be on time.

We ran STA on the gate-level netlist of the 4-bit multiplier using OpenSTA. We checked three conditions of the chip, called corners:

| Corner | What it means | Speed |
|---|---|---|
| Slow (ss) | Hot (100 °C), low voltage (1.6 V) | Slowest, so worst case for speed |
| Typical (tt) | Room temperature (25 °C), 1.8 V | Normal |
| Fast (ff) | Cold (-40 °C), high voltage (1.95 V) | Fastest, so worst case for hold |

We used a 10 ns clock (100 MHz).

## The two checks that matter

- **Setup check: is the signal fast enough?** The data must arrive before the next clock tick. If the clock is too fast, this fails. Slack is how many nanoseconds of spare time there are. Positive means pass.
- **Hold check: is the signal too fast?** The data must not arrive so early that it overwrites the previous value before the flip-flop has captured it. This check does not depend on the clock speed.

## Results

| Corner | Setup spare time | Hold spare time | Fastest clock allowed |
|---|---|---|---|
| Slow | 3.43 ns | 0.81 ns | 152 MHz |
| Typical | 6.77 ns | 0.28 ns | 310 MHz |
| Fast | 7.35 ns | 0.08 ns | 522 MHz |

Everything passes at every corner. No timing violations.

## What this means

1. **The design can run at about 152 MHz.** We take the number from the slow corner, because the chip must work in the worst case. The typical and fast numbers are only for comparison. Our 10 ns test clock (100 MHz) is comfortably slower than this limit.
2. **The slowest path is the multiplier logic.** It starts at the register holding input `b[0]` and ends at output bit `p[7]`, passing through 9 gates. The full-adder chain at the end (three `maj3` cells) takes the most time.
3. **The hold margin at the fast corner is small (0.08 ns).** It is still positive, so it passes. The shortest path is `a[0] AND b[0]` going into `p[0]`, which has almost no logic delay. This margin could become a problem in Part D, when the real clock wiring is added. If it does, the tool will insert delay buffers to fix it.
4. **The reset signal is safe.** The reset (`rst_n`) has plenty of spare time at all corners.

## Things to keep in mind

- **These numbers are optimistic.** We assumed a perfect clock and no wire delays. Real wires add delay, so Part D will give slower results.
- **Some settings were our own choices:** the input and output timing budgets (2 ns each), the driver strength on inputs, and the output load. If the course gives different values, rerun with those.
- **STA checks timing only.** Whether the multiplier gives the correct answers was checked by the simulations in Parts A and B.
- **Confirm the library version.** The timing libraries should match the ones used when the netlist was synthesized in Part B.

## One-line summary

The multiplier meets timing at all three corners and can run up to about 152 MHz in the worst case, with the hold margin at the fast corner being the thing to watch in Part D.