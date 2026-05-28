#!/usr/bin/env python3
"""
Intentionally vulnerable login server for SQL Injection CTF.
DO NOT deploy this anywhere real. This is educational only.
"""
from http.server import HTTPServer, BaseHTTPRequestHandler
import sqlite3
import json
import os
from urllib.parse import parse_qs

DB_PATH = "/tmp/vuln_login.db"

FLAG1 = "FLAG{sql_injection_bypasses_authentication_logic}"
FLAG2 = "FLAG{union_select_dumps_the_entire_database}"
FLAG3 = "FLAG{never_concatenate_user_input_into_sql_queries}"


def setup_database():
    """Create the vulnerable database."""
    if os.path.exists(DB_PATH):
        os.unlink(DB_PATH)
    
    conn = sqlite3.connect(DB_PATH)
    c = conn.cursor()
    
    c.execute('''CREATE TABLE users (
        id INTEGER PRIMARY KEY,
        username TEXT,
        password TEXT,
        role TEXT
    )''')
    
    c.execute('''CREATE TABLE secrets (
        id INTEGER PRIMARY KEY,
        flag TEXT,
        description TEXT
    )''')
    
    # Insert users
    users = [
        (1, "admin", "Sup3rS3cr3tP@ss!", "admin"),
        (2, "guest", "guest123", "user"),
        (3, "dev", "debugging2024", "developer"),
        (4, "backup", "backup_routine_99", "service"),
    ]
    c.executemany("INSERT INTO users VALUES (?,?,?,?)", users)
    
    # Insert flags
    secrets = [
        (1, FLAG2, "Extracted via UNION SELECT"),
        (2, FLAG3, "You should use parameterized queries"),
    ]
    c.executemany("INSERT INTO secrets VALUES (?,?,?)", secrets)
    
    conn.commit()
    conn.close()


class VulnLoginHandler(BaseHTTPRequestHandler):

    def log_message(self, format, *args):
        pass

    def send_json(self, status, data):
        self.send_response(status)
        self.send_header("Content-Type", "application/json")
        self.end_headers()
        self.wfile.write(json.dumps(data, indent=2).encode())

    def do_GET(self):
        if self.path == "/":
            self.send_json(200, {
                "message": "Vulnerable Login Server (EDUCATIONAL ONLY)",
                "endpoints": {
                    "POST /login": "Submit username & password",
                    "GET /search?q=<query>": "Search users (also vulnerable)"
                },
                "hint": "The login form is vulnerable to SQL injection"
            })
        elif self.path.startswith("/search"):
            self.handle_search()
        else:
            self.send_json(404, {"error": "Not found"})

    def do_POST(self):
        if self.path == "/login":
            self.handle_login()
        else:
            self.send_json(404, {"error": "Not found"})

    def handle_login(self):
        """VULNERABLE: SQL injection in login."""
        content_length = int(self.headers.get('Content-Length', 0))
        body = self.rfile.read(content_length).decode()
        params = parse_qs(body)
        
        username = params.get("username", [""])[0]
        password = params.get("password", [""])[0]

        conn = sqlite3.connect(DB_PATH)
        c = conn.cursor()

        # VULNERABLE QUERY — direct string concatenation!
        query = f"SELECT * FROM users WHERE username='{username}' AND password='{password}'"
        
        try:
            c.execute(query)
            results = c.fetchall()
            
            if results:
                user = results[0]
                response = {
                    "status": "Login successful!",
                    "user": user[1],
                    "role": user[3] if len(user) > 3 else "unknown",
                    "flag1": FLAG1,
                    "query_executed": query,
                    "lesson": "The SQL was manipulated by your input!"
                }
                # If multiple results (UNION injection), show all
                if len(results) > 1:
                    response["all_results"] = [list(r) for r in results]
                    response["flag2"] = FLAG2
                self.send_json(200, response)
            else:
                self.send_json(401, {
                    "status": "Login failed",
                    "query_executed": query,
                    "hint": "Look at the query. Can you make it return true?"
                })
        except sqlite3.Error as e:
            self.send_json(500, {
                "error": f"SQL Error: {str(e)}",
                "query_attempted": query,
                "hint": "The error message reveals the database structure!"
            })
        finally:
            conn.close()

    def handle_search(self):
        """VULNERABLE: SQL injection in search."""
        from urllib.parse import urlparse, parse_qs as url_parse_qs
        parsed = urlparse(self.path)
        params = url_parse_qs(parsed.query)
        q = params.get("q", [""])[0]

        conn = sqlite3.connect(DB_PATH)
        c = conn.cursor()

        # ANOTHER vulnerable query
        query = f"SELECT username, role FROM users WHERE username LIKE '%{q}%'"

        try:
            c.execute(query)
            results = c.fetchall()
            self.send_json(200, {
                "results": [{"username": r[0], "role": r[1]} for r in results],
                "query": query
            })
        except sqlite3.Error as e:
            self.send_json(500, {
                "error": f"SQL Error: {str(e)}",
                "query": query
            })
        finally:
            conn.close()


if __name__ == "__main__":
    setup_database()
    PORT = 7334
    server = HTTPServer(("127.0.0.1", PORT), VulnLoginHandler)
    print(f"[*] Vulnerable Login Server on http://localhost:{PORT}")
    print("[*] Database created at {DB_PATH}")
    print("[*] Press Ctrl+C to stop")
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("\n[*] Server stopped")
        server.shutdown()
