# TODO: this should use the interchange default connections API

conns = {}

conns["PLLE2_ADV"] = {
    "CLKFBIN": 0,
    "CLKIN1": 0,
    "CLKIN2": 0,
    "CLKINSEL": 0,
    "DCLK": 0,
    "DEN": 0,
    "DWE": 0,
    "PWRDWN": 0,
    "RST": 0
}

for i in range(7):
    conns["PLLE2_ADV"][f"DADDR[{i}]"] = 0
for i in range(16):
    conns["PLLE2_ADV"][f"DI[{i}]"] = 0

conns["IDELAYE2"] = {
    "REGRST": 0,
    "LDPIPEEN": 0,
    "CINVCTRL": 0,
    "DATAIN": 1,
}

conns["OSERDESE2"] = {
    "RST": 0,
    "OCE": 1,
    "TCE": 1
}

for i in range(1, 5):
    conns["OSERDESE2"][f"T{i}"] = 0
for i in range(1, 9):
    conns["OSERDESE2"][f"D{i}"] = 0

conns["ISERDESE2"] = {
    "DYNCLKDIVSEL": 1,
    "DYNCLKSEL": 1,
    "CE1": 1,
    "CE2": 1,
}

for cell_name, cell in ctx.cells:
    def_conns = conns.get(str(cell.type), {})
    for port, value in def_conns.items():
        if port in cell.ports and cell.ports[port].net != None and cell.ports[port].net.driver.cell != None:
            continue
        if port not in cell.ports:
            cell.addInput(port)
        if cell.ports[port].net != None:
            ctx.disconnectPort(cell_name, port)
        print(f"Default-connecting {cell_name}.{port} to constant {value}")
        ctx.connectPort(f"GLOBAL_LOGIC{value}", cell_name, port)
