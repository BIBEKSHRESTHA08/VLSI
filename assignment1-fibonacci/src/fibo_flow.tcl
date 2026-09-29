# fibo_flow.tcl : Lab 2, Assignment 1 (FIBO)
# Variants: baseline 5/medium/medium, speed 3/high/low, area 5/medium/high
set VARIANT       "area"
set CLK_PERIOD    5
set MAP_EFFORT    medium
set AREA_EFFORT   high

set link_library [list \
  /apps/designlib/SAED90_EDK/SAED_EDK90nm/Digital_Standard_cell_Library/synopsys/models/saed90nm_max.db \
  /apps/designlib/SAED90_EDK/SAED_EDK90nm/Digital_Standard_cell_Library/synopsys/models/saed90nm_typ.db \
  /apps/designlib/SAED90_EDK/SAED_EDK90nm/Digital_Standard_cell_Library/synopsys/models/saed90nm_min.db]
set target_library [list \
  /apps/designlib/SAED90_EDK/SAED_EDK90nm/Digital_Standard_cell_Library/synopsys/models/saed90nm_typ.db]

define_design_lib WORK -path work
analyze -library WORK -format sverilog {src/assignment2.sv}
elaborate FIBO -architecture verilog -library WORK
current_design FIBO
link
check_design > reports/fibo_${VARIANT}_check_design.rpt

create_clock clk -name ideal_clock1 -period $CLK_PERIOD
set_input_delay  [expr {$CLK_PERIOD * 0.4}] -clock ideal_clock1 \
  [remove_from_collection [all_inputs] clk]
set_output_delay [expr {$CLK_PERIOD * 0.4}] [all_outputs]
set_max_area 0

compile -map_effort $MAP_EFFORT -area_effort $AREA_EFFORT

report_area        > reports/fibo_${VARIANT}_area.rpt
report_timing      > reports/fibo_${VARIANT}_timing.rpt
report_qor         > reports/fibo_${VARIANT}_qor.rpt
report_resources   > reports/fibo_${VARIANT}_resources.rpt
report_constraints > reports/fibo_${VARIANT}_constraints.rpt

write -format verilog -hierarchy -output output/fibo_${VARIANT}_synth.v
write_sdc constraints/fibo_${VARIANT}.sdc

report_timing
gui_start
# quit
