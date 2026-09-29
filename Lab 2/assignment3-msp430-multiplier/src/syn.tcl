# =================================================================
# DC synthesis script: Assignment 3 (MSP430 hardware multiplier)
# Run from inside assignment3/ :   dc_shell -f syn.tcl
# =================================================================

# ---- clock period in ns (change this to experiment) ----
set CLK_PERIOD 7

# ---- search path and work library ----
lappend search_path src/
define_design_lib WORK -path work

# ---- technology libraries ----
set LIB_DIR /apps/designlib/SAED90_EDK/SAED_EDK90nm/Digital_Standard_cell_Library/synopsys/models
set link_library   [list $LIB_DIR/saed90nm_max.db $LIB_DIR/saed90nm_typ.db $LIB_DIR/saed90nm_min.db]
set target_library [list $LIB_DIR/saed90nm_typ.db]

# ---- TA fix: never use BSLEX cells for tri-states ----
set_dont_use [get_lib_cells */BSLEX1]
set_dont_use [get_lib_cells */BSLEX2]
set_dont_use [get_lib_cells */BSLEX4]

# ---- load design ----
analyze -library WORK -format sverilog assignment3.sv
elaborate -architecture verilog -library WORK mult430
check_design > reports/synth_check_design.rpt

# ---- constraints ----
create_clock clk -name ideal_clock1 -period $CLK_PERIOD
set_input_delay  2.0 [remove_from_collection [all_inputs] clk]
set_output_delay 2.0 [all_outputs]
set_max_area 0

# ---- synthesize ----
compile -map_effort medium -area_effort medium

# ---- reports ----
report_area        > reports/assignment3_area.rpt
report_timing      > reports/assignment3_timing.rpt
report_resources   > reports/assignment3_resources.rpt
report_constraints > reports/assignment3_constraints.rpt
report_qor         > reports/assignment3_qor.rpt

# ---- outputs ----
write_sdc constraints/assignment3.sdc
write -f ddc -hierarchy -output output/assignment3.ddc
write -hierarchy -format verilog -output output/assignment3_synth.v

# ---- show critical path, open Design Vision ----
report_timing
gui_start
