## 2026-11-04 · Week 2 · Virtual networks (Learn module + lab)

**What I did:**
- Finished "Introduction to Azure Virtual Networks" on Microsoft Learn
- Lab: built 3 VNets for a fictional company (Contoso) in 3 regions, 9 subnets total
- CoreServicesVnet in the portal; ManufacturingVnet and ResearchVnet with the Azure CLI
- Verified with `az network vnet list` and deleted everything with `az group delete`

**What confused me:**
- The portal said "Validation passed" but the deployment failed, and the Errors panel was empty
- My `--query` for subnet ranges came back blank

**What I figured out:**
- The real error was in the notifications (bell icon): a policy violation. My free
  subscription blocks some regions (West Europe failed; North Europe and Southeast Asia worked)
- Validation checks my settings; policy is checked at deployment
- Failed deployments: check the resource group's Deployments blade or the notifications
- Portal-created subnets store the range in `addressPrefixes` (a list); CLI-created ones use
  `addressPrefix`. When a query is blank, look at the raw JSON for the real field name
- The default subnet has to be deleted if it overlaps a subnet I need
- GatewaySubnet is a reserved name; VPN gateways only deploy there
- Subnets were spaced out (10, 20, 30) to leave room for growth
- A resource group is just a folder; its resources can be in any region

**What I'd explain to a customer in one sentence:**
A virtual network is your own private network in Azure, and subnets split it into
sections so you can group and protect different parts of your system separately.

**Next session:**
CIDR notation, the paper exercise (split 10.0.0.0/16 into three /24s), then build vnet-lab.
