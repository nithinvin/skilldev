# DEBRIEF: Hidden in Plain Sight

## Flags

1. **FLAG{the_obvious_one_is_never_the_real_prize}**
   - Location: `.secret` (hidden file — starts with dot)
   - Lesson: `ls` doesn't show hidden files. `ls -la` or `ls -A` does.
   - Real-world: `.env` files with API keys, `.git/` with repo history

2. **FLAG{strings_command_reveals_secrets_in_binaries}**
   - Location: `deploy.sh` (inside a comment in a script)
   - Lesson: Comments in code are still visible. `grep -r FLAG .` finds text in any file.
   - Real-world: Developers accidentally leave secrets in comments, commit messages, scripts.

3. **FLAG{base64_is_not_encryption_its_just_encoding}**
   - Location: `logo.png` (not actually a PNG — the last line is Base64-encoded)
   - Lesson: File extensions LIE. `file logo.png` reveals the truth. Base64 decoding: `echo "RkxBR3tiYXNlNjRfaXNfbm90X2VuY3J5cHRpb25faXRzX2p1c3RfZW5jb2Rpbmd9" | base64 -d`
   - Real-world: Attackers rename malicious files. Security scanners check content, not names. Base64 is encoding (reversible by anyone), NOT encryption.

## Mental Model

```
Files can hide in plain sight:
├── Hidden files (dot-prefix) — invisible to casual browsing
├── Comments in code — humans skip them, grep finds them
├── Fake extensions — the OS doesn't care about extensions, content matters
└── Encoding ≠ Encryption — Base64 hides from eyes, not from tools
```

## Skills Unlocked
- `ls -la` — see everything
- `grep -r` — recursive text search
- `file` — identify true file type
- `base64 -d` — decode Base64
- `find . -name ".*"` — find hidden files
- `cat` / `strings` — inspect file contents

## Key Insight
**Security through obscurity is not security.** Hiding something doesn't protect it.
Real protection requires encryption (a key), not just encoding (a format).
