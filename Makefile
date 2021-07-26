LITEX_TARGET=digilent_arty
LITEX_ARGS=--cpu-type picorv32 --cpu-variant minimal --sys-clk-freq 50e6 --synth-mode yosys
BUILD_DIR=build/${LITEX_TARGET}/gateware
TOP_SCRIPT=${BUILD_DIR}/${LITEX_TARGET}.ys

TESTS=${HOME}/fpga-interchange-tests
SCHEMA=${TESTS}/third_party/fpga-interchange-schema/interchange
DEVICE=${TESTS}/build/devices/xc7a35t/xc7a35t.device
CHIPDB=${TESTS}/build/devices/xc7a35t/xc7a35t.bin
PACKAGE=csg324

all: ${BUILD_DIR}/${LITEX_TARGET}.phys

${TOP_SCRIPT}:
	python3 -m litex_boards.targets.${LITEX_TARGET} ${LITEX_ARGS}

${BUILD_DIR}/${LITEX_TARGET}.json: ${TOP_SCRIPT}
	# Determine dependencies and run Yosys
	TOP=${LITEX_TARGET} OUT_JSON=$@ yosys -ql ${BUILD_DIR}/${LITEX_TARGET}.yosys.log -p "tcl run_yosys.tcl" $(shell grep -Po '(?<=read_verilog )[^ ]*$$' $^)

${BUILD_DIR}/${LITEX_TARGET}.netlist: ${BUILD_DIR}/${LITEX_TARGET}.json
	python3 -m fpga_interchange.yosys_json --schema_dir ${SCHEMA} --device ${DEVICE} --top ${LITEX_TARGET} $^ $@

${BUILD_DIR}/${LITEX_TARGET}.patched.xdc: ${BUILD_DIR}/${LITEX_TARGET}.xdc
	grep 'set_property.*get_ports' $^ > $@  

${BUILD_DIR}/${LITEX_TARGET}.phys: ${BUILD_DIR}/${LITEX_TARGET}.netlist ${BUILD_DIR}/${LITEX_TARGET}.patched.xdc
	nextpnr-fpga_interchange --chipdb ${CHIPDB} --package ${PACKAGE} --netlist ${BUILD_DIR}/${LITEX_TARGET}.netlist --xdc ${BUILD_DIR}/${LITEX_TARGET}.patched.xdc --phys $@

clean:
	rm -rf build/

.PHONY: clean

