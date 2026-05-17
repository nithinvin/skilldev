"""
=============================================================================
Level 0.5 Extension — HTTP Server That Serves Files from Disk
=============================================================================

This builds on 03_http_server.py. Read that first!

WHAT'S NEW:
  This server reads actual HTML/CSS/JS files from a directory.
  This is what nginx and Apache do (static file serving).

  In Layer 1, you'll create HTML/CSS/JS files and serve them with this.

QUESTIONS:
  1. What is a MIME type? (same as Content-Type)
     - A label telling the browser what kind of data the file contains
     - .html → text/html, .css → text/css, .js → text/javascript
     - .png → image/png, .jpg → image/jpeg, .json → application/json
     - Getting this WRONG = browser misinterprets the file

  2. What is path traversal?
     - Attacker requests: GET /../../../etc/passwd
     - Naive server: reads /etc/passwd and sends it back!
     - Defense: resolve the path and verify it stays within the document root
     - We implement this below.

  3. What is a MIME type sniffing attack?
     - Browser ignores Content-Type and GUESSES the type
     - Attacker uploads malicious.html as malicious.txt
     - Browser sniffs it as HTML and executes embedded JavaScript!
     - Defense: X-Content-Type-Options: nosniff header

HOW TO RUN:
  mkdir -p /tmp/mybookshelf-www
  echo '<h1>Hello from a file!</h1>' > /tmp/mybookshelf-www/index.html
  python3 04_http_file_server.py /tmp/mybookshelf-www

  Or use the default directory:
  python3 04_http_file_server.py

=============================================================================
"""

import socket
import os
import sys
from datetime import datetime
from pathlib import Path


# MIME type mapping
# Q: What happens if we serve a .css file with Content-Type: text/html?
#    → Browser won't apply the styles! It thinks it's HTML, not CSS.
MIME_TYPES = {
    '.html': 'text/html; charset=utf-8',
    '.htm':  'text/html; charset=utf-8',
    '.css':  'text/css; charset=utf-8',
    '.js':   'text/javascript; charset=utf-8',
    '.json': 'application/json; charset=utf-8',
    '.txt':  'text/plain; charset=utf-8',
    '.png':  'image/png',
    '.jpg':  'image/jpeg',
    '.jpeg': 'image/jpeg',
    '.gif':  'image/gif',
    '.svg':  'image/svg+xml',
    '.ico':  'image/x-icon',
    '.woff': 'font/woff',
    '.woff2': 'font/woff2',
}


def get_mime_type(filepath: str) -> str:
    """Get MIME type from file extension."""
    ext = Path(filepath).suffix.lower()
    return MIME_TYPES.get(ext, 'application/octet-stream')


def is_safe_path(document_root: str, requested_path: str) -> bool:
    """
    Prevent path traversal attacks.

    Q: Why is this necessary?
       Without this check:
         GET /../../../etc/passwd HTTP/1.1
       Would resolve to /etc/passwd and serve your password file!

    Q: How does this work?
       1. Resolve the full absolute path (follows .., symlinks, etc.)
       2. Check that the result STARTS WITH the document root
       3. If not, it's an escape attempt → deny
    """
    # Resolve to absolute path
    full_path = os.path.realpath(os.path.join(document_root, requested_path.lstrip('/')))
    # Must be within document root
    return full_path.startswith(os.path.realpath(document_root))


def build_response(status_code: int, status_text: str, content_type: str, body: bytes) -> bytes:
    """Build HTTP response with binary body (for images etc.)."""
    headers = (
        f"HTTP/1.1 {status_code} {status_text}\r\n"
        f"Content-Type: {content_type}\r\n"
        f"Content-Length: {len(body)}\r\n"
        f"Connection: close\r\n"
        f"Server: MyBookShelf-FileServer/0.1\r\n"
        f"X-Content-Type-Options: nosniff\r\n"
        f"Date: {datetime.utcnow().strftime('%a, %d %b %Y %H:%M:%S GMT')}\r\n"
        f"\r\n"
    )
    return headers.encode('utf-8') + body


