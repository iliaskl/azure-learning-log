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
