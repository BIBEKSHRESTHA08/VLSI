# VLSI Lab 3: Placement and Routing with Synopsys IC Compiler

Synthesized designs from Lab 2 are taken through floorplanning, power planning, placement,
clock tree synthesis and routing in IC Compiler, using the SAED 90 nm standard-cell library.

Course project for CPE 527 VLSI Design, University of Alabama in Huntsville (Fall 2026).

## Projects

| # | Design | What it shows | Result |
|---|--------|---------------|--------|
| 0 | [4-bit gray counter (tutorial)](tutorial-gray-counter/report.pdf) | Full ICC flow, power grid, routed layout, inside the cells | _fill in: slack after route, utilization, DRCs_ |
| 1 | [16-bit Fibonacci generator](assignment1-fibonacci/report.pdf) | Verilog netlist import, Lab 2 critical path traced cell by cell in the layout | _fill in: post-route slack at 5 ns, utilization, DRCs_ |
| 2 | [8-bit bit-serial adder](assignment2-serial-adder/report.pdf) | Small design: core dwarfed by the I/O margin, all 23 flip-flops found by name | _fill in: post-route slack at 5 ns, utilization, DRCs_ |
| 3 | [MSP430 hardware multiplier](assignment3-msp430-multiplier/report.pdf) | 881-cell hierarchical design, tri-state bus, BSLEX ban carried into ICC, typ vs max corner | _fill in: post-route slack at 7 ns, utilization, DRCs_ |

## Flow

```
Lab 2 .ddc + .sdc -> setup (Milkyway lib, TLU+) -> floorplan -> power rings + straps
                  -> place_opt -> clock_opt -> fillers -> route_opt -> verify_zrt_route
                  -> reports, parasitics (.sbpf), final netlist (.v)
```

## Repository layout

```
<design folder>/
  report.tex       LaTeX source of the write-up
  report.pdf       compiled report
  figures/         diagrams and ICC screenshots
  src/             RTL, testbench and ICC script
  make_figures.py  (where present) draws the diagrams in figures/
```

## Tools

- Synopsys IC Compiler V-2023.12-SP5
- SAED 90 nm EDK (Milkyway reference library, 1P9M technology file, TLU+ models)

## Running the flow (on a machine with the Synopsys tools)

```bash
export PATH=$PATH:/apps/synopsys2023/icc/V-2023.12-SP5/bin
cd syn_tut/icc                  # one level below output/ and constraints/
icc_shell -shared_license -f ../src/icc_flow.tcl | tee icc_output.txt
```

For the Lab 2 designs, each script runs from an `icc_assignmentN/` folder one level below that design's
`output/` and `constraints/`, for example `icc_shell -shared_license -f icc_mult.tcl | tee icc_mult.log`.

`create_mw_lib` only runs once. To reopen the finished layout later:

```
open_mw_lib gray4bcntLIB
open_mw_cel gray4bcnt_route
```

## Building the report

```bash
(cd tutorial-gray-counter && python3 make_figures.py && pdflatex report.tex && pdflatex report.tex)
(cd assignment1-fibonacci && python3 make_figures.py && pdflatex report.tex && pdflatex report.tex)
(cd assignment2-serial-adder && pdflatex report.tex && pdflatex report.tex)
(cd assignment3-msp430-multiplier && pdflatex report.tex && pdflatex report.tex)
```

## Author

Bibek Shrestha
