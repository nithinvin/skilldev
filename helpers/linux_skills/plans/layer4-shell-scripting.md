# Layer 4: Shell Scripting

> **Goal**: Automate anything. Write scripts that are robust, readable, and reusable.

---

## What You'll Do

| Exercise | Skill |
|----------|-------|
| `01_variables_and_quoting.sh` | variables, quoting, parameter expansion |
| `02_conditionals.sh` | if, test, [[ ]], file tests, string comparison |
| `03_loops.sh` | for, while, until, loop over files/lines |
| `04_functions.sh` | defining functions, local vars, return values |
| `05_error_handling.sh` | set -euo pipefail, trap, exit codes |
| `06_real_scripts/` | Practical scripts: backup, log rotator, monitor |

---

## Key Ideas (Discovered Through Practice)

- **Always start with `#!/bin/bash`** and consider `set -euo pipefail`
- **Quoting matters** — `"$var"` vs `$var` can break your script with spaces
- **`[[ ]]` > `[ ]`** — double brackets are safer and more powerful
- **Functions are mini-scripts** — they have their own scope with `local`
- **Exit codes are your API** — scripts should return meaningful codes

---

## Checkpoint

1. What happens if you don't quote `$filename` and it contains spaces?
2. What does `set -e` do? When might you NOT want it?
3. How do you pass arguments to a function? How do you get them back?
4. Write a script that takes a directory path and reports its total size, file count, and newest file.
5. What does `trap cleanup EXIT` do?
