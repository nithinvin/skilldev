# 🔬 REVERSE: The Cipher

**Difficulty:** [SPECIALIST]
**Type:** Reverse Engineering (Portal-style — understand the system, then exploit it)
**Skills:** Pattern recognition, cipher analysis, Python reading, deduction
**Time estimate:** 60-90 minutes

---

## SITUATION

We've captured an encryption program used by a target. We don't have documentation,
only the source code. Your mission: figure out what cipher it implements,
then decrypt the intercepted messages.

## FILES

- `cipher.py` — The encryption program (readable but uncommented)
- `intercepted.txt` — Three encrypted messages to decrypt

## OBJECTIVES

1. **FLAG #1**: Read `cipher.py` and identify what cipher algorithm it implements
2. **FLAG #2**: Decrypt the first message (the key is hidden in the program)
3. **FLAG #3**: Decrypt the third message (you'll need to figure out the key)

## RULES

- You MUST figure out the algorithm by reading the code (no running it first)
- After you understand it, you may write a decryption function
- The cipher is a REAL historical cipher (not made up)

## APPROACH

1. Read `cipher.py` carefully
2. Trace the logic: what does it do to each character?
3. Identify the pattern (substitution? transposition? polyalphabetic?)
4. Once you know the cipher, the decryption method becomes obvious
5. Apply it to the intercepted messages

## INTEL

- The cipher was invented in the 16th century
- It was considered unbreakable for 300 years
- It uses a keyword to shift each letter by a different amount
- It was broken by Charles Babbage / Friedrich Kasiski

---

*Read the code. Understand the cipher. Decrypt the messages.*
*Then check DEBRIEF.md.*
