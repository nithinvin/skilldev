"""
=============================================================================
Level 3.4 — Authentication & Authorization
=============================================================================

QUESTIONS (answer before reading):

  1. Authentication vs Authorization?
     - Authentication (AuthN): WHO are you? (login, prove identity)
     - Authorization (AuthZ): WHAT can you do? (permissions, roles)
     - You must authenticate BEFORE authorizing.

  2. What is a JWT?
     - JSON Web Token — a signed JSON payload
     - Structure: header.payload.signature (Base64-encoded, dot-separated)
     - The payload is NOT encrypted — anyone can read it!
     - The signature proves it wasn't tampered with.
     - Server signs with SECRET_KEY → only server can create valid tokens.

  3. Why hash passwords? Why not encrypt?
     - Encryption is REVERSIBLE (if key leaks, all passwords exposed)
     - Hashing is ONE-WAY (even if DB leaks, passwords are unrecoverable)
     - bcrypt: slow on purpose (brute-force takes centuries, not seconds)
     - SHA-256: fast (bad for passwords — can try billions per second)

  4. Why bcrypt has a "salt"?
     - Without salt: same password → same hash → rainbow table attack
     - With salt: same password + unique salt → different hash each time
     - bcrypt auto-generates and embeds the salt in the hash string

  5. 401 vs 403?
     - 401 Unauthorized: "I don't know who you are" (no token / bad token)
     - 403 Forbidden: "I know who you are, but you can't do this" (wrong role)

=============================================================================
"""

import bcrypt
import jwt
import datetime
import os
from functools import wraps
from flask import request, jsonify

SECRET_KEY = os.environ.get("SECRET_KEY", "dev-secret-change-in-production")
# Q: Why environment variable?
# Hardcoded secrets end up in git → anyone with repo access has your key.
# Environment variables: set per-machine, never committed.

TOKEN_EXPIRY_HOURS = 24


# =============================================================================
# PASSWORD HASHING
# =============================================================================

def hash_password(password: str) -> str:
    """
    Hash a password with bcrypt.
    
    Q: Why encode() to bytes?
       bcrypt operates on bytes, not strings.
       The result is decoded back to string for storage in DB.
    
    Q: What is gensalt()?
       Generates a random salt. The "12" default = 2^12 iterations.
       More rounds = slower = more secure (but also slower login).
    """
    return bcrypt.hashpw(password.encode("utf-8"), bcrypt.gensalt()).decode("utf-8")


def verify_password(password: str, password_hash: str) -> bool:
    """
    Verify a password against its bcrypt hash.
    
    Q: How does bcrypt know the salt?
       The salt is embedded in the hash string itself!
       $2b$12$SALT_HERE...HASH_HERE
       bcrypt extracts it automatically during verification.
    """
    return bcrypt.checkpw(password.encode("utf-8"), password_hash.encode("utf-8"))


# =============================================================================
# JWT TOKEN MANAGEMENT
# =============================================================================

def create_token(user_id: int, username: str, role: str) -> str:
    """
    Create a signed JWT token.
    
    Q: What's in the payload?
       user_id: identify the user
       role: for authorization checks
       exp: expiration time (token auto-invalidates)
       iat: issued-at (for auditing)
    
    Q: Is the payload secret?
       NO! JWT payload is Base64-encoded, NOT encrypted.
       Anyone can decode it. The SIGNATURE just proves it's authentic.
       Never put sensitive data (passwords, credit cards) in a JWT.
    """
    payload = {
        "user_id": user_id,
        "username": username,
        "role": role,
        "exp": datetime.datetime.utcnow() + datetime.timedelta(hours=TOKEN_EXPIRY_HOURS),
        "iat": datetime.datetime.utcnow(),
    }
    return jwt.encode(payload, SECRET_KEY, algorithm="HS256")


def decode_token(token: str) -> dict:
    """
    Decode and verify a JWT token.
    
    Q: What can go wrong?
       - ExpiredSignatureError: token past its exp time
       - InvalidTokenError: signature doesn't match (tampered or wrong key)
       Both mean: reject the request.
    """
    return jwt.decode(token, SECRET_KEY, algorithms=["HS256"])


# =============================================================================
# DECORATORS (middleware)
# =============================================================================

