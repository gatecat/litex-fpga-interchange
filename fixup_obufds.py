# OBUFDS is currently broken in RapidWright
# rewriting to OBUFTDS is non-trivial because we have to route through the SERDES

for cell_name, cell in ctx.cells:
	if cell.type != "OBUFDS":
		continue
	print(f"Rewriting OBUFDS {cell_name} to OBUFTDS")
	cell.type = "OBUFTDS"

	serdes = cell.ports["I"].net.driver.cell
	assert serdes.type == "OSERDESE2", serdes.type
	serdes.setParam("DATA_RATE_TQ", "BUF")

	net = f"{cell_name}$T$rewritten"
	ctx.createNet(net)
	cell.addInput("T")
	ctx.connectPort(net, cell_name, "T")
	if "TQ" not in serdes.ports:
		serdes.addOutput("TQ")
	else:
		assert len(serdes.ports["TQ"].net.users) == 0
		ctx.disconnectPort(serdes.name, "TQ")
	ctx.connectPort(net, serdes.name, "TQ")
	# default_ports will set T1 of the SERDES to GND
