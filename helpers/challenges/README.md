# 🎮 OPERATION: STACK OVERFLOW

## You are Agent N.

You've been recruited into **Project Chimera** — a covert dev-ops unit that handles
the problems nobody else can solve. Broken servers, encrypted files, corrupted pipelines,
and rogue code that's gone sentient.

Your handler (codename: **Architect**) will assign you operations. Each one is a real
problem. No hand-holding. No tutorials. You figure it out, or the mission fails.

---

## HOW THIS WORKS

### 🎯 Mission Types

| Type | Style | What You Do |
|------|-------|-------------|
| **OPS** | Hitman | Multi-step missions. Plan your approach. Multiple valid solutions. |
| **CTF** | Doom | Capture the flag. Find the hidden answer. Brute logic. |
| **BOSS FIGHTS** | Half-Life 2 | Combine everything you know. Hard. Satisfying. |
| **BREAK IT** | Valorant | Given working code — find the exploit. Think like an attacker. |
| **REVERSE** | Portal | Code with no docs. Figure out what it does. Then weaponize it. |
| **SPEEDRUN** | Doom Eternal | Timed challenges. Build X in Y minutes. Pressure = growth. |

### 🏆 Difficulty Tiers

```
[RECRUIT]     → You should be able to solve this. Warm-up.
[OPERATIVE]   → Requires thinking. Might take 30-60 min.
[SPECIALIST]  → Hard. Might need multiple attempts. Research allowed.
[GHOST]       → The kind of problem that keeps you up at night. Glory awaits.
```

### 📋 Rules of Engagement

1. **No peeking at solutions until you've TRIED.** Minimum 20 minutes of real effort.
2. **Failing is data.** Every wrong path teaches you something. Write down what you tried.
3. **Google is a weapon, not a crutch.** Search for concepts, not answers.
4. **Document your mental model.** After solving, write 2-3 sentences: "I now understand that..."
5. **If stuck > 45 min:** Read the HINT file (one hint at a time). Don't read all hints at once.
6. **After solving:** Look at the DEBRIEF. It explains the "why" behind the challenge.

### 🧠 INTP Protocol

You learn by building theories from experience. So:
- **Try first. Fail. Observe WHY you failed. Form a theory. Test it.**
- These challenges are designed to give you failures that teach specific lessons.
- The "aha!" moment is yours to earn.

---

## MISSION MAP

### Phase 1: INFILTRATION (Linux, Files, Permissions)
- `ctf/level01_hidden_in_plain_sight/` — Something's hidden. Find it.
- `ctf/level02_the_locked_room/` — Permission denied. Get in anyway.
- `ctf/level03_the_ghost_process/` — A rogue process. Hunt it down.
- `ops/op01_dead_drop/` — Retrieve encrypted intel from a server.

### Phase 2: EXPLOITATION (Web, APIs, Networking)
- `ctf/level04_the_leaky_api/` — An API is leaking secrets. Extract them.
- `ctf/level05_cookie_monster/` — Steal the session. Become admin.
- `break_it/web01_injection_point/` — Find the SQL injection. Exploit it.
- `ops/op02_the_broken_pipeline/` — CI/CD is down. Production is burning. Fix it.

### Phase 3: CRYPTOGRAPHY (Encoding, Hashing, Encryption)
- `ctf/level06_not_encryption/` — It looks encrypted. It's not.
- `ctf/level07_cracking_the_vault/` — Weak passwords. Break them.
- `ctf/level08_the_forged_token/` — Forge a JWT. Become root.
- `reverse/rev01_the_cipher/` — Unknown encryption. Reverse-engineer it.

### Phase 4: SYSTEMS (Docker, Processes, Debugging)
- `break_it/sys01_container_escape/` — Break out of the container.
- `ops/op03_the_zombie_horde/` — Server is dying. Fix it under pressure.
- `reverse/rev02_binary_analysis/` — What does this program do?
- `speedrun/sr01_deploy_in_10/` — Deploy a full stack in 10 minutes.

### Phase 5: BOSS FIGHTS (Everything Combined)
- `boss_fights/boss01_the_heist/` — Full stack break-in. Plan. Execute. Exfil.
- `boss_fights/boss02_the_outage/` — Production is down. Clock is ticking.
- `boss_fights/boss03_the_mole/` — Someone planted a backdoor. Find it.

---

## TRACKING PROGRESS

After each challenge, add a line to `KILLBOARD.md`:

```
| Date | Challenge | Time | Attempts | Key Lesson |
```

Your kill count is your resume.

---

## START HERE

```bash
cd ctf/level01_hidden_in_plain_sight/
cat BRIEFING.md
```

Good luck, Agent N. The first flag is waiting.

— Architect
