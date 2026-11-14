# Week 3 · Identity + storage (Nov 11–17, 2026)

**Goal:** control who can do what in Azure, and store and manage files in the cloud.

**Contents**
1. Session 1 (Nov 14): Users, groups, roles
2. Session 2: Test it as a user *(to do)*
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

## 2. Test it as a user *(to do)*

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
