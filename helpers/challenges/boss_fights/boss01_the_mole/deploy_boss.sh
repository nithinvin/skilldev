#!/bin/bash
# Deploy Boss Fight: The Mole
# Creates a git repo with a planted backdoor

set -e

BASE="/tmp/boss_the_mole"
rm -rf "$BASE"
mkdir -p "$BASE"
cd "$BASE"

echo "[*] Deploying Boss Fight: The Mole..."

# Initialize git repo
git init -q
git config user.email "dev@company.internal"
git config user.name "Sarah Chen"

# ============================================================
# Commit 1: Initial project structure (legitimate)
# ============================================================
mkdir -p app templates static

cat > app/__init__.py << 'EOF'
"""Simple Flask-like web application."""
EOF

cat > app/routes.py << 'EOF'
"""Main application routes."""
from app.utils import sanitize_input, log_request
from app.auth import require_login


def handle_index(request):
    """Serve the main page."""
    log_request(request)
    return {"status": "ok", "page": "index"}


def handle_login(request):
    """Process login form."""
    username = sanitize_input(request.get("username", ""))
    password = request.get("password", "")
    if not username or not password:
        return {"status": "error", "message": "Missing credentials"}
    return {"status": "ok", "user": username}


def handle_api_status(request):
    """Return API health check."""
    return {"status": "healthy", "version": "2.1.0"}
EOF

cat > app/auth.py << 'EOF'
"""Authentication module."""
import hashlib


def require_login(func):
    """Decorator to require authentication."""
    def wrapper(request):
        token = request.get("auth_token")
        if not token:
            return {"status": "error", "message": "Not authenticated"}
        return func(request)
    return wrapper


def hash_password(password, salt="app_salt_2024"):
    """Hash a password with SHA-256 and salt."""
    return hashlib.sha256(f"{salt}{password}".encode()).hexdigest()


def verify_token(token):
    """Verify an authentication token."""
    # Simple token verification
    return len(token) == 64 and all(c in '0123456789abcdef' for c in token)
EOF

cat > app/utils.py << 'EOF'
"""Utility functions for the application."""
import re
import time


def sanitize_input(text):
    """Remove potentially dangerous characters from input."""
    # Strip HTML tags
    text = re.sub(r'<[^>]+>', '', text)
    # Remove SQL injection attempts
    dangerous = ['DROP', 'DELETE', 'INSERT', '--', ';', 'UNION']
    for word in dangerous:
        text = text.replace(word, '')
    return text.strip()


def log_request(request):
    """Log incoming request for debugging."""
    timestamp = time.strftime("%Y-%m-%d %H:%M:%S")
    method = request.get("method", "GET")
    path = request.get("path", "/")
    print(f"[{timestamp}] {method} {path}")


def format_response(data, status_code=200):
    """Format response data."""
    return {
        "code": status_code,
        "data": data,
        "timestamp": time.time()
    }
EOF

cat > requirements.txt << 'EOF'
flask==3.0.0
gunicorn==21.2.0
python-dotenv==1.0.0
EOF

cat > README.md << 'EOF'
# Internal Dashboard

Simple internal dashboard for team operations.

## Setup
```
pip install -r requirements.txt
python run.py
```

## Routes
- GET / — Main dashboard
- POST /login — Authentication
- GET /api/status — Health check
- POST /api/analytics — Process analytics data
EOF

git add -A
git commit -q -m "Initial project setup" --date="2024-03-01 09:00:00"

# ============================================================
# Commit 2: Add templates (legitimate, different author)
# ============================================================
git config user.email "mike.r@company.internal"
git config user.name "Mike Rodriguez"

cat > templates/index.html << 'EOF'
<!DOCTYPE html>
<html>
<head><title>Dashboard</title></head>
<body>
    <h1>Internal Dashboard</h1>
    <div id="status"></div>
    <script src="/static/app.js"></script>
</body>
</html>
EOF

cat > static/app.js << 'EOF'
// Dashboard client-side code
async function checkStatus() {
    const resp = await fetch('/api/status');
    const data = await resp.json();
    document.getElementById('status').textContent = 
        `Status: ${data.status} | Version: ${data.version}`;
}
checkStatus();
EOF

git add -A
git commit -q -m "Add frontend templates" --date="2024-03-03 14:30:00"

