import json
import sys

with open(sys.argv[1]) as f:
	design = json.load(f)

for module in design["modules"].values():
	for cell_name, cell in module["cells"].items():
		if cell["type"] != "RAMB36E1":
			continue
		print(f"Fixing up RAMB36E1 {cell_name}")
		# When cascading not used - assume it isn't - Vivado expects the MSB to be 1. It auto-transforms but we don't leading to an inconsistency
		cell["connections"]["ADDRARDADDR"][15] = "1"
		cell["connections"]["ADDRBWRADDR"][15] = "1"

with open(sys.argv[2], "w") as f:
	print(json.dumps(design, sort_keys=True, indent=2), file=f)
