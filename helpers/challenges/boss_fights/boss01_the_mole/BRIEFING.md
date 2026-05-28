# 💀 BOSS FIGHT: The Mole

**Difficulty:** [GHOST]
**Type:** Boss Fight (combines ALL domains)
**Skills:** Code review, git forensics, Linux, crypto, web security
**Time estimate:** 2-4 hours
**Attempts expected:** Multiple sessions

---

## SITUATION

A mole has infiltrated our codebase. They planted a backdoor in what looks
like a normal web application. The commit history has been partially cleaned,
but traces remain.

Your mission:
1. Clone the repository
2. Find the backdoor (it's disguised as normal code)
3. Determine what it does
4. Find who planted it (git forensics)
5. Extract the flag from the backdoor's hidden functionality

## DEPLOYMENT

```bash
bash deploy_boss.sh
```

This creates a git repository at `/tmp/boss_the_mole/` with a suspicious history.

## OBJECTIVES

| # | Objective | Flag |
|---|-----------|------|
| 1 | Find the backdoor file | FLAG #1 |
| 2 | Understand what the backdoor does | FLAG #2 |
| 3 | Find the mole's identity in git history | FLAG #3 |
| 4 | Trigger the backdoor to extract final flag | FLAG #4 |

## HINTS POLICY

No hints for boss fights. This is the real deal.

What you DO know:
- The backdoor is in a Python web app
- It looks like legitimate code at first glance
- It was introduced in a commit between March 1-15
- The mole used a fake identity but left a trace in the commit metadata
- The backdoor activates with a specific HTTP request

## TOOLS YOU'LL NEED

- `git log`, `git diff`, `git show`, `git blame`
- Code reading skills (Python)
- Understanding of web request handling
- Knowledge of how backdoors hide (eval, exec, base64, obfuscation)
- Process of elimination

## APPROACH

Think like a security auditor:
1. Map the codebase (what files exist, what's the structure?)
2. Check git history for suspicious commits
3. Look for code that does more than its name suggests
4. Find functions that process input in unusual ways
5. Trace data flow: user input → ??? → code execution

---

*This is the hardest challenge. Take your time. Think like a detective.*
