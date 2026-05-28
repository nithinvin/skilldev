#!/usr/bin/env python3
"""
JWT server with weak key (brute-forceable) for CTF Level 08.
Patches the "none" algorithm bug from Level 05.
"""
from http.server import HTTPServer, BaseHTTPRequestHandler
import json
import base64
import hmac
import hashlib
from urllib.parse import urlparse, parse_qs

# The weak secret — it's in the Level 07 wordlist!
JWT_SECRET = "dragon"

FLAG1 = "FLAG{jwt_claims_are_never_secret_only_signed}"
FLAG2 = "FLAG{weak_keys_fall_to_brute_force_in_seconds}"
FLAG3 = "FLAG{forge_master_the_keys_to_the_kingdom_are_yours}"


def base64url_encode(data):
    if isinstance(data, str):
        data = data.encode()
    return base64.urlsafe_b64encode(data).rstrip(b'=').decode()


def base64url_decode(data):
    padding = 4 - len(data) % 4
    if padding != 4:
        data += '=' * padding
    return base64.urlsafe_b64decode(data)


def create_jwt(payload):
    header = {"alg": "HS256", "typ": "JWT"}
    h = base64url_encode(json.dumps(header))
    p = base64url_encode(json.dumps(payload))
    sig = hmac.new(JWT_SECRET.encode(), f"{h}.{p}".encode(), hashlib.sha256).digest()
    s = base64url_encode(sig)
    return f"{h}.{p}.{s}"


def verify_jwt(token):
    """Verify JWT — no 'none' algorithm accepted."""
    parts = token.split('.')
    if len(parts) != 3:
        return None, "Token must have exactly 3 parts"

    try:
        header = json.loads(base64url_decode(parts[0]))
        payload = json.loads(base64url_decode(parts[1]))
    except Exception:
        return None, "Failed to decode token parts"

    # PATCHED: Reject algorithm "none"
    alg = header.get("alg", "")
    if alg.lower() == "none":
        return None, "Algorithm 'none' is not accepted (we patched that!)"

    if alg != "HS256":
        return None, f"Unsupported algorithm: {alg}"

    # Verify HMAC signature
    sig_input = f"{parts[0]}.{parts[1]}".encode()
    expected = hmac.new(JWT_SECRET.encode(), sig_input, hashlib.sha256).digest()
    actual = base64url_decode(parts[2])

    if not hmac.compare_digest(expected, actual):
        return None, "Invalid signature (key is wrong)"

    return payload, None


class ForgeHandler(BaseHTTPRequestHandler):

    def log_message(self, format, *args):
        pass

    def send_json(self, status, data):
        self.send_response(status)
        self.send_header("Content-Type", "application/json")
        self.end_headers()
        self.wfile.write(json.dumps(data, indent=2).encode())

    def get_token(self):
        auth = self.headers.get("Authorization", "")
        if auth.startswith("Bearer "):
            return auth[7:]
        return None

    def do_GET(self):
        parsed = urlparse(self.path)
        path = parsed.path
        params = parse_qs(parsed.query)

        if path == "/":
            self.send_json(200, {
                "message": "Forge Server v2.0 (none algorithm PATCHED)",
                "endpoints": {
                    "/login?user=<name>": "Get a signed token",
                    "/profile": "View token contents",
                    "/vault": "Admin only — requires forged token"
                },
                "security_notes": [
                    "Algorithm 'none' is now rejected",
                    "All tokens are properly signed with HS256",
                    "Good luck finding the key... it's not 'secret' anymore"
                ]
            })

        elif path == "/login":
            user = params.get("user", ["operative"])[0]
            payload = {
                "user": user,
                "role": "operative",
                "clearance": "level-2",
                "flag1": FLAG1
            }
            token = create_jwt(payload)
            self.send_json(200, {
                "token": token,
                "message": f"Token issued for {user}",
                "challenge": "The key is NOT 'secret'. But it IS a common word. Can you brute-force it?"
            })

        elif path == "/profile":
            token = self.get_token()
            if not token:
                self.send_json(401, {"error": "No token provided"})
                return
            payload, err = verify_jwt(token)
            if err:
                self.send_json(403, {"error": err})
                return
            self.send_json(200, {"profile": payload})

        elif path == "/vault":
            token = self.get_token()
            if not token:
                self.send_json(401, {"error": "Token required for vault access"})
                return
            payload, err = verify_jwt(token)
            if err:
                self.send_json(403, {
                    "error": err,
                    "hint": "You need to sign the token with the correct key"
                })
                return
            if payload.get("role") == "admin" and payload.get("clearance") == "level-5":
                self.send_json(200, {
                    "message": "VAULT ACCESS GRANTED",
                    "flag2": FLAG2,
                    "flag3": FLAG3,
                    "classified": {
                        "lesson": "HMAC keys must be long, random, and never in a dictionary",
                        "minimum_key_length": "256 bits (32 bytes) of random data",
                        "bad_keys": ["secret", "password", "dragon", "company_name", "jwt_key"],
                        "good_key_example": "openssl rand -hex 32"
                    }
                })
            else:
                self.send_json(403, {
                    "error": "Insufficient privileges",
                    "your_role": payload.get("role"),
                    "your_clearance": payload.get("clearance"),
                    "required": {"role": "admin", "clearance": "level-5"}
                })

        else:
            self.send_json(404, {"error": "Not found"})


if __name__ == "__main__":
    PORT = 7333
    server = HTTPServer(("127.0.0.1", PORT), ForgeHandler)
    print(f"[*] Forge Server running on http://localhost:{PORT}")
    print("[*] Press Ctrl+C to stop")
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("\n[*] Server stopped")
        server.shutdown()