def serve_file(document_root: str, path: str) -> bytes:
    """
    Serve a file from the document root.

    This is the core of what nginx does for static files!
    """
    # Default to index.html for directory requests
    if path == '/' or path.endswith('/'):
        path = path + 'index.html'

    # Security: prevent path traversal
    if not is_safe_path(document_root, path):
        return build_response(403, 'Forbidden', 'text/plain', b'403 Forbidden: Path traversal detected\n')

    # Build the full filesystem path
    filepath = os.path.join(document_root, path.lstrip('/'))

    # Check if it's a directory (serve index.html inside it)
    if os.path.isdir(filepath):
        filepath = os.path.join(filepath, 'index.html')

    # Check if file exists
    if not os.path.isfile(filepath):
        body = f"<h1>404 Not Found</h1><p>File not found: {path}</p>".encode('utf-8')
        return build_response(404, 'Not Found', 'text/html', body)

    # Read and serve the file
    content_type = get_mime_type(filepath)
    try:
        with open(filepath, 'rb') as f:  # rb = read binary (works for all file types)
            body = f.read()
        return build_response(200, 'OK', content_type, body)
    except PermissionError:
        return build_response(403, 'Forbidden', 'text/plain', b'403 Forbidden\n')


def main():
    # Document root: where to serve files from
    if len(sys.argv) > 1:
        document_root = sys.argv[1]
    else:
        # Default: create a sample directory
        document_root = os.path.join(os.path.dirname(__file__), '..', 'www')
        os.makedirs(document_root, exist_ok=True)

        # Create a sample index.html if it doesn't exist
        index_path = os.path.join(document_root, 'index.html')
        if not os.path.exists(index_path):
            with open(index_path, 'w') as f:
                f.write("""<!DOCTYPE html>
<html>
<head>
    <title>MyBookShelf — File Server</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>
    <h1>📚 MyBookShelf File Server</h1>
    <p>This HTML file is being read from <strong>disk</strong> and served over HTTP.</p>
    <p>Edit the files in the <code>www/</code> directory and refresh to see changes!</p>
    <p>Try: <a href="/style.css">View the CSS file</a></p>
    <script src="app.js"></script>
</body>
</html>""")

        # Create a sample CSS file
        css_path = os.path.join(document_root, 'style.css')
        if not os.path.exists(css_path):
            with open(css_path, 'w') as f:
                f.write("""body {
    font-family: sans-serif;
    max-width: 700px;
    margin: 40px auto;
    padding: 0 20px;
    background: #f0f0f0;
    color: #333;
}
h1 { color: #2c3e50; }
code { background: #ddd; padding: 2px 6px; border-radius: 3px; }
a { color: #3498db; }
""")

        # Create a sample JS file
        js_path = os.path.join(document_root, 'app.js')
        if not os.path.exists(js_path):
            with open(js_path, 'w') as f:
                f.write("""// This JavaScript file is served by our custom HTTP server!
console.log("app.js loaded — served from raw TCP socket server 🚀");

// Add a dynamic element to prove JS is executing
const footer = document.createElement('p');
footer.style.color = '#888';
footer.style.marginTop = '30px';
footer.textContent = `Page loaded at ${new Date().toLocaleTimeString()} — JS is running!`;
document.body.appendChild(footer);
""")

    document_root = os.path.abspath(document_root)

    if not os.path.isdir(document_root):
        print(f"Error: {document_root} is not a directory")
        sys.exit(1)

    # Start the server
    server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)

    host = '0.0.0.0'
    port = 8080
    server.bind((host, port))
    server.listen(5)

    print(f"{'='*60}")
    print(f"  MyBookShelf File Server")
    print(f"  http://localhost:{port}")
    print(f"  Serving: {document_root}")
    print(f"{'='*60}")
    print(f"  Files in document root:")
    for f in sorted(os.listdir(document_root)):
        size = os.path.getsize(os.path.join(document_root, f))
        print(f"    {f} ({size} bytes)")
    print(f"{'='*60}")
    print(f"  Press Ctrl+C to stop.\n")

    try:
        request_count = 0
        while True:
            client, addr = server.accept()
            raw_request = client.recv(4096).decode('utf-8', errors='replace')

            if not raw_request:
                client.close()
                continue

            request_count += 1
            timestamp = datetime.now().strftime('%H:%M:%S')

            # Parse request line
            try:
                request_line = raw_request.split('\r\n')[0]
                method, path, version = request_line.split(' ')
            except (ValueError, IndexError):
                response = build_response(400, 'Bad Request', 'text/plain', b'Bad Request\n')
                client.sendall(response)
                client.close()
                continue

            # Strip query string (everything after ?)
            path = path.split('?')[0]

            # Serve the file
            response = serve_file(document_root, path)
            client.sendall(response)
            client.close()

            # Log in Apache/nginx format
            status = 200 if b'200 OK' in response[:50] else (404 if b'404' in response[:50] else 403)
            print(f"[{timestamp}] {addr[0]} - \"{method} {path}\" {status}")

    except KeyboardInterrupt:
        print(f"\n\nServer stopped after {request_count} requests.")
    finally:
        server.close()


if __name__ == '__main__':
    main()
