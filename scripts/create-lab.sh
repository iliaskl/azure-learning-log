#!/bin/bash          # first line: tells the system to run this file with Bash
set -e               # stop the script the moment any command fails

RG="rg-week4-lab"    # a Bash variable: no spaces around =
echo "Using $RG"     # read it back with $

LOCATION="westus2"
SA="stweek4ilias"

# 1. Create the resource group
az group create --name $RG --location $LOCATION

# 2. Create the storage account (Standard_LRS, StorageV2, TLS 1.2)
az storage account create --name $SA --resource-group $RG --location $LOCATION \
  --sku Standard_LRS --kind StorageV2 --min-tls-version TLS1_2

# 3. Turn on blob soft delete (7 days)
az storage account blob-service-properties update \
  --account-name $SA \
  --resource-group $RG \
  --enable-delete-retention true \
  --delete-retention-days 7

echo "Done"