LITEX_TARGET=digilent_arty
LITEX_ARGS=--cpu-type picorv32 --cpu-variant minimal --sys-clk-freq 50e6 --synth-mode yosys
BUILD_DIR=build/${LITEX_TARGET}/gateware
TOP_VERILOG=${BUILD_DIR}/${LITEX_TARGET}.v

TESTS=${HOME}/fpga-interchange-tests
SCHEMA=${TESTS}/third_party/fpga-interchange-schema/interchange
DEVICE=${TESTS}/build/devices/xc7a35t/xc7a35t.device
CHIPDB=${TESTS}/build/devices/xc7a35t/xc7a35t.bin
PACKAGE=csg324

RAPIDWRIGHT=${HOME}/RapidWright

all: ${BUILD_DIR}/${LITEX_TARGET}.dcp

${TOP_VERILOG}:
	python3 -m litex_boards.targets.${LITEX_TARGET} ${LITEX_ARGS}

${BUILD_DIR}/${LITEX_TARGET}.json: ${TOP_VERILOG}
	# Determine dependencies and run Yosys
	TOP=${LITEX_TARGET} VERILOG=$^ OUT_JSON=$@ yosys -ql ${BUILD_DIR}/${LITEX_TARGET}.yosys.log -p "tcl run_yosys.tcl"

${BUILD_DIR}/${LITEX_TARGET}.netlist: ${BUILD_DIR}/${LITEX_TARGET}.json
	python3 -m fpga_interchange.yosys_json --schema_dir ${SCHEMA} --device ${DEVICE} --top ${LITEX_TARGET} $^ $@

${BUILD_DIR}/${LITEX_TARGET}.patched.xdc: ${BUILD_DIR}/${LITEX_TARGET}.xdc
	grep 'set_property.*get_ports' $^ > $@  

${BUILD_DIR}/${LITEX_TARGET}.phys: ${BUILD_DIR}/${LITEX_TARGET}.netlist ${BUILD_DIR}/${LITEX_TARGET}.patched.xdc
	nextpnr-fpga_interchange --chipdb ${CHIPDB} --package ${PACKAGE} --netlist ${BUILD_DIR}/${LITEX_TARGET}.netlist --xdc ${BUILD_DIR}/${LITEX_TARGET}.patched.xdc --phys $@ --pre-pack fixup_obufds.py --pre-place default_ports.py

${BUILD_DIR}/${LITEX_TARGET}.dcp: ${BUILD_DIR}/${LITEX_TARGET}.phys
	RAPIDWRIGHT_PATH=${RAPIDWRIGHT} ${RAPIDWRIGHT}/scripts/invoke_rapidwright.sh  com.xilinx.rapidwright.interchange.PhysicalNetlistToDcp ${BUILD_DIR}/${LITEX_TARGET}.netlist ${BUILD_DIR}/${LITEX_TARGET}.phys ${BUILD_DIR}/${LITEX_TARGET}.xdc $@

clean:
	rm -rf build/

.PHONY: clean

