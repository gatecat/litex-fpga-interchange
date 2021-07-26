yosys -import
read_verilog $::env(VERILOG)
read_verilog [exec python3 -c "import pythondata_cpu_picorv32, os; print(os.path.dirname(pythondata_cpu_picorv32.__file__))"]/verilog/picorv32.v
# Needed to get the FD blackbox
read_verilog -lib remap.v
synth_xilinx -flatten -nolutram -nowidelut -nosrl -nodsp -top $::env(TOP)
techmap -map remap.v
opt_expr -undriven
opt_clean

setundef -zero -params

write_json $::env(OUT_JSON)
