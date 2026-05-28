#!/usr/bin/env python3
"""
Intentionally vulnerable JWT server for CTF Level 05.
DO NOT deploy this anywhere real. Multiple deliberate vulnerabilities.
"""
from http.server import HTTPServer, BaseHTTPRequestHandler
import json
import base64
import hmac
import hashlib
from urllib.parse import urlparse, parse_qs

# Deliberately weak secret (this IS the vulnerability)
JWT_SECRET = "secret"

FLAG1 = "FLAG{jwt_payload_is_just_base64_anyone_can_read_it}"
FLAG2 = "FLAG{algorithm_none_attack_bypasses_signature_verification}"
FLAG3 = "FLAG{never_trust_client_side_role_claims_without_server_validation}"


def base64url_encode(data):
    """Base64URL encode (no padding)."""
    if isinstance(data, str):
        data = data.encode()
    return base64.urlsafe_b64encode(data).rstrip(b'=').decode()


def base64url_decode(data):
    """Base64URL decode (add padding back)."""
    padding = 4 - len(data) % 4
    if padding != 4:
        data += '=' * padding
    return base64.urlsafe_b64decode(data)


def create_jwt(payload):
    """Create a JWT with HS256."""
    header = {"alg": "HS256", "typ": "JWT"}
    h = base64url_encode(json.dumps(header))
    p = base64url_encode(json.dumps(payload))
    signature_input = f"{h}.{p}".encode()
    sig = hmac.new(JWT_SECRET.encode(), signature_input, hashlib.sha256).digest()
    s = base64url_encode(sig)
    return f"{h}.{p}.{s}"


def verify_jwt(token):
    """
    Verify JWT — INTENTIONALLY VULNERABLE.
    Accepts alg:none (this is the CVE-2015-2951 vulnerability).
    """
    parts = token.split('.')
    if len(parts) < 2:
        return None

    try:
        header = json.loads(base64url_decode(parts[0]))
        payload = json.loads(base64url_decode(parts[1]))
    except Exception:
        return None

    # VULNERABILITY: Accept "none" algorithm (no signature check!)
    if header.get("alg", "").lower() == "none":
        return payload

    # VULNERABILITY: Weak secret "secret" is easily guessable
    if len(parts) == 3:
        signature_input = f"{parts[0]}.{parts[1]}".encode()
        expected_sig = hmac.new(
            JWT_SECRET.encode(), signature_input, hashlib.sha256
        ).digest()
        actual_sig = base64url_decode(parts[2])
        if hmac.compare_digest(expected_sig, actual_sig):
            return payload

    return None


class CookieHandler(BaseHTTPRequestHandler):

    def log_message(self, format, *args):
        pass

    def send_json(self, status, data, headers=None):
        self.send_response(status)
        self.send_header("Content-Type", "application/json")
        if headers:
            for k, v in headers.items():
                self.send_header(k, v)
        self.end_headers()
        self.wfile.write(json.dumps(data, indent=2).encode())

    def get_token(self):
        """Extract token from Authorization header or cookie."""
        auth = self.headers.get("Authorization", "")
        if auth.startswith("Bearer "):
            return auth[7:]
        cookie = self.headers.get("Cookie", "")
        for part in cookie.split(";"):
            part = part.strip()
            if part.startswith("token="):
                return part[6:]
        return None

    def do_GET(self):
        parsed = urlparse(self.path)
        path = parsed.path
        params = parse_qs(parsed.query)

        if path == "/":
            self.send_json(200, {
                "message": "Cookie Monster Auth Server",
                "endpoints": {
                    "/login?user=<name>": "Get a token (try 'guest')",
                    "/profile": "View your profile (needs token)",
                    "/admin": "Admin only (needs admin token)"
                },
                "how_to_auth": "Send token as: Authorization: Bearer <token>"
            })

        elif path == "/login":
            user = params.get("user", ["anonymous"])[0]
            payload = {
                "user": user,
                "role": "guest",
                "flag1": FLAG1,
                "hint": "Decode this JWT. Change the role. Bypass the signature."
            }
            token = create_jwt(payload)
            self.send_json(200, {
                "message": f"Welcome, {user}!",
                "token": token,
                "instructions": [
                    "This is your JWT. It has 3 parts separated by dots.",
                    "Try: echo '<part>' | base64 -d",
                    "The payload contains your role. Can you change it?",
                    "The signature prevents tampering... or does it?"
                ]
            }, {"Set-Cookie": f"token={token}; Path=/"})

        elif path == "/profile":
            token = self.get_token()
            if not token:
                self.send_json(401, {"error": "No token. Login first at /login?user=guest"})
                return
            payload = verify_jwt(token)
            if not payload:
                self.send_json(403, {
                    "error": "Invalid token signature",
                    "hint": "Try algorithm 'none' (no quotes) in the header, or sign with key 'secret'"
                })
                return
            self.send_json(200, {
                "message": f"Hello, {payload.get('user', 'unknown')}",
                "role": payload.get("role", "unknown"),
                "token_contents": payload
            })

        elif path == "/admin":
            token = self.get_token()
            if not token:
                self.send_json(401, {"error": "Authentication required"})
                return
            payload = verify_jwt(token)
            if not payload:
                self.send_json(403, {
                    "error": "Invalid token",
                    "flag2_hint": FLAG2
                })
                return
            if payload.get("role") == "admin":
                self.send_json(200, {
                    "message": "Welcome, Admin!",
                    "flag3": FLAG3,
                    "lesson": "JWTs should NEVER trust alg:none in production",
                    "real_world": "CVE-2015-2951 affected many JWT libraries"
                })
            else:
                self.send_json(403, {
                    "error": f"Access denied. Your role is '{payload.get('role')}'",
                    "hint": "You need role:admin. The token is just base64... modify it."
                })

        else:
            self.send_json(404, {"error": "Not found"})


if __name__ == "__main__":
    PORT = 7332
    server = HTTPServer(("127.0.0.1", PORT), CookieHandler)
    print(f"[*] Cookie Monster running on http://localhost:{PORT}")
    print("[*] Press Ctrl+C to stop")
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("\n[*] Server stopped")
        server.shutdown()