# ============================================================
# Commit 3: THE MOLE'S COMMIT — backdoor disguised as "analytics"
# ============================================================
git config user.email "alex.dev@company.internal" 
git config user.name "Alex Petrov"
# Hidden identity in committer vs author
GIT_COMMITTER_EMAIL="shadow0ps@proton.me" \
GIT_COMMITTER_NAME="Alex Petrov" \
git config user.email "alex.dev@company.internal"

cat > app/analytics.py << 'EOF'
"""Analytics processing module.

Handles incoming analytics data from the dashboard.
Supports custom metric transformations for flexible reporting.
"""
import base64
import json
import time


# Analytics configuration
METRICS_VERSION = "2.1"
SUPPORTED_FORMATS = ["json", "csv", "custom"]


def process_analytics(request):
    """
    Process incoming analytics payload.
    
    Accepts JSON analytics data and applies configured transformations.
    Supports 'custom' format for advanced metric calculations.
    """
    data = request.get("data", {})
    format_type = request.get("format", "json")
    
    if format_type == "json":
        return _process_json_metrics(data)
    elif format_type == "csv":
        return _process_csv_metrics(data)
    elif format_type == "custom":
        # Advanced: apply custom transformation expression
        return _apply_custom_transform(data)
    else:
        return {"error": f"Unsupported format: {format_type}"}


def _process_json_metrics(data):
    """Standard JSON metrics processing."""
    metrics = data.get("metrics", [])
    result = {
        "processed": len(metrics),
        "timestamp": time.time(),
        "version": METRICS_VERSION
    }
    return result


def _process_csv_metrics(data):
    """CSV format metrics processing."""
    rows = data.get("rows", "").split("\n")
    return {"processed": len(rows), "format": "csv"}


def _apply_custom_transform(data):
    """
    Apply a custom transformation to metrics data.
    
    The transform field contains a Base64-encoded calculation expression
    that is evaluated against the provided metrics context.
    This allows flexible server-side metric aggregation.
    """
    transform = data.get("transform", "")
    context = data.get("context", {})
    
    if not transform:
        return {"error": "No transform specified"}
    
    try:
        # Decode the transformation expression
        # FLAG{eval_is_always_a_backdoor_in_disguise}
        expression = base64.b64decode(transform).decode('utf-8')
        
        # Execute the calculation in a metrics context
        result = eval(expression, {"__builtins__": {}}, context)
        return {"result": result, "type": "custom_metric"}
    except Exception as e:
        return {"error": f"Transform failed: {str(e)}"}


def get_analytics_summary():
    """Return analytics system summary."""
    return {
        "version": METRICS_VERSION,
        "formats": SUPPORTED_FORMATS,
        "status": "active"
    }
EOF

# Also add the route for it (looks normal)
cat >> app/routes.py << 'EOF'


def handle_analytics(request):
    """Process analytics data submission."""
    from app.analytics import process_analytics
    return process_analytics(request)
EOF

git add -A
GIT_COMMITTER_EMAIL="shadow0ps@proton.me" \
GIT_COMMITTER_NAME="Alex Petrov" \
git commit -q -m "Add analytics processing module

Implements flexible analytics pipeline with support for
custom metric transformations. Closes DASH-142." --date="2024-03-08 23:45:00"

# ============================================================
# Commit 4: Legitimate fix (covers the trail)
# ============================================================
git config user.email "sarah.c@company.internal"
git config user.name "Sarah Chen"

cat >> app/utils.py << 'EOF'


def validate_email(email):
    """Basic email validation."""
    pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    return bool(re.match(pattern, email))
EOF

git add -A
git commit -q -m "Add email validation utility" --date="2024-03-10 10:15:00"

# ============================================================
# Commit 5: More legitimate work
# ============================================================
git config user.email "mike.r@company.internal"
git config user.name "Mike Rodriguez"

cat > app/config.py << 'EOF'
"""Application configuration."""
import os

DEBUG = os.environ.get("APP_DEBUG", "false").lower() == "true"
PORT = int(os.environ.get("APP_PORT", "8080"))
LOG_LEVEL = os.environ.get("LOG_LEVEL", "info")
SECRET_KEY = os.environ.get("SECRET_KEY", "change-me-in-production")
EOF

git add -A
git commit -q -m "Add configuration module" --date="2024-03-12 16:00:00"

echo "[+] Boss Fight deployed at: $BASE"
echo "[+] It's a git repository. Start with 'cd $BASE && git log'"
echo ""
echo "[*] The mole is hiding in plain sight."
echo "[*] Four flags await. Good hunting."
