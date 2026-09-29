#############################################################
# adder_flow.tcl
# Lab 2, Assignment 2 -- 8-bit bit-serial adder (serial_adder)
# Design Compiler flow: analyze -> elaborate -> constrain ->
# compile -> reports -> netlist export -> Design Vision.
#
# Usage (from your assignment2/ directory):
#   dc_shell -f adder_flow.tcl
#
# Variants for the write-up (edit the four lines below, re-run):
#   baseline : CLK_PERIOD 5, MAP_EFFORT medium, AREA_EFFORT medium
#   speed    : CLK_PERIOD 3, MAP_EFFORT high,   AREA_EFFORT low
#   area     : CLK_PERIOD 5, MAP_EFFORT medium, AREA_EFFORT high
# Report and netlist names get the variant name, so runs
# do not overwrite each other.
#############################################################

# ---------- EDIT THESE FOUR LINES PER VARIANT ----------
set VARIANT       "baseline"
set CLK_PERIOD    5
set MAP_EFFORT    medium
set AREA_EFFORT   medium
# ----------------------------------------------------------

# ---- library setup ----
set link_library [list \
  /apps/designlib/SAED90_EDK/SAED_EDK90nm/Digital_Standard_cell_Library/synopsys/models/saed90nm_max.db \
  /apps/designlib/SAED90_EDK/SAED_EDK90nm/Digital_Standard_cell_Library/synopsys/models/saed90nm_typ.db \
  /apps/designlib/SAED90_EDK/SAED_EDK90nm/Digital_Standard_cell_Library/synopsys/models/saed90nm_min.db]

set target_library [list \
  /apps/designlib/SAED90_EDK/SAED_EDK90nm/Digital_Standard_cell_Library/synopsys/models/saed90nm_typ.db]

# ---- TA note: never use BSLEX cells (they break tri-states) ----
# This design has no tri-state, so these lines are just a safety net.
set_dont_use [get_lib_cells */BSLEX1]
set_dont_use [get_lib_cells */BSLEX2]
set_dont_use [get_lib_cells */BSLEX4]

# ---- working library ----
define_design_lib WORK -path work

# ---- load design (top module = serial_adder) ----
analyze -library WORK -format sverilog {src/assignment2.sv}
elaborate serial_adder -architecture verilog -library WORK
current_design serial_adder
link

check_design > reports/adder_${VARIANT}_check_design.rpt

# ---- constraints ----
create_clock clk -name ideal_clock1 -period $CLK_PERIOD
set_input_delay  [expr {$CLK_PERIOD * 0.4}] -clock ideal_clock1 \
  [remove_from_collection [all_inputs] clk]
set_output_delay [expr {$CLK_PERIOD * 0.4}] [all_outputs]
set_max_area 0

# ---- compile ----
compile -map_effort $MAP_EFFORT -area_effort $AREA_EFFORT

# ---- reports (auto-suffixed with the variant name) ----
report_area        > reports/adder_${VARIANT}_area.rpt
report_timing      > reports/adder_${VARIANT}_timing.rpt
report_qor         > reports/adder_${VARIANT}_qor.rpt
report_resources   > reports/adder_${VARIANT}_resources.rpt
report_constraints > reports/adder_${VARIANT}_constraints.rpt

# ---- netlist export (-hierarchy keeps datapath + control_unit) ----
write -format verilog -hierarchy -output output/adder_${VARIANT}_synth.v
write -format ddc     -hierarchy -output output/adder_${VARIANT}.ddc
write_sdc constraints/adder_${VARIANT}.sdc

puts "\n=== Variant '${VARIANT}' complete: period=${CLK_PERIOD}ns, map_effort=${MAP_EFFORT}, area_effort=${AREA_EFFORT} ==="
puts "=== Reports written to reports/adder_${VARIANT}_*.rpt ==="
puts "=== Netlist written to output/adder_${VARIANT}_synth.v ==="

# ---- show critical path on screen, then open Design Vision ----
report_timing
gui_start

# quit
