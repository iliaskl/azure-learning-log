# Week 3 · Identity + storage (Nov 11–17, 2026)

**Goal:** control who can do what in Azure, and store and manage files in the cloud.

**Contents**
1. Session 1 (Nov 14): Users, groups, roles
2. Session 2 (Nov 14): Testing roles as alex.test
3. Session 3: Storage *(to do)*
4. Reference: key concepts
5. Commands cheat sheet

---

## 1. 2026-11-14 · Week 3 · Users, groups, roles

**What I did:**
- Read Microsoft Learn's overview of Azure role-based access control (RBAC)
- In Microsoft Entra ID, created two test users: `alex.test` and `sam.test` (type: Member)
- Created a **Security** group `lab-readers` (membership type: Assigned) and added alex.test to it. sam.test stays out of the group on purpose
- Created `rg-week3` in West US 2 with the CLI
- In rg-week3 → Access control (IAM), gave `lab-readers` the **Reader** role on rg-week3

**What confused me:**
- My first `az group create` failed because I left out a space: `rg-week3--location`. Azure read that whole thing as the name and didn't know what to do with `westus2`
- I couldn't find where to assign a role. It's in **Access control (IAM)** on the resource itself, not in Entra ID
- I thought I showed up in Role assignments because I owned the group. Actually the group has **0 owners**; I'm there because I'm **Owner of the subscription**, and that flows down to rg-week3 (Scope column: "Subscription (Inherited)")
- When I listed the three parts of a role assignment, I said "access". The real third part is the **security principal** (who)

**What I figured out:**
- **A role assignment = who + what + where**: security principal + role definition + scope. Example: *lab-readers* can *read* in *rg-week3*
- **Owner vs Contributor vs Reader:**
  - Reader: view only
  - Contributor: create, change and delete resources, but **can't give anyone else access**
  - Owner: everything Contributor can do **plus assign roles to others**
- **Permissions flow down** the scope levels, never up or sideways: management group → subscription → resource group → resource. Reader on rg-week3 doesn't let you see other resource groups
- A resource group's `id` (`/subscriptions/<id>/resourceGroups/rg-week3`) **is** its scope. The role assignment screen shows the exact same string
- Azure assigns roles to an **Object ID**, not a name. lab-readers' Object ID (`8d091318...`) was the same on the group page and the role assignment. Renaming the group wouldn't break anything
- **Why roles go on groups, not individuals:** you manage *people* in groups and *permissions* on groups.
  - New hire → add them to the group, done
  - Someone leaves → remove them from the group, and their access is gone everywhere
  - Audit → check one group instead of every individual
- User sign-in names end with my tenant's default domain: `alex.test@iliaskladakisoutlook.onmicrosoft.com`
- **Member vs Guest:** Member = someone inside my organization; Guest = an outside person (e.g., a contractor) signing in with their own company's account
- **Assigned vs Dynamic groups:** Assigned = I add people by hand; Dynamic = Entra adds them automatically from a rule (e.g., department = Sales)
- "Privileged" on the IAM page flags powerful roles like Owner

**Customer sentence:**
> Instead of giving each person access one by one, you put people in groups and give the group access. When someone joins or leaves, you just add or remove them from the group and everything else takes care of itself.

---

## 2. 2026-11-14 · Week 3 · Testing roles as alex.test

**What I did:**
- Signed in as alex.test in a private window (changed the temporary password on first sign-in)
- **As Reader:** alex could see only rg-week3. Tried to create storage account `stweek3ilias` → `AuthorizationFailed`
- Switched lab-readers from Reader to Contributor (added the new role first, then removed the old one)
- **As Contributor:** created `stweek3ilias` successfully, then deleted it
- Tried to give sam.test the Reader role as alex → **Add role assignment was greyed out**

**What confused me:**
- I accidentally gave the group **Advisor Discoverable Workloads Contributor** instead of **Contributor**. It's a narrow role that can't even read the resource group, so alex got locked out completely (the error's action changed to `resourceGroups/read`)
  - Plain **Contributor** isn't on the default "Job function roles" tab. It's under **Privileged administrator roles**
  - Lesson: the role list has dozens of look-alike names. Check the exact name before assigning
- My first storage account settings were wrong for this week:
  - **Primary service: Azure Files** → that's for file shares (network drives), and it can't hold blob containers. Needed **Azure Blob Storage**
  - **GRS** → copies data to a second region; about twice the cost. A lab only needs **LRS**
- The review page said "Account type: Page blobs," but the automation template showed `"kind": "StorageV2"`. The portal label was just confusing. **When the portal is unclear, check the template's Parameters tab**

**What I figured out:**
- **Reading an Azure permission error:** every one has *who* (the client + object ID), *what action* was blocked, and *where* (the scope path)
- The object ID in the error was **alex's own**, even though the role was on the group. Azure checks the user, then their group memberships
- Creating something in the portal runs a **deployment**. Reader got blocked at `deployments/validate/action`, before the storage account was even attempted
- **Role assignments can't be edited.** To change a role, you add the new one and delete the old one. Add first, so people don't lose access in between
- Role changes can take a few minutes. If access was just granted, sign out and back in ("refresh your credentials")
- Giving access needs `Microsoft.Authorization/roleAssignments/write`. **Contributor is specifically denied that**, which is why the button was greyed out
- Contributor can **delete everything** in its scope, which is why Azure lists it as Privileged. In real companies, give it on specific resource groups, not the whole subscription
- Every portal Create button generates an **ARM template** behind the scenes ("View automation template"). `"accountType": "Standard_LRS"` = Standard performance + LRS replication in one value

**Reader vs Contributor vs Owner (my words):**

| Role | Can do | Can't do | Who gets it |
|---|---|---|---|
| Reader | See what's in the scope it's assigned to | Create, change, delete, or give access | Guests or employees who only need to see things |
| Contributor | Create, change and delete anything in its scope | Give anyone else access | Standard workers who build and run resources |
| Owner | Everything, including assigning roles | Nothing within its scope | The top engineer or whoever owns the resource |

**Storage redundancy (customer question: "which one do I need?"):**
- **LRS:** 3 copies in one datacenter. Cheapest. Fine for labs and test data
- **GRS:** also copies to a second region far away. About 2x the cost. For data you can't afford to lose
- The real question: *how bad would losing this data be, and what will you pay to avoid it?*

**Blob types:**
- **Block blobs:** ordinary files (docs, images, backups). Supports access tiers (Hot/Cool)
- **Page blobs:** VM disks (lots of small random reads and writes)
- **Append blobs:** logs (only add to the end)

## 3. Storage *(to do)*

---

## 4. Reference: key concepts

| Term | Plain meaning | This week's example |
|---|---|---|
| Security principal | **Who**: a user, group or app | lab-readers |
| Role definition | **What** they can do | Reader |
| Scope | **Where** it applies | rg-week3 |
| Inherited | A role that flows down from a higher scope | My Owner role from the subscription |
| Object ID | The ID Azure actually uses behind the name | 8d091318-... |

```
Management group
  └── Subscription          ← I'm Owner here (from signing up)
        └── Resource group  ← lab-readers is Reader here (rg-week3)
              └── Resources ← both roles flow down to these
```

---

## 5. Commands cheat sheet

```bash
# Create a resource group (watch the spaces between flags)
az group create --name rg-week3 --location westus2
```
