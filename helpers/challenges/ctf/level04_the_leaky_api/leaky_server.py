#!/usr/bin/env python3
"""
Intentionally vulnerable API for CTF Level 04.
DO NOT deploy this anywhere real. It's designed to be broken.
"""
from http.server import HTTPServer, BaseHTTPRequestHandler
import json

FLAG1 = "FLAG{always_check_debug_endpoints_in_production}"
FLAG2 = "FLAG{http_methods_matter_options_reveals_secrets}"
FLAG3 = "FLAG{default_credentials_are_the_first_thing_attackers_try}"


class LeakyHandler(BaseHTTPRequestHandler):

    def log_message(self, format, *args):
        """Suppress default logging to keep things clean."""
        pass

    def send_json(self, status, data):
        self.send_response(status)
        self.send_header("Content-Type", "application/json")
        self.end_headers()
        self.wfile.write(json.dumps(data, indent=2).encode())

    def do_GET(self):
        if self.path == "/":
            self.send_json(200, {
                "message": "Welcome to the API",
                "version": "1.0.3",
                "endpoints": ["/api/users", "/api/status"]
            })

        elif self.path == "/api/users":
            self.send_json(200, {
                "users": [
                    {"id": 1, "name": "agent_n", "role": "operative"},
                    {"id": 2, "name": "admin", "role": "admin"}
                ]
            })

        elif self.path == "/api/status":
            self.send_json(200, {"status": "operational", "uptime": "47h"})

        # Hidden debug endpoint — FLAG #1
        elif self.path == "/debug" or self.path == "/api/debug":
            self.send_json(200, {
                "debug_mode": True,
                "flag": FLAG1,
                "note": "TODO: disable before production deploy",
                "internal_config": {
                    "db_host": "localhost:5432",
                    "secret_key": "changeme123"
                }
            })

        elif self.path == "/api/admin":
            # Check for auth header
            auth = self.headers.get("Authorization", "")
            api_key = self.headers.get("X-API-Key", "")

            if auth == "Bearer admin" or api_key == "admin":
                # Weak token accepted — FLAG #3
                self.send_json(200, {
                    "access": "granted",
                    "flag": FLAG3,
                    "admin_panel": "You're in. The developer used 'admin' as the token.",
                    "lesson": "Never use default/guessable credentials"
                })
            else:
                self.send_json(401, {
                    "error": "Unauthorized",
                    "hint": "This endpoint requires authentication. Check common auth headers."
                })

        else:
            self.send_json(404, {"error": "Not found"})

    def do_POST(self):
        if self.path == "/api/users":
            # POST reveals different data than GET
            self.send_json(200, {
                "message": "Interesting... POST to /api/users",
                "hint": "Close, but try other methods too. What does OPTIONS tell you?"
            })
        else:
            self.send_json(405, {"error": "Method not allowed on this path"})

    def do_OPTIONS(self):
        if self.path == "/api/users":
            # OPTIONS reveals the flag — FLAG #2
            self.send_response(200)
            self.send_header("Allow", "GET, POST, OPTIONS, DELETE")
            self.send_header("X-Hidden-Flag", FLAG2)
            self.send_header("X-Debug-Note", "The OPTIONS method reveals allowed methods AND sometimes secrets in headers")
            self.send_header("Content-Type", "application/json")
            self.end_headers()
            self.wfile.write(json.dumps({
                "allowed_methods": ["GET", "POST", "OPTIONS", "DELETE"],
                "note": "Check the response HEADERS, not just the body",
                "flag_location": "X-Hidden-Flag response header"
            }, indent=2).encode())
        else:
            self.send_response(200)
            self.send_header("Allow", "GET, OPTIONS")
            self.end_headers()

    def do_DELETE(self):
        self.send_json(403, {
            "error": "Nice try. DELETE is disabled for safety.",
            "message": "In a real pentest, finding enabled DELETE is a critical vuln."
        })

    def do_PUT(self):
        self.send_json(405, {"error": "Method not allowed"})


if __name__ == "__main__":
    PORT = 7331
    server = HTTPServer(("127.0.0.1", PORT), LeakyHandler)
    print(f"[*] Leaky API running on http://localhost:{PORT}")
    print("[*] Press Ctrl+C to stop")
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("\n[*] Server stopped")
        server.shutdown()
