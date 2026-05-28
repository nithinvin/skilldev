# 🔒 BRIEFING: The Locked Room

**Difficulty:** [RECRUIT]
**Skills:** Linux permissions, chmod, chown, users, groups, sudo
**Time estimate:** 20-40 minutes

---

## SITUATION

Intel is locked inside `vault/`. Our agent set up restrictive permissions
before disappearing. You need to access the flag inside without destroying evidence.

## OBJECTIVES

1. Figure out WHY you can't access the vault
2. Get inside and read the flag
3. There's a second flag that requires you to UNDERSTAND permission math

## SETUP (Run this first!)

```bash
bash setup.sh
```

This creates the challenge environment. Run it ONCE.

## CONSTRAINTS

- Don't just `sudo cat` everything. That's not learning.
- Understand the permission system first, THEN act.
- The setup script creates files owned by you — no root needed.

## INTEL

The permission system uses three triads: `rwx rwx rwx` (owner/group/other).
But there's more to Linux permissions than just rwx...

## START

```bash
bash setup.sh
ls -la vault/
```

Why can't you get in? What does the permission string MEAN?

---

*After solving, check DEBRIEF.md*
