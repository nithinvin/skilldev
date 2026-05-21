# Layer 4: Shell Scripting

## What You'll Learn
- Variables, quoting, and parameter expansion (the tricky bits)
- Conditionals ([[ ]], case, short-circuit operators)
- Loops (for, while, processing files safely)
- Functions, error handling, and writing production-grade scripts

## File Structure

```
layer4/
├── README.md              ← You are here
└── exercises/
    ├── 01_variables_and_quoting.sh    ← Variables, arrays, quoting rules
    ├── 02_conditionals.sh             ← if, [[ ]], case, && ||
    ├── 03_loops.sh                    ← for, while, break/continue
    └── 04_functions_and_errors.sh     ← Functions, set -euo pipefail, trap
```

## Prerequisites
- Complete Layers 0-3
- You should be very comfortable typing commands in the terminal

## Why This Matters
Shell scripting automates YOUR life:
- "I do this 5-step process every morning" → one script
- "I need to rename 500 files" → a for loop
- "Alert me when disk hits 90%" → cron + script
- "Deploy my app" → a robust script with error handling

## The Script Evolution
```
One-liner         →  "I'll just type it"
Alias             →  "I'll save the one-liner"
Script            →  "I need logic and error handling"
Tool              →  "Others will use this" → add --help, input validation
```

## Time Estimate
~5 hours (shell scripting is where everything comes together)
