# Layer 0: Terminal & Shell Basics

## What You'll Learn
- How the shell works (it's just a program that finds and runs other programs)
- Navigating the filesystem (cd, ls, pwd, tree, pushd/popd)
- Finding help (man, --help, type, which, apropos)
- Environment variables and shell configuration (.bashrc, PATH, aliases)
- I/O redirection (stdin, stdout, stderr, >, >>, <, 2>)
- Pipes (|) and combining commands

## File Structure

```
layer0/
├── README.md              ← You are here
├── checkpoint_quiz.py     ← Test yourself before moving on
└── exercises/
    ├── 01_navigation.sh           ← cd, ls, pwd, tree, pushd/popd
    ├── 02_commands_and_help.sh    ← type, which, man, PATH
    ├── 03_environment.sh          ← variables, export, .bashrc, aliases
    ├── 04_io_redirection.sh       ← >, >>, <, 2>, /dev/null
    └── 05_first_pipes.sh          ← |, tee, xargs, pipeline thinking
```

## How to Work Through This

```bash
cd ~/skilldev/helpers/linux_skills/layer0

# Open each exercise in your editor AND a terminal side by side.
# Read the exercise file, then type each command yourself.
# DO NOT just run the script — type each command manually!

# Start here:
cat exercises/01_navigation.sh     # Read it
# Then type each command from the file into your terminal

# After all 5 exercises:
python3 checkpoint_quiz.py
```

## Rules
1. Type every command yourself (muscle memory matters)
2. Always try the "BREAK IT" section (you learn more from failures)
3. If a command's output confuses you, `man <command>` before moving on
4. Don't skip — later exercises build on earlier ones

## Time Estimate
~3-4 hours total (about 45 min per exercise)
