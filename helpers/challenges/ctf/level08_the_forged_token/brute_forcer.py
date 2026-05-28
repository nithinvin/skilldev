#!/usr/bin/env python3
"""
JWT Brute-Forcer — Starter Script
Complete this to find the signing key!
"""
import hmac
import hashlib
import base64
import sys


def base64url_decode(data):
    """Decode base64url (add padding back)."""
    padding = 4 - len(data) % 4
    if padding != 4:
        data += '=' * padding
    return base64.urlsafe_b64decode(data)


def base64url_encode(data):
    """Encode to base64url (strip padding)."""
    if isinstance(data, str):
        data = data.encode()
    return base64.urlsafe_b64encode(data).rstrip(b'=').decode()


def brute_force_jwt(token, wordlist_path):
    """
    Given a JWT token and a wordlist, find the HMAC-SHA256 signing key.
    
    TODO:
    1. Split the token into header, payload, signature
    2. For each word in the wordlist:
       a. Compute HMAC-SHA256(header.payload, word)
       b. Compare to the actual signature
       c. If match → you found the key!
    """
    parts = token.split('.')
    if len(parts) != 3:
        print("Error: Invalid token format")
        return None

    # The signature input is: header_b64 + "." + payload_b64
    sig_input = f"{parts[0]}.{parts[1]}".encode()
    
    # The actual signature from the token
    actual_sig = base64url_decode(parts[2])

    # YOUR CODE HERE: load wordlist and try each word as the key
    # ...
    
    return None  # Return the key if found


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python3 brute_forcer.py <jwt_token> [wordlist_path]")
        print()
        print("Example:")
        print("  TOKEN=$(curl -s http://localhost:7333/login?user=test | python3 -c \"import sys,json;print(json.load(sys.stdin)['token'])\")")
        print("  python3 brute_forcer.py $TOKEN ../level07_cracking_the_vault/wordlist.txt")
        sys.exit(1)

    token = sys.argv[1]
    wordlist_path = sys.argv[2] if len(sys.argv) > 2 else "../level07_cracking_the_vault/wordlist.txt"

    print(f"[*] Token: {token[:50]}...")
    print(f"[*] Wordlist: {wordlist_path}")
    print("[*] Brute-forcing...")

    key = brute_force_jwt(token, wordlist_path)
    if key:
        print(f"[+] KEY FOUND: {key}")
        print()
        print("[*] Now forge a token:")
        print(f"    python3 -c \"")
        print(f"import hmac, hashlib, base64, json")
        print(f"def b64url(d): return base64.urlsafe_b64encode(d).rstrip(b'=').decode()")
        print(f"h = b64url(json.dumps({{'alg':'HS256','typ':'JWT'}}).encode())")
        print(f"p = b64url(json.dumps({{'user':'admin','role':'admin','clearance':'level-5'}}).encode())")
        print(f"s = b64url(hmac.new(b'{key}', f'{{h}}.{{p}}'.encode(), hashlib.sha256).digest())")
        print(f"print(f'{{h}}.{{p}}.{{s}}')\"")
    else:
        print("[-] Key not found in wordlist. Try a bigger dictionary?")
