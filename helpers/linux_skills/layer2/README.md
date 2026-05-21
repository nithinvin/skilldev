# Layer 2: Text Processing Power

## What You'll Learn
- grep (search for patterns in text — your daily workhorse)
- sed (transform text — stream search-and-replace)
- awk (process columnar data — a mini language for text)
- The power of combining them in pipelines

## File Structure

```
layer2/
├── README.md              ← You are here
└── exercises/
    ├── 01_grep_mastery.sh         ← Find patterns: grep, regex, -r, -l, -c
    ├── 02_sed_transform.sh        ← Transform text: s/old/new/, line operations
    └── 03_awk_programming.sh      ← Process columns: fields, math, aggregation
```

## How to Work Through This

```bash
cd ~/skilldev/helpers/linux_skills/layer2

# Each exercise creates sample data files for you to practice with.
# Read the exercise, run the setup commands, then work through each part.

cat exercises/01_grep_mastery.sh
cat exercises/02_sed_transform.sh
cat exercises/03_awk_programming.sh
```

## Prerequisites
- Complete Layer 0 and Layer 1
- You should be comfortable with pipes (|) and basic commands

## Why This Matters
Every developer spends time:
- Searching logs for errors (grep)
- Modifying config files in scripts (sed)
- Analyzing data from command output (awk)

These three tools handle 90% of text processing tasks without writing a Python script.

## The Decision Tree
```
Need to FIND something?       → grep
Need to REPLACE/TRANSFORM?    → sed
Need to COMPUTE/AGGREGATE?    → awk
More than 20 lines of awk?    → switch to Python
```

## Time Estimate
~4 hours (grep and awk take longer — they're deep tools)
