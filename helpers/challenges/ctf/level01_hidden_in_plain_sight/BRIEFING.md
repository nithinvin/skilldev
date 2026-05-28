# 📡 BRIEFING: Hidden in Plain Sight

**Difficulty:** [RECRUIT]
**Skills:** Linux filesystem, hidden files, file inspection, text search
**Time estimate:** 15-30 minutes

---

## SITUATION

Our field agent left a dead drop in this directory before going dark.
The flag is hidden somewhere in these files. It's a string in the format:

```
FLAG{some_text_here}
```

The agent was paranoid. They hid the flag using multiple techniques.
There are actually **3 flags** hidden here. Find all three.

## OBJECTIVES

1. Find FLAG #1 (easy — just look carefully)
2. Find FLAG #2 (moderate — not everything is what it seems)
3. Find FLAG #3 (hard — you need to think beyond text)

## RULES

- Stay inside this directory and its subdirectories
- You can use any Linux command
- No internet needed for this one

## INTEL

The agent was known to use:
- Hidden files
- File metadata
- Unusual file extensions
- Encoding tricks (but NOT encryption)

## START

```bash
ls -la
```

That's your only free hint. Go.

---

*After you find all 3 flags, check DEBRIEF.md*
