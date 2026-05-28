# 🔓 BRIEFING: Not Encryption

**Difficulty:** [RECRUIT]
**Skills:** Encoding vs encryption, Base64, hex, URL encoding, ROT13
**Time estimate:** 20-30 minutes

---

## SITUATION

We intercepted communications from a junior operative who THINKS they're
using encryption. They're not. Every message here uses ENCODING — not
encryption. Anyone with the right tool can reverse it.

Your job: decode each message and assemble the final flag.

## OBJECTIVES

Decode all 5 messages below. Each gives you one word of the flag.
Assemble them in order: `FLAG{word1_word2_word3_word4_word5}`

## INTERCEPTED MESSAGES

### Message 1 (Format: Base64)
```
ZW5jb2Rpbmc=
```

### Message 2 (Format: Hexadecimal)
```
69 73 6e 6f 74
```

### Message 3 (Format: ROT13)
```
frphevgl
```

### Message 4 (Format: URL Encoding)
```
%69%74%73
```

### Message 5 (Format: Binary ASCII)
```
01101111 01100010 01110011 01100011 01110101 01110010 01101001 01110100 01111001
```

## RULES

- Figure out WHAT each encoding is (hint is in the label)
- Use command-line tools to decode (or write your own decoder)
- No online decoders — use the terminal!

## TOOLS YOU MIGHT NEED

```bash
echo "..." | base64 -d              # Base64 decode
echo "..." | xxd -r -p              # Hex to text
echo "..." | tr 'A-Za-z' 'N-ZA-Mn-za-m'  # ROT13
python3 -c "print(...)"            # Python for anything
printf '\x69\x73'                   # Hex escape in printf
```

---

*Assemble the flag, then check DEBRIEF.md*
