# 📋 OPERATION: Dead Drop

**Difficulty:** [SPECIALIST]
**Type:** Multi-step operation (Hitman-style planning)
**Skills:** Linux, networking, encryption, steganography, scripting
**Time estimate:** 90-120 minutes

---

## MISSION BRIEFING

Agent N,

A field operative has gone dark. Before disappearing, they left an encrypted
dead drop — a series of clues, each leading to the next. You must follow
the trail, decrypt the intel, and extract the final message.

This operation has **5 stages**. Each stage gives you what you need for the next.
There are multiple valid approaches. Choose your tools wisely.

## DEPLOYMENT

```bash
bash deploy_mission.sh
```

This creates the dead drop environment in `/tmp/dead_drop_op/`.

## STAGE 1: The Entry Point

A file has been left at a publicly accessible location.
Find it. It contains encoded coordinates to the next stage.

**Starting point:** `/tmp/dead_drop_op/public/notice.txt`

## STAGE 2-5: Follow the Trail

Each stage reveals itself only after completing the previous one.
The clues are embedded in the outputs.

## RULES OF ENGAGEMENT

- You may use any tool available on the system
- You may write scripts to automate steps
- Internet access is NOT required (everything is local)
- Time yourself — can you beat 60 minutes?

## APPROACH OPTIONS (Hitman-style)

Like Hitman, there are multiple paths:

- **Loud approach:** brute-force where needed, ignore elegance
- **Silent approach:** follow every clue precisely, minimal footprint
- **Ghost approach:** script the entire operation to run in one shot

## SCORING

| Criteria | Points |
|----------|--------|
| Complete all 5 stages | 50 |
| Under 90 minutes | +10 |
| Under 60 minutes | +20 |
| Wrote automation script | +15 |
| Found bonus flag | +10 |
| Zero Google searches | +5 |

---

*Deploy and begin. DEBRIEF.md contains full walkthrough after you're done.*
