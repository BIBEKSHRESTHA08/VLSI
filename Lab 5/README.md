# VLSI Lab 5: CMOS Inverter and 2-input NAND

Custom (transistor level) design in Synopsys Custom Compiler. Drew the schematics and symbols, made testbenches and ran DC and transient sims in PrimeWave, then measured everything in WaveView. Used the SAED 90nm PDK.

CPE 527 VLSI Design, UAH, Fall 2026

Report: [vlsi_lab5 (1).pdf](vlsi_lab5%20(1).pdf)

## What I did

1. Tutorial: CMOS inverter (Wp = 0.5u, Wn = 0.25u), symbol, testbench, DC sweep and transient
2. Assignment 1: made the PMOS 0.25u (same as NMOS) to see how sizing changes VM and delay
3. Assignment 2: 2-input NAND gate, DC sweep and transient

## Results

All runs: VDD = 1.2 V, L = 0.1 um, TT corner, 25 C

| Design | VM | tpLH | Avg supply current |
|--------|----|------|--------------------|
| Inverter, Wp = 0.5u | ~0.60 V | 5.29 ps | 315 nA |
| Inverter, Wp = 0.25u | ~0.53 V | 6.19 ps | 215 nA |
| NAND2, all 0.5u | ~0.56 V | 8.12 ps | 698 nA |

## Notes

- Have to start cdesigner from the folder with lib.defs, otherwise the PDK libraries don't show up.
- Custom Compiler 2025 was the one running, so some menus are different from the tutorial. The DC sweep window has no Source option, so I put a variable (VIN_SWEEP) as the DC voltage of the input source and swept that.
- Making the PMOS smaller moved VM down and made the rising output slower.
- The NAND was slower and used more current than the inverter because more transistors are connected to its output.
