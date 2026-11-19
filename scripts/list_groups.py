import json                      # Python's built-in JSON reader

with open("groups.json") as f:   # open the file (it closes automatically after this block)
    groups = json.load(f)        # turn the JSON text into a Python list of dicts


for group in groups:
    state = group['properties']['provisioningState']
    if group['location'] != "westus2":
        print(f"{group['name']} - {group['location']} - {state} ⚠")
    else :
        print(f"{group['name']} - {group['location']} - {state}")