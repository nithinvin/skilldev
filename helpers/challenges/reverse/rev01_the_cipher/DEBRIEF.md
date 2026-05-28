# DEBRIEF: The Cipher

## Code Analysis

### What `cipher.py` does:
```python
K = "VIGENERE"              # Default key

def t(c, k, d=1):          # Transform one character
    # Skip non-alpha chars
    # Get base ('A' or 'a')
    # Shift = position of key letter in alphabet (A=0, B=1, ..., Z=25)
    # New char = (original + direction * shift) mod 26
    
def p(text, key, decrypt=False):  # Process entire text
    # For each letter: apply shift from corresponding key letter
    # Key letter cycles through the key string
    # Non-alpha characters don't advance the key index
```

**This is the Vigenère cipher!**
- Each letter is shifted by the corresponding key letter
- Key repeats cyclically
- Decryption = same process but shift in reverse direction

## Solutions

### Flag 1: Identify the Cipher
The algorithm is the **Vigenère cipher** (1553, Giovan Battista Bellaso, attributed to Blaise de Vigenère).

### Flag 2: Decrypt Message 1 (key = "VIGENERE")
```bash
python3 cipher.py decrypt "ATGK{imxiimxi_pmglzz_ow_n_wzqktk_whfjxdbaxvse_gdxnie}"
```
**FLAG{vigenere_cipher_is_a_simple_substitution_cipher}**

### Flag 3: Decrypt Message 3 (key = "PYTHON")
```bash
python3 cipher.py decrypt "UJTN{iasckzhncbbuu_cprmlfah_gg_aski_dklehtlvpsf_plw_llcambag}" PYTHON
```
**FLAG{understanding_patterns_in_text_frequencies_and_exploits}**

## Mental Model

```
VIGENÈRE CIPHER:

  Plaintext:  A T T A C K A T D A W N
  Key:        V I G E N E R E V I G E  (repeats)
  Shift:      21 8 6 4 13 4 17 4 21 8 6 4
  Ciphertext: V B Z E P O R X Y I C R

ENCRYPTION: ciphertext[i] = (plaintext[i] + key[i]) mod 26
DECRYPTION: plaintext[i] = (ciphertext[i] - key[i]) mod 26

WHY IT WAS "UNBREAKABLE" FOR 300 YEARS:
  - Single letter frequency analysis doesn't work
  - 'E' doesn't always map to the same ciphertext letter
  - Different key positions create different substitution alphabets
  
HOW IT WAS BROKEN (Kasiski examination):
  1. Find repeated sequences in ciphertext
  2. Distance between repetitions = multiple of key length
  3. GCD of distances = key length
  4. Once you know key length, split into groups
  5. Each group is a simple Caesar cipher → frequency analysis!

CIPHER EVOLUTION:
├── Caesar (shift cipher)     — one shift for all letters (trivial)
├── Substitution              — fixed letter mapping (frequency analysis)
├── Vigenère                  — rotating shifts (broken by Kasiski)
├── Enigma                    — mechanical rotation (broken by Turing)
├── DES/AES                   — block ciphers (modern, math-based)
└── RSA/ECC                   — public key (based on hard math problems)

CODE READING STRATEGY:
  1. Identify the inputs and outputs
  2. Trace ONE character through the transformation
  3. Look for patterns: modular arithmetic → cipher
  4. Variable names may be misleading (or helpful, like K = "VIGENERE")
  5. Test your theory with a known input/output pair
```

## The Lesson

**Reading code you didn't write is a CORE skill.**

This challenge teaches:
1. Reverse engineering from source (no docs, minimal names)
2. Pattern recognition in algorithms
3. Relating code to known mathematical constructs
4. The difference between knowing a cipher exists and implementing it

## Skills Unlocked
- Vigenère cipher (encrypt + decrypt)
- Code reading without documentation
- Tracing variable transformations
- Modular arithmetic in cryptography
- Historical context of cipher evolution
- Key-based vs keyless transformations
