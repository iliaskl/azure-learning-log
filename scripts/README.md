# scripts

Small scripts from Week 4 of my Azure learning log: Bash scripts that build and tear down a lab environment, and a Python script that reads Azure data.

## Files

| File | What it does | How to run |
|---|---|---|
| `create-lab.sh` | Creates a resource group and a storage account with secure settings | `bash create-lab.sh` |
| `delete-lab.sh` | Deletes the resource group (and everything in it), then confirms it's gone | `bash delete-lab.sh` |
| `list_groups.py` | Reads `groups.json` and prints each resource group's name, location and state, flagging any outside West US 2 | `az group list -o json > groups.json` then `python3 list_groups.py` |

Requires the Azure CLI (signed in) and Python 3. Tested in Azure Cloud Shell (Bash).

## Design decisions

- **Security settings are set explicitly.** In Week 3 I found the Azure CLI's defaults are weaker than the portal's (minimum TLS 1.0 vs 1.2, blob soft delete off vs on). `create-lab.sh` sets TLS 1.2 and 7-day soft delete itself instead of trusting defaults.
- **Names live in variables at the top**, so the lab can be changed or reused by editing one line, and every command uses the same names.
- **`set -e`** stops the script at the first failure, so a broken step doesn't leave half-built resources behind.
- **Names follow Microsoft's Cloud Adoption Framework abbreviations** (`rg-` for resource groups, `st` for storage accounts).
- **`groups.json` is excluded via `.gitignore`** because it contains my subscription ID and this repo is public.