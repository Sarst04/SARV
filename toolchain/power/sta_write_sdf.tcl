read_liberty stdcells.lib
read_verilog SARV.v
link_design SARV_Core
read_sdc SARV.sdc
set_wire_load_mode top

write_sdf -include_typ SARV.sdf
