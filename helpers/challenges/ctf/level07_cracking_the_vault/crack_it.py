#!/usr/bin/env python3
"""
Password Hash Cracker — Starter Script
Fill in the TODO sections to crack the hashes!
"""
import hashlib

# Load the wordlist
def load_wordlist(filepath="wordlist.txt"):
    """Load passwords from wordlist file."""
    with open(filepath, 'r') as f:
        return [line.strip() for line in f if line.strip()]


def crack_md5(target_hash, wordlist):
    """
    Crack an MD5 hash using dictionary attack.
    
    TODO: For each word in the wordlist:
      1. Hash the word with MD5
      2. Compare to target_hash
      3. Return the word if match found
    
    Hint: hashlib.md5(word.encode()).hexdigest()
    """
    # YOUR CODE HERE
    pass


def crack_sha256(target_hash, wordlist):
    """
    Crack a SHA-256 hash using dictionary attack.
    
    TODO: Same approach as MD5 but with SHA-256
    
    Hint: hashlib.sha256(word.encode()).hexdigest()
    """
    # YOUR CODE HERE
    pass


def crack_sha256_salted(target_hash, salt, wordlist):
    """
    Crack a salted SHA-256 hash.
    
    TODO: The salt is PREPENDED to the password before hashing.
      hash = sha256(salt + password)
    
    Think about it: why does this make precomputed tables useless?
    """
    # YOUR CODE HERE
    pass


if __name__ == "__main__":
    wordlist = load_wordlist()
    print(f"[*] Loaded {len(wordlist)} passwords from wordlist")
    print()

    # Target hashes from leaked_hashes.txt
    md5_hash = "5f4dcc3b5aa765d61d8327deb882cf99"
    sha256_hash = "ef92b778bafe771e89245b89ecbc08a44a4e166c06659911881f383d4473e94f"
    salted_hash = "a3f5b6c8d2e1f9a0b4c7d8e2f1a0b3c5d6e7f8a9b0c1d2e3f4a5b6c7d8e9f0a1"
    salt = "pepper2024"

    print("[*] Cracking MD5 hash...")
    result = crack_md5(md5_hash, wordlist)
    if result:
        print(f"[+] CRACKED! Password is: {result}")
        print(f"[+] FLAG{{md5_is_dead_never_use_it_for_passwords}}")
    else:
        print("[-] Not cracked. Check your implementation.")

    print()
    print("[*] Cracking SHA-256 hash...")
    result = crack_sha256(sha256_hash, wordlist)
    if result:
        print(f"[+] CRACKED! Password is: {result}")
        print(f"[+] FLAG{{dictionary_attacks_defeat_weak_passwords}}")
    else:
        print("[-] Not cracked. Check your implementation.")

    print()
    print("[*] Cracking salted SHA-256 hash...")
    result = crack_sha256_salted(salted_hash, salt, wordlist)
    if result:
        print(f"[+] CRACKED! Password is: {result}")
    else:
        print("[-] Not cracked with this approach.")
        print("[*] FLAG{{salts_prevent_rainbow_tables_but_not_targeted_attacks}}")
        print("[*] The salt was known — if the salt is secret AND per-user,")
        print("    the attacker needs a separate attack per user.")

    print()
    print("[*] LESSON: Even SHA-256 falls to dictionary attacks if the password is weak.")
    print("[*] The REAL defense: bcrypt/argon2 (slow by design) + strong passwords.")
