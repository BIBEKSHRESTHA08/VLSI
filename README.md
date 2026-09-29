# VLSI Lab 2: RTL to Gates with Synopsys Design Compiler

Three small digital designs written in SystemVerilog, verified with Synopsys VCS, synthesized to the
SAED 90 nm standard-cell library with Design Compiler, and verified again at gate level.

Course project for CPE 527 VLSI Design, University of Alabama in Huntsville (Fall 2026).

## Projects

| # | Design | What it shows | Result |
|---|--------|---------------|--------|
| 1 | [16-bit Fibonacci generator](assignment1-fibonacci/report.pdf) | Speed vs. area synthesis, critical path, a testbench race | 4.35 ns critical path, ~225 MHz, speed run +20% area for 31% less delay |
| 2 | [8-bit bit-serial adder](assignment2-serial-adder/report.pdf) | Datapath + FSM, one full adder over 8 clocks | 23 flip-flops, 1268 cell area, +1.77 ns slack at 5 ns |
| 3 | [MSP430 hardware multiplier](assignment3-msp430-multiplier/report.pdf) | Memory-mapped MPY/MPYS/MAC/MACS, tri-state bus, 228-test testbench | 7 ns (~143 MHz), 881 cells, 228/228 tests pass on RTL and gates |

## Flow

```
SystemVerilog RTL -> VCS functional sim -> Design Compiler (analyze, elaborate, constrain, compile)
                  -> area / timing / QoR reports -> netlist -> VCS gate-level sim -> Design Vision
```

## Repository layout

```
assignmentN-*/
  report.tex     LaTeX source of the write-up
  report.pdf     compiled report
  figures/       diagrams and tool screenshots
  src/           RTL, testbench and Design Compiler script
```

## Tools

- Synopsys VCS V-2023.12-SP2 and DVE
- Synopsys Design Compiler V-2023.12-SP5 and Design Vision
- SAED 90 nm EDK standard cells (typical corner)

## Building the reports

```bash
cd assignment1-fibonacci && pdflatex report.tex && pdflatex report.tex
```

Each `report.tex` is self-contained and reads its code listings from `src/`.

## Running the designs (on a machine with the Synopsys tools)

```bash
# RTL simulation
vcs -sverilog -full64 -debug_access+all src/<design>.sv src/<design>_tb.sv -o f_sim/sim.simv
./f_sim/sim.simv

# Synthesis (reports, netlist, then Design Vision)
dc_shell -f src/<flow>.tcl

# Gate-level simulation
vcs -sverilog -full64 src/<design>_tb.sv output/<netlist>.v <path>/saed90nm.v -o ps_sim/sim.simv
./ps_sim/sim.simv
```

## Things I learned

- The clock constraint decides the hardware: the same adder code became a ripple adder or a faster adder depending on the target.
- Faster costs area, and flip-flop area is fixed by the RTL.
- In serial designs, control logic can be slower than the arithmetic.
- Change testbench inputs away from the sampling clock edge, or RTL and gate-level results can disagree.
- Check the netlist for known bad cells (here, BSLEX tri-states) and always re-run the testbench on the gates.

## Author

Bibek Shrestha
