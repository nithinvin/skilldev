"""
=============================================================================
Level 0.5 — Minimal HTTP Server (From Scratch)
=============================================================================

QUESTIONS (answer these BEFORE reading the code):

  1. HTTP is just text over TCP. What does an HTTP request look like?
     Request:
       GET / HTTP/1.1\r\n
       Host: example.com\r\n
       Connection: close\r\n
       \r\n

     Key parts:
       - Request line: METHOD PATH VERSION
       - Headers: Key: Value (one per line)
       - Blank line (\r\n\r\n) signals end of headers
       - Optional body (for POST/PUT)

  2. What does an HTTP response look like?
     Response:
       HTTP/1.1 200 OK\r\n
       Content-Type: text/html\r\n
       Content-Length: 44\r\n
       \r\n
       <html><body><h1>Hello!</h1></body></html>

     Key parts:
       - Status line: VERSION STATUS_CODE REASON
       - Headers
       - Blank line
       - Body

  3. What is Content-Type? Why does it matter?
     - Tells the browser HOW to interpret the body
     - text/html → render as a web page
     - application/json → it's structured data
     - text/plain → display as-is, no rendering
     - image/png → display as image
     - Without it, the browser GUESSES (and often guesses wrong)

  4. What's the minimum valid HTTP response?
     HTTP/1.1 200 OK\r\n\r\n
     → Just a status line and blank line. No headers, no body.
     → The browser shows a blank page. But it's valid!

HOW TO RUN:
  python3 03_http_server.py
  Then open http://localhost:8080 in your browser
  Or: curl -v http://localhost:8080

=============================================================================
"""

import socket
from datetime import datetime


def parse_request(raw_request: str) -> dict:
    """
    Parse a raw HTTP request string into its components.

    Q: Why do we need to parse? Can't we just look at the first line?
       → For this simple server, yes. But real servers need headers
         (like Host, Content-Type, Authorization, Cookies, etc.)
    """
    lines = raw_request.split('\r\n')

    # Request line: "GET /path HTTP/1.1"
    request_line = lines[0]
    parts = request_line.split(' ')

    if len(parts) != 3:
        return None  # Malformed request

    method, path, version = parts

    # Parse headers into a dict
    headers = {}
    for line in lines[1:]:
        if line == '':
            break  # Empty line = end of headers
        if ':' in line:
            key, value = line.split(':', 1)
            headers[key.strip().lower()] = value.strip()

    return {
        'method': method,
        'path': path,
        'version': version,
        'headers': headers,
    }


def build_response(status_code: int, status_text: str, content_type: str, body: str) -> bytes:
    """
    Build a complete HTTP response.

    Q: Why return bytes and not a string?
       → Network sockets send BYTES, not strings.
       → We must encode the string to bytes before sending.
       → HTTP/1.1 uses ASCII for headers, body can be any encoding.
    """
    response = (
        f"HTTP/1.1 {status_code} {status_text}\r\n"
        f"Content-Type: {content_type}\r\n"
        f"Content-Length: {len(body.encode('utf-8'))}\r\n"
        f"Connection: close\r\n"
        f"Server: MyBookShelf/0.1 (Learning)\r\n"
        f"Date: {datetime.utcnow().strftime('%a, %d %b %Y %H:%M:%S GMT')}\r\n"
        f"\r\n"
        f"{body}"
    )
    return response.encode('utf-8')


# --- Page content ---
# In Layer 1, this will come from actual HTML files.
# For now, it's hardcoded strings.

HOME_PAGE = """<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>MyBookShelf — From Scratch</title>
    <style>
        body {
            font-family: sans-serif;
            max-width: 700px;
            margin: 40px auto;
            padding: 0 20px;
            background: #f5f5f5;
            color: #333;
        }
        h1 { color: #2c3e50; }
        .info { background: #fff; padding: 20px; border-radius: 8px; margin: 20px 0; }
        code { background: #e8e8e8; padding: 2px 6px; border-radius: 3px; }
        a { color: #3498db; }
        table { border-collapse: collapse; width: 100%; }
        th, td { text-align: left; padding: 8px; border-bottom: 1px solid #ddd; }
        th { background: #3498db; color: white; }
    </style>
</head>
<body>
    <h1>📚 MyBookShelf</h1>
    <p>This page is served by a Python HTTP server built from <strong>raw TCP sockets</strong>.</p>
    <p>No Flask. No Django. No frameworks. Just <code>socket.socket()</code>.</p>

    <div class="info">
        <h2>How this works</h2>
        <ol>
            <li>Your browser opened a <strong>TCP connection</strong> to port 8080</li>
            <li>It sent an <strong>HTTP GET request</strong> (text over TCP)</li>
            <li>This Python script <strong>parsed</strong> the request</li>
            <li>It built an <strong>HTTP response</strong> with this HTML</li>
            <li>Your browser <strong>rendered</strong> the HTML into what you see</li>
        </ol>
    </div>

    <h2>My Books</h2>
    <table>
        <tr><th>Title</th><th>Author</th><th>Year</th></tr>
        <tr><td>Code</td><td>Charles Petzold</td><td>1999</td></tr>
        <tr><td>The C Programming Language</td><td>K&amp;R</td><td>1978</td></tr>
        <tr><td>SICP</td><td>Abelson &amp; Sussman</td><td>1996</td></tr>
    </table>

    <h2>Try These</h2>
    <ul>
        <li><a href="/">Home</a> (this page)</li>
        <li><a href="/about">About</a></li>
        <li><a href="/headers">See your request headers</a></li>
        <li><a href="/json">JSON response</a></li>
        <li><a href="/nonexistent">404 page</a></li>
    </ul>

    <p><small>Server: MyBookShelf/0.1 — Layer 0, Level 0.5</small></p>
</body>
</html>"""

