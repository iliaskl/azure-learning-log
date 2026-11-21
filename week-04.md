# Week 4 · Python + scripting (Nov 18–24)

## 1. 2026-11-19 · Week 4 · Python warm-up + Python meets Azure

**What I did:**
- Python warm-up in Cloud Shell: sum a list, count words, °F→°C function, loop over a list of dictionaries
- Connected GitHub to Cloud Shell (`gh auth login`, `git config`, cloned this repo)
- Created two resource groups, exported them with `az group list -o json > groups.json`
- Wrote `scripts/list_groups.py`: prints each group's name, location and provisioning state, with ⚠ next to any group outside West US 2
- Added `.gitignore` so `groups.json` never gets pushed
- Deleted both resource groups

**What confused me:**
- `list("My name is Ilias")` splits into characters (16), not words. `.split()` splits into words (4)
- I built one dictionary (name → location) instead of a list of dictionaries. A single dictionary can only hold two values per group; Azure gives many fields per group
- `{group['location']} == "eastus"` was always False. Outside an f-string, `{}` makes a **set**, not a value
- Typed Python straight into Bash (`import: command not found`). Python goes in a `.py` file; Bash runs it with `python3 file.py`

**What I figured out:**
- `az ... -o json` returns a **list of dictionaries**, one per resource
- Nested lookups go two levels down: `group['properties']['provisioningState']` opens `properties`, then takes the state out of it
- `with open(...)` + `json.load(f)` turns a JSON file into Python data
- Cloud Shell is ephemeral: anything not pushed to GitHub disappears with the session
- Each group's `id` contains my subscription ID, so raw Azure output stays out of a public repo
- `NetworkWatcherRG` was created automatically by Azure when I built my first virtual network in Week 2

**Customer sentence:**
> Rather than checking resources one by one in the portal, a short script can check all of them at once and flag anything that doesn't follow your rules.

---

## 2. 2026-11-21 · Week 4 · Deployment scripts

**What I did:**
- Wrote `scripts/create-lab.sh`: resource group + storage account (Standard_LRS, StorageV2), TLS 1.2 and 7-day blob soft delete set explicitly
- Wrote `scripts/delete-lab.sh`: deletes the group, then confirms with `az group exists` (prints `false`)
- Ran the full create → delete cycle; both worked
- Wrote `scripts/README.md`

**What confused me:**
- Hard-coded `--name stweek4` in step 2 while step 3 used `$SA` (`stweek4ilias`). Step 3 would have failed looking for an account that didn't exist
- Forgot `--min-tls-version TLS1_2` at first, so the CLI's insecure default would have come back
- Typed into the wrong editor tab (nearly overwrote `create-lab.sh`) and into the terminal instead of the editor
- Pasted the script into the live terminal: `set -e` turned on in my shell, a command failed, and **the whole Cloud Shell session closed**

**What I figured out:**
- A `.sh` file is just Bash commands saved so they run the same way every time
- `#!/bin/bash` = run with Bash; `set -e` = stop at the first failure (good in scripts, dangerous in the live terminal; `set +e` turns it off)
- Variables go at the top (`RG="..."`, used as `$RG`), so names change in one place and can't mismatch
- Each script needs its own variables; `delete-lab.sh` doesn't know what `create-lab.sh` set
- `--yes` stops `az group delete` from waiting for a y/n answer, which would hang an unattended script
- Deleting a resource group deletes everything inside it, but **not** Entra ID users/groups (they live in the tenant)
- Storage accounts: 3–24 lowercase letters/numbers, globally unique (the name becomes a URL)
- Microsoft's Cloud Adoption Framework has standard prefixes: `rg-`, `st`, `vnet-`, `vm-`, `nsg-`
- **Push before you run.** Then a closed session costs nothing

**Customer sentence:**
> Instead of someone clicking through the portal and hoping they remember every setting, a script builds it the same way every time, security settings included.

---

## Week 4 summary
- Done Nov 21, ~3 hrs (planned ~6)
- Biggest takeaway: scripts turn a deployment into something repeatable and checkable, and they're where secure settings get locked in instead of left to defaults
- Next: Week 5 (Nov 25 – Dec 1), monitoring + first KQL