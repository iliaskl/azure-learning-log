#!/bin/bash
set -e

RG="rg-week4-lab"

# Delete the resource group and everything in it
az group delete --name $RG --yes

# Confirm it's gone (should print false)
az group exists --name $RG

echo "Done"