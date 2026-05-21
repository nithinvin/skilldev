# Layer 2: Text Processing Power

> **Goal**: Master the Unix text-processing pipeline. This is your superpower for data wrangling.

---

## What You'll Do

| Exercise | Skill |
|----------|-------|
| `01_grep_mastery.sh` | grep, egrep, -r, -i, -n, -l, -c, regex basics |
| `02_sed_transform.sh` | sed substitution, delete, insert, in-place edit |
| `03_awk_programming.sh` | awk fields, patterns, actions, built-in variables |
| `04_sort_uniq_cut.sh` | sort, uniq, cut, tr, paste, column |
| `05_xargs_and_find.sh` | find + exec, xargs, parallel processing |
| `06_real_problems.sh` | Combine everything to solve actual tasks |

---

## Key Ideas (Discovered Through Practice)

- **Unix philosophy**: each tool does one thing well; pipes compose them into solutions
- **grep** = filter lines matching a pattern
- **sed** = transform text line by line (stream editor)
- **awk** = mini programming language for columnar data
- **sort | uniq** = the classic deduplication pipeline
- **xargs** = convert stdin into arguments for another command

---

## Checkpoint

1. How do you count how many times "error" appears in all `.log` files recursively?
2. Write a one-liner to extract unique IP addresses from an Apache access log.
3. What does `awk '{print $NF}'` do? What is `$NF`?
4. When would you use `sed -i` vs `sed > newfile`?
5. Why is `find . -exec rm {} \;` slower than `find . | xargs rm`?