ABOUT_PAGE = """<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>About — MyBookShelf</title>
    <style>
        body { font-family: sans-serif; max-width: 700px; margin: 40px auto; padding: 0 20px; }
        a { color: #3498db; }
    </style>
</head>
<body>
    <h1>About MyBookShelf</h1>
    <p>A learning project built layer by layer:</p>
    <ul>
        <li><strong>Layer 0</strong>: Linux, networking, raw sockets (you are here)</li>
        <li><strong>Layer 1</strong>: HTML, CSS, JavaScript</li>
        <li><strong>Layer 2</strong>: Backend server + database</li>
        <li><strong>Layer 3</strong>: REST API + authentication</li>
        <li>...and more</li>
    </ul>
    <p><a href="/">← Back to home</a></p>
</body>
</html>"""

NOT_FOUND_PAGE = """<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>404 — Not Found</title>
    <style>
        body { font-family: sans-serif; max-width: 700px; margin: 40px auto;
               padding: 0 20px; text-align: center; }
        h1 { font-size: 4rem; color: #e74c3c; }
        a { color: #3498db; }
    </style>
</head>
<body>
    <h1>404</h1>
    <p>The path <code>{path}</code> was not found on this server.</p>
    <p>This server only knows a few routes. That's okay — it's Layer 0!</p>
    <p><a href="/">← Back to home</a></p>
</body>
</html>"""


def handle_request(request: dict) -> bytes:
    """
    Route the request to the right handler and return an HTTP response.

    Q: This is basically what Flask's @app.route() does — but manually!
       In Layer 2, Flask will handle all this routing for you.
    """
    path = request['path']
    method = request['method']

    timestamp = datetime.now().strftime('%H:%M:%S')

    if path == '/' or path == '/index.html':
        response = build_response(200, 'OK', 'text/html', HOME_PAGE)

    elif path == '/about':
        response = build_response(200, 'OK', 'text/html', ABOUT_PAGE)

    elif path == '/headers':
        # Show the client their own request headers — educational!
        header_list = '\n'.join(f"  {k}: {v}" for k, v in request['headers'].items())
        body = (
            f"<html><body><h1>Your Request Headers</h1>"
            f"<pre>Method: {method}\nPath: {path}\n\nHeaders:\n{header_list}</pre>"
            f"<p><a href='/'>← Back</a></p></body></html>"
        )
        response = build_response(200, 'OK', 'text/html', body)

    elif path == '/json':
        # Demonstrate different Content-Type
        # Q: What happens if you set Content-Type to text/html but send JSON?
        #    → The browser tries to RENDER the JSON as HTML (it looks weird)
        import json
        data = json.dumps({
            "books": [
                {"title": "Code", "author": "Petzold", "year": 1999},
                {"title": "K&R C", "author": "Kernighan & Ritchie", "year": 1978},
            ],
            "server": "MyBookShelf/0.1",
            "your_headers": request['headers'],
        }, indent=2)
        response = build_response(200, 'OK', 'application/json', data)

    else:
        body = NOT_FOUND_PAGE.replace('{path}', path)
        response = build_response(404, 'Not Found', 'text/html', body)

    return response


def main():
    server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)

    host = '0.0.0.0'
    port = 8080
    server.bind((host, port))
    server.listen(5)

    print(f"{'='*60}")
    print(f"  MyBookShelf HTTP Server (from scratch!)")
    print(f"  http://localhost:{port}")
    print(f"{'='*60}")
    print(f"  Routes:")
    print(f"    GET /           → Home page with book list")
    print(f"    GET /about      → About page")
    print(f"    GET /headers    → See your request headers")
    print(f"    GET /json       → JSON response (different Content-Type)")
    print(f"    GET /anything   → 404 page")
    print(f"{'='*60}")
    print(f"  Press Ctrl+C to stop.\n")

    try:
        request_count = 0
        while True:
            client, addr = server.accept()

            # Receive the HTTP request
            raw_request = client.recv(4096).decode('utf-8', errors='replace')

            if not raw_request:
                client.close()
                continue

            request_count += 1
            timestamp = datetime.now().strftime('%H:%M:%S')

            # Parse it
            request = parse_request(raw_request)

            if request is None:
                # Malformed request — send 400
                response = build_response(400, 'Bad Request', 'text/plain', 'Bad Request\n')
                client.sendall(response)
                client.close()
                print(f"[{timestamp}] #{request_count} MALFORMED REQUEST from {addr[0]}")
                continue

            # Log the request (like nginx/Apache access logs)
            print(f"[{timestamp}] #{request_count} {request['method']} {request['path']} "
                  f"from {addr[0]}:{addr[1]}")

            # Handle it
            response = handle_request(request)

            # Send response
            client.sendall(response)
            client.close()

    except KeyboardInterrupt:
        print(f"\n\nServer stopped after {request_count} requests.")
    finally:
        server.close()


if __name__ == '__main__':
    main()
