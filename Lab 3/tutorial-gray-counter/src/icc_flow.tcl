gui_start
set_app_var search_path /apps/designlib/SAED90_EDK/SAED_EDK90nm/Digital_Standard_cell_Library/synopsys/models/
set_app_var target_library "saed90nm_max.db"
set_app_var link_library "* saed90nm_max.db"
create_mw_lib -technology "/apps/designlib/SAED90_EDK/SAED_EDK90nm/Technology_Kit/milkyway/saed90nm_icc_1p9m.tf" -mw_reference_library "/apps/designlib/SAED90_EDK/SAED_EDK90nm/Digital_Standard_cell_Library/process/astro/fram/saed90nm/" "gray4bcntLIB"
open_mw_lib gray4bcntLIB
import_designs "../output/gray_counter.ddc" -format ddc -top "gray_counter" -cel "gray_counter"
read_sdc ../constraints/gray_counter.sdc
set_tlu_plus_files -max_tluplus "/apps/designlib/SAED90_EDK/SAED_EDK90nm/Technology_Kit/starrcxt/tluplus/saed90nm_1p9m_1t_Cmax.tluplus" -min_tluplus "/apps/designlib/SAED90_EDK/SAED_EDK90nm/Technology_Kit/starrcxt/tluplus/saed90nm_1p9m_1t_Cmin.tluplus" -tech2itf_map "/apps/designlib/SAED90_EDK/SAED_EDK90nm/Digital_Standard_cell_Library/process/astro/tech/tech2itf.map"
save_mw_cel -as gray4bcnt_init
create_floorplan -core_utilization 0.6 -start_first_row -left_io2core "30" -bottom_io2core "30" -right_io2core "30" -top_io2core "30"
derive_pg_connection -power_net "VDD" -power_pin "VDD" -ground_net "VSS" -ground_pin "VSS" -create_ports "top"
create_rectangular_ring -nets {VSS} -left_offset 0.5 -left_segment_layer M6 -left_segment_width 1.0 -extend_ll -extend_lh -right_offset 0.5 -right_segment_layer M6 -right_segment_width 1.0 -extend_rl -extend_rh -bottom_offset 0.5 -bottom_segment_layer M7 -bottom_segment_width 1.0 -extend_bl -extend_bh -top_offset 0.5 -top_segment_layer M7 -top_segment_width 1.0 -extend_tl -extend_th
create_rectangular_ring -nets {VDD} -left_offset 1.8 -left_segment_layer M6 -left_segment_width 1.0 -extend_ll -extend_lh -right_offset 1.8 -right_segment_layer M6 -right_segment_width 1.0 -extend_rl -extend_rh -bottom_offset 1.8 -bottom_segment_layer M7 -bottom_segment_width 1.0 -extend_bl -extend_bh -top_offset 1.8 -top_segment_layer M7 -top_segment_width 1.0 -extend_tl -extend_th
create_power_strap -nets {VSS} -layer M6 -direction vertical -width 3
create_power_strap -nets {VDD} -layer M6 -direction vertical -width 3
create_fp_placement
place_opt
clock_opt
save_mw_cel -as gray4bcnt_cts_opt
report_placement_utilization > ../output/gray4bcnt_cts_util.rpt
report_qor > ../output/gray4bcnt_cts_qor.rpt
report_timing -delay max -max_paths 5 > ../output/gray4bcnt_cts.setup.rpt
report_timing -delay min -max_paths 5 > ../output/gray4bcnt_cts.hold.rpt
insert_stdcell_filler -cell_with_metal "SHFILL2" -cell_without_metal "SHFILL2" -connect_to_power {VDD} -connect_to_ground {VSS}
route_opt
verify_zrt_route
report_placement_utilization > ../output/gray4bcnt_route_util.rpt
report_qor > ../output/gray4bcnt_route_qor.rpt
report_timing -delay max -max_paths 5 > ../output/gray4bcnt_route.setup.rpt
report_timing -delay min -max_paths 5 > ../output/gray4bcnt_route.hold.rpt
extract_rc -coupling_cap
write_parasitics -format SBPF -output ../output/gray4bcnt.output.sbpf
write_verilog ../output/gray4bcntLIB.output.v
save_mw_cel -as gray4bcnt_route
close_mw_cel