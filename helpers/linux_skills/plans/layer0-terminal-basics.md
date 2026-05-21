# Layer 0: Terminal & Shell Basics

> **Goal**: Make the terminal feel like home. Understand what happens when you type a command.

---

## What You'll Do

| Exercise | Skill |
|----------|-------|
| `01_navigation.sh` | cd, ls, pwd, tree, pushd/popd, tab completion |
| `02_commands_and_help.sh` | type, which, man, --help, apropos, info |
| `03_environment.sh` | PATH, variables, export, .bashrc, aliases |
| `04_io_redirection.sh` | stdin, stdout, stderr, >, >>, 2>, &>, /dev/null |
| `05_first_pipes.sh` | |, tee, combining commands |

---

## Key Ideas (Discovered Through Practice)

- **The shell is just a program** — it reads input, finds the executable, fork+exec's a child process
- **PATH is a search list** — when you type `ls`, the shell looks through PATH directories left to right
- **Everything has an exit code** — 0 = success, non-zero = failure. Check with `echo $?`
- **Three streams** — every process is born with stdin(0), stdout(1), stderr(2)
- **Pipes connect stdout→stdin** — that's it. That's the whole magic.

---

## Checkpoint (answer before moving to Layer 1)

1. What is the difference between a *shell* and a *terminal emulator*?
2. What does `type ls` tell you that `which ls` doesn't?
3. If PATH is empty, can you still run commands? How?
4. What's the difference between `>` and `>>`?
5. What happens to stderr when you use `|`? Does it go through the pipe?

---

## Time Estimate

~2-3 hours if you run every exercise and experiment.
