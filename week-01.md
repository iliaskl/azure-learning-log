## 2026-10-31 · Week 1 · Lab setup (part 1)

**What I did:**
- Signed up for an Azure free account: $200 credit for 30 days (expires ~Nov 30) plus 12 months of free services
- Confirmed my subscription: Azure subscription 1, Active, my role is Owner
- Created a $10 monthly budget (`monthly-10`) at the billing account level, with email alerts at 25%, 50% and 100%
- Explored the portal: Home, All resources, Resource groups, Cost Management, Billing scopes
- Pinned Cost Management to my dashboard
- Created this repo, azure-learning-log

**What confused me:**
- After signing up, the portal still said "Don't have a subscription?", and trying to sign up again said I already had an account. The first signup had worked; the portal just took a while to show it.
- I opened the "Create a subscription" wizard by mistake because it also has a Budget tab. The real budget is under Cost Management → Budgets.
- The pin icon isn't on every page (e.g., not on Billing scopes).

**What I figured out:**
- Budget alerts only send emails; they don't stop spending. Deleting resources after every session is what actually controls cost.
- A budget at the billing account level covers everything on my account, not just one subscription.

**What I'd explain to a customer in one sentence:**
A budget in Azure is basically an alarm. It emails you when you're getting close to your spending limit, but it won't shut anything off, so you still have to delete stuff you're not using.

**Next session:**
Part 2: create my first VM (Ubuntu, B1s) in rg-week1, connect to it, look at what else got created, then delete the resource group.

## 2026-10-31 · Week 1 · First virtual machine (part 2)

**What I did:**
- Created resource group rg-week1 in West US 2
- Created vm-week1: Ubuntu 24.04, size Standard_B2ats_v2 (2 vCPUs, 1 GiB), SSH key login, port 22 open
- Connected from Cloud Shell with `ssh -i vm-week1_key.pem azureuser@<public IP>`
- Ran `uname -a`, `df -h`, `free -m`, `ls /` inside the VM
- Reviewed the 7 resources Azure created, then deleted rg-week1

**What each command told me:**
- `uname -a`: Linux kernel built for Azure, Ubuntu 24.04, x86_64
- `df -h`: 29 GB OS disk, about 1.9 GB used
- `free -m`: 836 MB total memory (not the full 1 GiB, since some is reserved), about 605 MB available, no swap
- `ls /`: top-level Linux folders (home, etc, var, tmp, etc.)

**What got created besides the VM:**
| Resource | What it is | Costs money? |
|---|---|---|
| OS disk | The VM's 30 GB drive | Yes, even when the VM is stopped |
| Public IP | Address I SSH'd to | Yes |
| Network interface | VM's network card, holds the private IP (172.16.0.4) | Free |
| Network security group | Firewall that allowed port 22 | Free |
| Virtual network | Private network the VM sits in | Free |
| SSH key | Azure's copy of my public key | Free |

**What confused me:**
- The default size (D2s_v3, about $70/month) wasn't allowed on my free trial
- B1s showed "Size not available" in West US 2, so I used B2ats_v2 instead (also free-tier eligible)
- I had to `chmod 400` the key before SSH would accept it

**What I figured out:**
- Stopping a VM doesn't stop all charges; the disk and public IP still cost money. Deleting the resource group is what brings cost to zero.
- Not every VM size is available in every region or on every subscription type.

**What I'd explain to a customer in one sentence:**
Stopping a VM doesn't stop all charges, because the disk and public IP keep billing, so delete the resource group once you're completely done with it.

**Next session:**
Part 3: the same thing from the command line (az group create / list / delete).