def require_auth(f):
    """
    Decorator: require a valid JWT to access this route.
    
    Q: What is a decorator?
       A function that wraps another function, adding behavior.
       @require_auth on a route = "run this check before the route function."
       If check fails → return error, never reach the route.
    
    Q: How does the client send the token?
       In the Authorization header: "Bearer eyJhbGc..."
       "Bearer" is a convention from OAuth2 standard.
    """
    @wraps(f)
    def decorated(*args, **kwargs):
        auth_header = request.headers.get("Authorization", "")

        if not auth_header.startswith("Bearer "):
            return jsonify({"error": "Missing or malformed Authorization header. Use: Bearer <token>"}), 401

        token = auth_header[7:]  # Strip "Bearer " prefix

        try:
            payload = decode_token(token)
            # Attach user info to the request object for use in the route
            request.user = payload
        except jwt.ExpiredSignatureError:
            return jsonify({"error": "Token expired. Please login again."}), 401
        except jwt.InvalidTokenError:
            return jsonify({"error": "Invalid token. Please login again."}), 401

        return f(*args, **kwargs)
    return decorated


def require_role(role):
    """
    Decorator: require a specific role (use AFTER require_auth).
    
    Q: Why a separate decorator?
       Separation of concerns:
       - require_auth checks IDENTITY (are you logged in?)
       - require_role checks PERMISSION (are you an admin?)
       You can mix and match: some routes need auth only, some need admin.
    """
    def decorator(f):
        @wraps(f)
        def decorated(*args, **kwargs):
            user_role = getattr(request, "user", {}).get("role", "")
            if user_role != role:
                return jsonify({"error": f"Requires '{role}' role. You have '{user_role}'."}), 403
            return f(*args, **kwargs)
        return decorated
    return decorator


# =============================================================================
# USER MANAGEMENT (in-memory for now, DB in production)
# =============================================================================

_users = [
    {
        "id": 1,
        "username": "admin",
        "email": "admin@mybookshelf.dev",
        "password_hash": hash_password("admin123"),
        "role": "admin",
    }
]
_next_user_id = 2


def register_user(username: str, email: str, password: str) -> dict:
    """Register a new user. Returns user info + token, or error."""
    global _next_user_id

    # Check for duplicates
    if any(u["username"] == username for u in _users):
        return {"error": "Username already exists"}
    if any(u["email"] == email for u in _users):
        return {"error": "Email already exists"}

    user = {
        "id": _next_user_id,
        "username": username,
        "email": email,
        "password_hash": hash_password(password),
        "role": "reader",  # New users are readers by default
    }
    _next_user_id += 1
    _users.append(user)

    token = create_token(user["id"], user["username"], user["role"])
    return {
        "token": token,
        "user": {"id": user["id"], "username": user["username"], "role": user["role"]},
    }


def login_user(username: str, password: str) -> dict:
    """Authenticate a user. Returns token or error."""
    user = next((u for u in _users if u["username"] == username), None)

    if not user or not verify_password(password, user["password_hash"]):
        # Q: Why same error for "user not found" AND "wrong password"?
        # If you say "user not found" → attacker knows which usernames exist.
        # Generic error reveals nothing. This is security through obscurity (partially).
        return {"error": "Invalid username or password"}

    token = create_token(user["id"], user["username"], user["role"])
    return {
        "token": token,
        "user": {"id": user["id"], "username": user["username"], "role": user["role"]},
    }


# =============================================================================
# STANDALONE TEST
# =============================================================================

if __name__ == "__main__":
    print("=== Auth Module Test ===\n")

    # Test password hashing
    pw = "mySecurePassword123"
    hashed = hash_password(pw)
    print(f"Password: {pw}")
    print(f"Hash:     {hashed}")
    print(f"Verify correct:  {verify_password(pw, hashed)}")
    print(f"Verify wrong:    {verify_password('wrong', hashed)}")
    print()

    # Test JWT
    token = create_token(1, "nithin", "reader")
    print(f"Token: {token[:50]}...")
    decoded = decode_token(token)
    print(f"Decoded: {decoded}")
    print()

    # Test registration
    result = register_user("nithin", "nithin@example.com", "secure123")
    print(f"Register: {result}")
    print()

    # Test login
    result = login_user("nithin", "secure123")
    print(f"Login: {result}")
    print()

    # Test wrong password
    result = login_user("nithin", "wrongpassword")
    print(f"Bad login: {result}")
