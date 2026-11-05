# Week 2 · Networking

**Contents**
1. Session 1 (Nov 4): Virtual networks module + Contoso lab
2. Session 2 (Nov 5): CIDR and subnetting
3. Session 3 (Nov 5): Build vnet-lab, ping between VMs, break it with an NSG
4. Reference: key concepts explained (read this to refresh)
5. Commands cheat sheet

---

## 1. 2026-11-04 · Week 2 · Virtual networks (Learn module + lab)

**What I did:**
- Finished "Introduction to Azure Virtual Networks" on Microsoft Learn (~2 hrs; it's from the AZ-700 path, so deeper than this week needed)
- Lab (M01 Unit 4): built 3 VNets for a fictional company (Contoso) in 3 regions, 9 subnets total
- CoreServicesVnet in the portal; ManufacturingVnet and ResearchVnet with the Azure CLI
- Verified with `az network vnet list` and deleted everything with `az group delete`
- Skipped Unit 6 (DNS) and Unit 8 (global peering): revisit in Stage 1 (AZ-104 networking, ~Feb 10–23)

**What confused me:**
- The portal said "Validation passed" but the deployment failed, and the Errors panel was empty
- My `--query` for subnet ranges came back blank

**What I figured out:**
- The real error was in the notifications (bell icon): **policy violation**. My free subscription only allows certain regions (West Europe failed; East US, North Europe and Southeast Asia worked)
- Validation checks my settings; **policy is checked at deployment**
- For a failed deployment, check the notifications or the resource group's **Deployments** blade
- Portal-created subnets store their range in `addressPrefixes` (a list); CLI-created ones use `addressPrefix`. **When a query comes back blank, look at the raw JSON for the real field name**
- Delete the portal's default subnet if it overlaps a subnet I need (Azure won't allow overlapping subnets)
- `GatewaySubnet` is a reserved name; VPN gateways only deploy into a subnet with exactly that name
- Contoso's subnets were spaced out (10, 20, 30) to leave room for growth
- A resource group is just a folder; what's inside can be in any region
- `NetworkWatcherRG` gets created automatically the first time I build a VNet in a region. It's free; leave it

---

## 2. 2026-11-05 · Week 2 · CIDR and subnetting

### The big picture
- **VNet = the building.** 10.0.0.0/16 is a building with 65,536 apartments.
- **Subnets = the floors.** I decide how big each floor is; floors can't overlap.
- **The /number sets the size. A bigger number means a smaller space.** /16 is the whole building, /24 is one floor, /28 is a small hallway.

### Where the numbers come from
- An IP address has **four numbers** (like 10.0.5.200). **Each one goes from 0 to 255**, so 256 options each, never higher.
- **/16 locks the first two numbers** (10.0), so two are free: 256 × 256 = **65,536** addresses (10.0.0.0 → 10.0.255.255)
- **/24 locks the first three numbers** (10.0.1), so one is free: **256** addresses (10.0.1.0 → 10.0.1.255)
- Each number is 8 bits, so going from /16 to /24 is a jump of 8. The "clean" sizes are /8, /16, /24, /32; everything in between splits a number partway.

### Halving ladder (the easy way to get any size)
Every +1 on the slash cuts the size in half:

| CIDR | Addresses | Usable in Azure |
|---|---|---|
| /16 | 65,536 | 65,531 |
| /23 | 512 | 507 |
| /24 | 256 | 251 |
| /25 | 128 | 123 |
| /26 | 64 | 59 |
| /27 | 32 | 27 |
| /28 | 16 | 11 |
| /29 | 8 | 3 |

(The formula behind it: 2^(32 − the number).)

### The two rules
1. **Range = everything.** First address = the CIDR address. **Last address = start + total − 1** (−1 because counting starts at 0).
2. **Usable in Azure = total − 5.** Reserved addresses are still *in* the range; they're just taken.

**What Azure reserves** (example 10.0.1.0/24):

