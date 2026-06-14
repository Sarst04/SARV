read_liberty stdcells.lib
read_verilog SARV.v
link_design SARV_Core
read_sdc SARV.sdc
set_wire_load_mode top
read_vcd -scope tb/soc/core riscv32.vcd
report_power > report_power.txt
report_activity_annotation
