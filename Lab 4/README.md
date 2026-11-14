# VLSI Lab 4: Mult8U (8-bit unsigned multiplier)

Full design flow for an 8-bit serial-parallel multiplier, from RTL all the way to a routed layout and power analysis. Used SAED 90nm library.

CPE 527 VLSI Design, UAH, Fall 2026

Report: [report.pdf](report.pdf)

## What I did

1. Functional verification (VCS)
2. Synthesis (Design Compiler) + formal check (Formality)
3. Post-synthesis verification
4. Placement and routing (IC Compiler)
5. Post-P&R verification
6. Power analysis (PrimeTime)

## Results

Clock was 20 ns (50 MHz) for everything.

| Step | Result |
|------|--------|
| RTL sim | 33 tests pass, exhaustive test (all 65536 pairs) passes |
| Synthesis | slack +0.31 ns, area 1886.5 um^2, no latches |
| Formality | passed, 48/48 points |
| Post-syn sim | all pass |
| P&R | slack +15.51 ns, area 1916.0 um^2, 0 DRCs |
| Post-P&R sim | all pass |
| Power | ~15.9 uW |

## Notes

- First routing run had 23 DRC errors (same net spacing). Increased the repair loops to 10 and added another detail route pass, that fixed it.
- ICC 2025 GUI kept crashing when opening the layout so I took the layout screenshots in the 2023 version.
- Source code (datapath, control unit, top, testbench) is in the appendix of the report.
