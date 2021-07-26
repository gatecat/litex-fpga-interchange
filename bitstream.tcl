open_checkpoint $::env(DCP_FILE)
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]

set_property SEVERITY Warning [get_drc_checks {PLHOLDVIO-2}]
set_property SEVERITY Warning [get_drc_checks {REQP-85}]
set_property SEVERITY Warning [get_drc_checks {REQP-159}]

set_property INTERNAL_VREF 0.675 [get_iobanks 34]

write_bitstream -force $::env(BIT_FILE)
