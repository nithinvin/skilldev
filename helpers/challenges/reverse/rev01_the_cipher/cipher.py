#!/usr/bin/env python3
# No comments. Figure out what this does.

import sys

K = "VIGENERE"

def t(c, k, d=1):
    if not c.isalpha():
        return c
    b = ord('A') if c.isupper() else ord('a')
    s = ord(k.upper()) - ord('A')
    return chr((ord(c) - b + d * s) % 26 + b)


def p(text, key, decrypt=False):
    r = []
    ki = 0
    d = -1 if decrypt else 1
    for c in text:
        if c.isalpha():
            r.append(t(c, key[ki % len(key)], d))
            ki += 1
        else:
            r.append(c)
    return ''.join(r)


def main():
    if len(sys.argv) < 3:
        print(f"Usage: {sys.argv[0]} <encrypt|decrypt> <message> [key]")
        sys.exit(1)
    
    mode = sys.argv[1]
    msg = sys.argv[2]
    key = sys.argv[3] if len(sys.argv) > 3 else K
    
    if mode == "encrypt":
        print(p(msg, key))
    elif mode == "decrypt":
        print(p(msg, key, decrypt=True))
    else:
        print("Unknown mode")


if __name__ == "__main__":
    main()
