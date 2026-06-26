read_liberty /home/sarst/OpenROAD-flow-scripts/flow/platforms/nangate45/lib/NangateOpenCellLibrary_typical.lib
read_verilog SARV.v
link_design SARV_Core
read_sdc SARV.sdc
set_wire_load_mode top
read_vcd -scope tb/soc/Core SARV.vcd
report_power > report_power_2.txt
report_activity_annotation