| Address | Used for |
|---|---|
| 10.0.1.0 | Network address (the subnet's "name") |
| 10.0.1.1 | Default gateway (the exit door out of the subnet) |
| 10.0.1.2 | DNS |
| 10.0.1.3 | DNS |
| 10.0.1.255 | Broadcast (the last address) |

So **the first VM in a subnet gets start + 4** (e.g., 10.0.1.4). Confirmed in Session 3: vm-a got 10.0.1.4 and vm-b got 10.0.2.4.

**Regular networking vs. Azure:**
- Regular networking reserves 2 (first + last), so usable = total − 2
- Azure reserves 5 (first 4 + last), so usable = total − 5
- Subnet calculators use the regular rule: their "End Address" is the last *usable* address; the **Broadcast Address** column is the true end of the range

### When a subnet is bigger than 256 (the odometer)
No single number goes above 255; it rolls over into the next number, like an odometer:
```
10.1.0.0   → 10.1.0.255
10.1.1.0   → 10.1.1.255
   ...
10.1.255.0 → 10.1.255.255   ← end of 10.1.0.0/16
```
- So a /16 ends at **10.1.255.255**, not "10.1.0.65,535"
- Example: **10.0.4.0/23** = 512 addresses = two /24s back to back → 10.0.4.0 to **10.0.5.255**
- Those 256 rows are what's *available*; the subnets are what I *choose* to use. Contoso had 256 possible /24s in 10.20.0.0/16 but only carved out 4 and left the rest for growth.

### Using the subnet calculator
- **Mask bits** = the /number of the big network (16)
- **Subnet bits** = how many times to cut it in half. 1 → 2 pieces (/17); 8 → 256 pieces of /24 (16 + 8 = 24)
- Ignore the bit-by-bit table for now

### Paper exercise: 10.0.0.0/16 split into three /24s

| subnet | cidr | first address | last address | usable in Azure |
|---|---|---|---|---|
| web | 10.0.1.0/24 | 10.0.1.0 | 10.0.1.255 | 251 |
| app | 10.0.2.0/24 | 10.0.2.0 | 10.0.2.255 | 251 |
| database | 10.0.3.0/24 | 10.0.3.0 | 10.0.3.255 | 251 |

### Contoso's GatewaySubnet

| subnet | cidr | first address | last address | usable in Azure |
|---|---|---|---|---|
| GatewaySubnet | 10.20.0.0/27 | 10.20.0.0 | 10.20.0.31 | 27 |

### Practice problems

| cidr | first address | last address | usable in Azure | first VM gets |
|---|---|---|---|---|
| 10.0.5.0/26 | 10.0.5.0 | 10.0.5.63 | 59 | 10.0.5.4 |
| 10.1.0.0/16 | 10.1.0.0 | 10.1.255.255 | 65,531 | 10.1.0.4 |
| 192.168.10.0/28 | 192.168.10.0 | 192.168.10.15 | 11 | 192.168.10.4 |
| 10.0.7.64/27 | 10.0.7.64 | 10.0.7.95 | 27 | 10.0.7.68 |

**Mistakes I made and what fixed them:**
- I subtracted reserved addresses from the range *and* from the usable count, removing them twice. Fix: range = everything; only subtract for usable.
- I wrote 10.1.0.65,535 as a last address. Fix: no number goes above 255; it rolls over into the next number.

---

## 3. 2026-11-05 · Week 2 · Build vnet-lab, ping, break it with an NSG

**What I built:**
```
vnet-lab  10.0.0.0/16  (West US 2, resource group rg-week2)
├── subnet-a  10.0.1.0/24
│     └── vm-a  private 10.0.1.4 · public 20.236.8.104 · NSG: vm-aNSG
└── subnet-b  10.0.2.0/24
      └── vm-b  private 10.0.2.4 · no public IP · NSG: vm-bNSG
```
- vm-b has **no public IP** on purpose, like a backend database: only reachable from inside the network
- `az vm create` also created, for each VM: a network interface (NIC), an NSG, an OS disk, and (for vm-a) a public IP

**What I did:**
1. Created the VNet and two subnets with the CLI
2. Created two Ubuntu VMs, one per subnet
3. SSH'd into vm-a and pinged vm-b: **4/4 replies, 0% loss** (~0.8 ms)
4. Read vm-b's NSG rules and found the rule that allowed it: **AllowVnetInBound (priority 65000)**
5. Added a deny rule on vm-b's NSG: deny ICMP from 10.0.1.0/24, priority 100
6. Pinged again: **hung, 100% packet loss**. The block worked
7. Deleted the rule, pinged again: **4/4 replies**. Back to normal
8. Deleted rg-week2

**What confused me / what went wrong:**
- **B1s was out of capacity** in West US 2 (`SkuNotAvailable`). Switched to `Standard_B2ats_v2`
- The CLI error was a huge Python traceback. The useful part was only the `Code:` and `Message:` lines
- I typed `--Standard_B2ats_v2` instead of `--size Standard_B2ats_v2`. Error: `unrecognized arguments`
- Cloud Shell timed out when I clicked away. My resources were fine (they live in Azure, not in Cloud Shell), and luckily my SSH key survived
- I typed `<vm-b's private IP>` literally. `<` is a special character in the shell, so it waited for more input (`>` prompt). Ctrl+C to escape. **Anything in `<angle brackets>` in instructions = replace with my value**
- I didn't know how to read the NSG table at first (see Reference: NSG)

**What I figured out:**
- The first VM in a subnet really does get .4
- Traffic inside a VNet is allowed by default, even across subnets, because of the built-in **AllowVnetInBound** rule
- NSG rules are checked **from the lowest priority number up; the first match wins**. My deny at 100 beat the allow at 65000
- **A blocked ping doesn't error; it just hangs.** "It just hangs" is a classic sign of an NSG (or firewall) block
- The CLI's table shows rules in no particular order; **only the priority number matters**
- NSG changes take up to a minute to take effect
- Inside the VM, `eth0` shows only the private IP. The public IP lives at Azure's network edge, not on the VM

**How I'd explain an NSG to a customer in one sentence (my version):**
> "An NSG is like a security guard for your servers: it checks every connection against a list of rules and only lets in the traffic you've approved."

**Next session:**
Push to GitHub. Week 3 (identity + storage) starts Wed Nov 11.

---

## 4. Reference: key concepts explained

### Virtual network (VNet)
**One sentence:** My own private network in Azure that lets my VMs and other resources talk to each other, without physical cables.

**In more detail:**
- A VNet is a **private, isolated** network inside Azure. Other customers can't see into it, and nothing from the internet gets in unless I allow it.
- It has an **address space**, a range of private IPs written in CIDR (e.g., 10.0.0.0/16).
- A VNet lives in **one region** (e.g., West US 2). To connect VNets in different regions, you use **peering** (Stage 1).
- Resources inside a VNet can talk to each other **by default**, even across subnets, because of built-in system routes and the AllowVnetInBound NSG rule.
- **Address spaces must not overlap** with other networks I'll ever connect to (other VNets, on-premises). That's why planning address space up front matters.
- **VNets and subnets are free.** You pay for what's inside them (VMs, public IPs, gateways).

### Subnet
**One sentence:** A smaller section of the VNet with its own range of IP addresses, used to group related resources.

**In more detail:**
- Each subnet takes a slice of the VNet's address space (e.g., 10.0.1.0/24 out of 10.0.0.0/16).
- Every resource placed in a subnet gets **one private IP from that subnet's range**.
- **Subnets in the same VNet can't overlap.**
- Azure reserves **5 addresses** per subnet (first 4 + last), so usable = total − 5.
- Why split into subnets? To **group** resources by role (web, app, database) and **protect** each group differently (e.g., an NSG on the database subnet that only accepts traffic from the app subnet).
- Leave room for growth: don't use up the whole VNet's space at once.
- **Special subnets:** `GatewaySubnet` (reserved name for VPN gateways).
- **Private subnet** (the portal checkbox, now the default): VMs in it get **no automatic outbound internet access**. They need a NAT gateway or a public IP to reach the internet.

### CIDR
**One sentence:** The address/number format (like 10.0.1.0/24) that says where a range of IPs starts and how big it is.

**In more detail:** see Session 2. Key rules: halving ladder for sizes; last = start + total − 1; usable in Azure = total − 5.

### Public vs. private IP
- **Private IP:** used *inside* a network (10.x.x.x, 172.16–31.x.x, 192.168.x.x). Not reachable from the internet. Every VM gets one from its subnet.
- **Public IP:** reachable from the internet. **Optional**, attached to a VM's network interface. Costs a little.
- The VM itself only sees its private IP; Azure translates the public one at its network edge.
- **Static** public IP never changes; **dynamic** can change when the resource is stopped or recreated.

### Network security group (NSG)
**One sentence (customer):** A security guard for your servers that checks every connection against a list of rules and only lets in the traffic you've approved.

**In more detail:**
- An NSG is a list of **allow/deny rules** that filter network traffic **in and out**.
- It can be attached to a **subnet** (protects everything in it) or a **single VM's network interface**. Today each VM had its own (vm-aNSG, vm-bNSG). If both exist, traffic must pass both.
- NSGs are **stateful**: if inbound traffic is allowed, the reply going back out is automatically allowed too.

**What every rule contains:**

| Field | What it means | My deny rule |
|---|---|---|
| Name | A label | deny-icmp-from-subnet-a |
| Priority | Order it's checked: **lower number = checked first**. Custom rules: 100–4096 | 100 |
| Direction | Inbound (arriving) or Outbound (leaving) | Inbound |
| Source | Where traffic comes from: an IP range, `*` (anything), or a service tag | 10.0.1.0/24 |
| Source port | Usually `*` | * |
| Destination | Where traffic is going | * |
| Destination port | Which "door" on the machine (22 = SSH, 80 = HTTP, 443 = HTTPS, 3389 = RDP) | * |
| Protocol | TCP, UDP, ICMP (ping), or `*` (any) | ICMP |
| Access | Allow or Deny | Deny |

**How an NSG decides (the bouncer):**
1. Check rules **from the lowest priority number to the highest**
2. The **first rule that matches** the traffic wins (allow or deny)
3. **Stop**. Later rules are never checked

**The built-in default rules** (on every NSG; can't be deleted, but can be overridden by a lower-numbered rule):

| Priority | Name | Direction | What it does |
|---|---|---|---|
| 65000 | AllowVnetInBound | Inbound | Allows anything coming from inside the VNet |
| 65001 | AllowAzureLoadBalancerInBound | Inbound | Allows Azure's load balancer health checks |
| 65500 | DenyAllInBound | Inbound | **Blocks everything else** |
| 65000 | AllowVnetOutBound | Outbound | Allows anything going to the VNet |
| 65001 | AllowInternetOutBound | Outbound | Allows outbound internet |
| 65500 | DenyAllOutBound | Outbound | Blocks everything else |

So **by default:** traffic inside the VNet is open, inbound from the internet is closed, and outbound to the internet is open. I open only what's needed (e.g., `default-allow-ssh`, priority 1000, which `az vm create` added so I could SSH in).

**Service tags** are named groups of IPs Azure maintains for you: `VirtualNetwork` (my VNet's address space), `Internet`, `AzureLoadBalancer`.

**Worked example (my ping, Session 3):** ping from vm-a (10.0.1.4) → vm-b is Inbound + ICMP + source inside the VNet.
- Before my rule: default-allow-ssh (1000) didn't match (TCP port 22 only) → **AllowVnetInBound (65000) matched → allowed**
- After my rule: **deny-icmp-from-subnet-a (100) matched first → denied**; 65000 never checked

**Troubleshooting:** a deny **drops traffic silently**. No error, it just hangs or times out. Changes take up to a minute.

### ICMP and ping
- **ICMP** is the protocol `ping` uses. It's not TCP or UDP, which is why the SSH rule (TCP 22) didn't affect it.
- `ping -c 4 <ip>` sends 4 pings and stops (Linux pings forever otherwise; Ctrl+C stops it).
- Output: `time=0.8 ms` = round-trip speed; `0% packet loss` = all replies came back; `100% packet loss` = blocked or unreachable.

### SSH and keys
- **SSH** = secure remote login to a Linux machine (TCP port 22).
- **Key pair:** a **private key** stays with me (`~/.ssh/id_rsa`), the **public key** goes on the VM (`id_rsa.pub`). The VM only lets in someone holding the matching private key. Safer than passwords.
- First connection asks to confirm the host's fingerprint. Type `yes`.
- When the prompt changes from `ilias [ ~ ]$` to `azureuser@vm-a:~$`, I'm *inside* the VM. `exit` goes back.
- If the key is lost: make a new one and push it to the VM with `az vm user update` (see cheat sheet).

### Resource group
- A **folder** for related resources. Deleting the group deletes everything in it, which is the easiest cleanup.
- The group has a region, but resources inside can be in **any** region.

### Things that can block a deployment
- **Azure Policy:** rules on the subscription. My free subscription only allows certain regions. Shows up as "policy violation" at deployment, even after validation passed.
- **Capacity (`SkuNotAvailable`):** Azure is temporarily out of that VM size in that region. Fix: another size or another region.

### Cloud Shell
- A browser terminal with the Azure CLI already logged in.
- **Ephemeral:** files (like SSH keys) may not survive when the session ends. Resources in Azure are unaffected.
- Times out if left idle. Just reopen it.

---

## 5. Commands cheat sheet

```bash
# ---------- Resource groups ----------
az group create --name rg-week2 --location westus2
az group list -o table
az group delete --name rg-week2 --yes          # silent when it succeeds

# ---------- VNets and subnets ----------
az network vnet create --resource-group rg-week2 --name vnet-lab --location westus2 \
  --address-prefixes 10.0.0.0/16 --subnet-name subnet-a --subnet-prefixes 10.0.1.0/24
az network vnet subnet create --resource-group rg-week2 --vnet-name vnet-lab \
  --name subnet-b --address-prefixes 10.0.2.0/24
az network vnet list -g rg-week2 -o table

# Show subnets with only the columns I want
# CLI-created subnets:    addressPrefix
# Portal-created subnets: addressPrefixes[0]
az network vnet subnet list -g rg-week2 --vnet-name vnet-lab \
  --query "[].{Name:name, Range:addressPrefix}" -o table

# ---------- VMs ----------
# With a public IP (so I can SSH in)
az vm create --resource-group rg-week2 --name vm-a --image Ubuntu2204 --size Standard_B2ats_v2 \
  --vnet-name vnet-lab --subnet subnet-a --admin-username azureuser --generate-ssh-keys
# Without a public IP (private only)
az vm create --resource-group rg-week2 --name vm-b --image Ubuntu2204 --size Standard_B2ats_v2 \
  --vnet-name vnet-lab --subnet subnet-b --admin-username azureuser --generate-ssh-keys \
  --public-ip-address ""

az vm list -g rg-week2 -d -o table                                   # -d adds IPs and power state
az vm list -g rg-week2 -d --query "[].{Name:name, PrivateIP:privateIps}" -o table

# ---------- SSH and ping ----------
ssh azureuser@<public IP>
ping -c 4 <private IP>
exit

# Lost SSH key? Make a new one and put it on the VM
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N ""
az vm user update --resource-group rg-week2 --name vm-a --username azureuser \
  --ssh-key-value ~/.ssh/id_rsa.pub

# ---------- NSGs ----------
az network nsg list -g rg-week2 -o table
az network nsg rule list -g rg-week2 --nsg-name vm-bNSG --include-default -o table

az network nsg rule create --resource-group rg-week2 --nsg-name vm-bNSG \
  --name deny-icmp-from-subnet-a --priority 100 --direction Inbound --access Deny \
  --protocol Icmp --source-address-prefixes 10.0.1.0/24 \
  --destination-address-prefixes '*' --destination-port-ranges '*'

az network nsg rule delete --resource-group rg-week2 --nsg-name vm-bNSG \
  --name deny-icmp-from-subnet-a                  # silent when it succeeds
```

**Reading CLI errors:** skip the Python traceback; find the `Code:` and `Message:` lines.
