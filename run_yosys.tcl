yosys -import
# Needed to get the FD blackbox
read_verilog -lib remap.v
synth_xilinx -flatten -nolutram -nowidelut -nosrl -nodsp -top $::env(TOP)
techmap -map remap.v
opt_expr -undriven
opt_clean

setundef -zero -params

write_json $::env(OUT_JSON)
