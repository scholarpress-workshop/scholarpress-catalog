"""Verify all functions in REFERENCE.json have doc-comments. Exits 1 if any are missing."""
import json
import sys
from pathlib import Path

ref_path = Path(sys.argv[1]) / "REFERENCE.json"
if not ref_path.is_file():
    print(f"ERROR: {ref_path} not found")
    sys.exit(1)

data = json.loads(ref_path.read_text())
missing = []
for func in data["functions"]:
    desc = func.get("description", "").strip()
    if not desc:
        missing.append(func["name"])

if missing:
    print(f"ERROR: {len(missing)} functions missing doc-comments:")
    for name in missing:
        print(f"  - {name}")
    sys.exit(1)

print(f"All {len(data['functions'])} functions have doc-comments.")
