#!/usr/bin/env python3
"""
Layer 0 Checkpoint Quiz: Terminal & Shell Basics
=================================================
Answer these questions to verify you've internalized the concepts.
Run: python3 checkpoint_quiz.py
"""

import sys

QUESTIONS = [
    {
        "question": "What is the difference between a shell and a terminal emulator?",
        "choices": [
            "A) They are the same thing",
            "B) Terminal is the window/display program; shell is the command interpreter running inside it",
            "C) Shell is graphical; terminal is text-only",
            "D) Terminal runs commands; shell just displays output",
        ],
        "answer": "B",
        "explanation": (
            "The terminal emulator (like GNOME Terminal, iTerm2, Windows Terminal) provides "
            "the window and handles keyboard/display. The shell (bash, zsh, fish) is the "
            "program RUNNING INSIDE the terminal that interprets your commands."
        ),
    },
    {
        "question": "You type `ls` and press Enter. What does the shell do? (in order)",
        "choices": [
            "A) Displays files directly from kernel",
            "B) Searches PATH for 'ls', fork()s a child process, exec()s /usr/bin/ls, waits for it to finish",
            "C) Sends 'ls' to the operating system which handles everything",
            "D) Reads the directory and prints it using a builtin function",
        ],
        "answer": "B",
        "explanation": (
            "The shell: 1) Parses the command, 2) Searches PATH directories for 'ls', "
            "3) Calls fork() to create a child process, 4) In the child, calls exec() "
            "to replace itself with /usr/bin/ls, 5) Parent shell waits (waitpid) for child to exit."
        ),
    },
    {
        "question": "What is the difference between `>` and `>>` in redirection?",
        "choices": [
            "A) > writes to the end; >> overwrites",
            "B) > creates a new file; >> appends to existing file",
            "C) > truncates/creates and writes; >> appends without truncating",
            "D) There is no difference",
        ],
        "answer": "C",
        "explanation": (
            "> opens the file with O_TRUNC (erases existing content) before writing. "
            ">> opens with O_APPEND (adds to end). > will also create the file if it doesn't exist. "
            "DANGER: `cmd > file` destroys existing content even before cmd runs!"
        ),
    },
    {
        "question": "What happens to stderr when you use a pipe (|)?",
        "choices": [
            "A) It goes through the pipe to the next command",
            "B) It goes directly to the terminal (bypasses the pipe)",
            "C) It is discarded automatically",
            "D) It causes an error",
        ],
        "answer": "B",
        "explanation": (
            "Pipes only connect stdout (fd 1) of the left command to stdin (fd 0) of the right. "
            "Stderr (fd 2) still goes directly to the terminal. "
            "To pipe stderr too: `cmd 2>&1 | next_cmd` or `cmd |& next_cmd`"
        ),
    },
    {
        "question": "What does `export MY_VAR=hello` do that `MY_VAR=hello` doesn't?",
        "choices": [
            "A) Makes the variable permanent across reboots",
            "B) Makes the variable visible to child processes",
            "C) Saves the variable to .bashrc",
            "D) Makes the variable read-only",
        ],
        "answer": "B",
        "explanation": (
            "Without export, MY_VAR is a shell variable — only visible in the current shell. "
            "With export, it becomes an environment variable — inherited by all child processes. "
            "Neither is permanent; for that, add the export to ~/.bashrc."
        ),
    },
    {
        "question": "What does `type ls` tell you that `which ls` doesn't?",
        "choices": [
            "A) The file size of ls",
            "B) Whether ls is an alias, builtin, or external command (not just the path)",
            "C) The permissions of ls",
            "D) The source code of ls",
        ],
        "answer": "B",
        "explanation": (
            "`which` only searches PATH for executables. `type` tells you the NATURE of the command: "
            "alias, shell builtin, shell keyword, or external file. For aliases, it shows the expansion. "
            "For builtins, it says 'builtin' (which wouldn't find these at all)."
        ),
    },
    {
        "question": "How do you discard ALL output (stdout AND stderr) from a command?",
        "choices": [
            "A) cmd > /dev/null",
            "B) cmd 2> /dev/null",
            "C) cmd > /dev/null 2>&1",
            "D) cmd | /dev/null",
        ],
        "answer": "C",
        "explanation": (
            "cmd > /dev/null redirects stdout to /dev/null. 2>&1 then redirects stderr to "
            "the same place stdout is going (which is /dev/null). Together: silence. "
            "Shorthand: cmd &> /dev/null (bash 4+)"
        ),
    },
    {
        "question": "What does the `tee` command do?",
        "choices": [
            "A) Creates a new terminal",
            "B) Copies stdin to both stdout AND a file (splits the stream)",
            "C) Encrypts data",
            "D) Measures command execution time",
        ],
        "answer": "B",
        "explanation": (
            "tee is named after a T-junction in plumbing. Data flows in from stdin, "
            "and tee sends it BOTH to stdout (for the next command in the pipe) AND "
            "to a file. Example: `cmd | tee log.txt | next_cmd`"
        ),
    },
]


def run_quiz():
    score = 0
    total = len(QUESTIONS)

    print("\n" + "═" * 60)
    print("  LAYER 0 CHECKPOINT QUIZ: Terminal & Shell Basics")
    print("═" * 60)
    print(f"\n  {total} questions. Let's see what you've learned.\n")

    for i, q in enumerate(QUESTIONS, 1):
        print(f"─── Question {i}/{total} {'─' * 40}")
        print(f"\n  {q['question']}\n")
        for choice in q["choices"]:
            print(f"    {choice}")

        while True:
            answer = input(f"\n  Your answer (A/B/C/D): ").strip().upper()
            if answer in ("A", "B", "C", "D"):
                break
            print("  Please enter A, B, C, or D.")

        if answer == q["answer"]:
            print(f"\n  ✓ CORRECT!")
            score += 1
        else:
            print(f"\n  ✗ Wrong. The answer is {q['answer']}.")

        print(f"  → {q['explanation']}\n")

    print("═" * 60)
    print(f"  SCORE: {score}/{total} ({score*100//total}%)")
    print("═" * 60)

    if score == total:
        print("\n  PERFECT! You've mastered Layer 0. Move to Layer 1!")
    elif score >= total * 0.75:
        print("\n  Good job! Review the ones you missed, then proceed to Layer 1.")
    else:
        print("\n  Go back through the exercises. Focus on the concepts you missed.")
        print("  Re-run this quiz when you're ready.")

    print()
    return score == total


if __name__ == "__main__":
    success = run_quiz()
    sys.exit(0 if success else 1)
