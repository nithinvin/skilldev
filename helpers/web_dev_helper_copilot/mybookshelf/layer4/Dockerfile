# =============================================================================
# Level 4.2 — Dockerfile: Package MyBookShelf
# =============================================================================
#
# QUESTIONS (answer before reading):
#   1. What is a Docker image? What is a container?
#      Image = a blueprint (like a class). Read-only. Built from Dockerfile.
#      Container = a running instance (like an object). Read-write layer on top.
#
#   2. What does FROM python:3.11-slim mean?
#      Start from an official Python image (Debian-based, minimal).
#      "slim" = no gcc, no dev headers (~150MB vs ~900MB for full image).
#      If you need to compile C extensions: use python:3.11 (full).
#
#   3. Why copy requirements.txt BEFORE the rest of the code?
#      Docker caches layers. If only your code changes (not requirements),
#      Docker reuses the cached pip install layer → much faster rebuilds.
#
#   4. What does EXPOSE do?
#      Documentation only! It does NOT actually publish the port.
#      You still need -p 5000:5000 in docker run.
#      It tells humans "this container listens on 5000."
#
#   5. CMD vs ENTRYPOINT?
#      CMD = default command (can be overridden: docker run ... /bin/bash)
#      ENTRYPOINT = fixed command (args are appended, not replaced)
#      Use CMD for flexibility. Use ENTRYPOINT for fixed executables.
#
# BUILD: docker build -t mybookshelf:latest .
# RUN:   docker run -p 5000:5000 mybookshelf:latest
# =============================================================================

FROM python:3.11-slim

# Set metadata labels (optional but good practice)
LABEL maintainer="Nithin <nithin@mybookshelf.dev>"
LABEL description="MyBookShelf API — Layer 3"

# Prevent Python from buffering stdout/stderr (see logs in real-time)
ENV PYTHONUNBUFFERED=1
# Q: Without this, print() output may not appear in docker logs!

# Create non-root user (security: don't run as root in containers)
RUN useradd --create-home appuser
# Q: Why not root? If an attacker compromises the app, they have LIMITED permissions.
# With root: they own the entire container (and potentially escape to host).

WORKDIR /app

# Copy requirements first (layer caching optimization)
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
# Q: --no-cache-dir saves ~50MB by not storing pip's download cache in the image.

# Copy application code
COPY . .

# Switch to non-root user
USER appuser

# Document the port (doesn't actually expose it)
EXPOSE 5000

# Health check: Docker can restart unhealthy containers
HEALTHCHECK --interval=30s --timeout=10s --retries=3 \
    CMD python3 -c "import urllib.request; urllib.request.urlopen('http://localhost:5000/health')" || exit 1

# Default command: run with gunicorn (production WSGI server)
# Q: Why gunicorn and not "python3 api.py"?
#    Flask's dev server is single-threaded and not secure.
#    Gunicorn = production server: multi-worker, handles crashes gracefully.
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "--workers", "4", "api:app"]
