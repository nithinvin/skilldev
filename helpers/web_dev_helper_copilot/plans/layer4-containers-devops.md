# Layer 4: Containers & DevOps

> **Goal**: Package MyBookShelf in Docker, automate testing/deployment with CI/CD, add monitoring.
> **Pre-req**: Layer 3 complete — REST API, auth, PostgreSQL, Redis all working locally.
> **Why?** "Works on my machine" isn't enough. Docker ensures identical environments everywhere. CI/CD catches bugs before they reach production. Monitoring tells you when things break.

---

## Level 4.1 — What Is Docker? Why Containers?

### Questions to Answer First
1. What problem does Docker solve? What was deployment like before containers?
2. What's the difference between a container and a VM?
3. What are Linux namespaces and cgroups? (hint: containers aren't VMs — they use the host kernel)
4. What is an image vs a container? (hint: class vs object)
5. What is a Dockerfile? What is a layer?
6. Why is Docker relevant if you already know how to `pip install` and `python3 server.py`?

### Theory (Concise)
```
VM:
  ┌──────────────┐ ┌──────────────┐
  │  App A        │ │  App B        │
  │  Bins/Libs    │ │  Bins/Libs    │
  │  Guest OS     │ │  Guest OS     │
  ├──────────────┤ ├──────────────┤
  │     Hypervisor                  │
  │     Host OS                     │
  │     Hardware                    │
  └────────────────────────────────┘

Container:
  ┌──────────────┐ ┌──────────────┐
  │  App A        │ │  App B        │
  │  Bins/Libs    │ │  Bins/Libs    │
  ├──────────────┤ ├──────────────┤
  │  Docker Engine (shared kernel)  │
  │  Host OS                        │
  │  Hardware                       │
  └─────────────────────────────────┘

Key insight: Containers = isolated processes using Linux namespaces (PID, net, mount, user)
                        + cgroups (resource limits: CPU, memory)
```

---

## Level 4.2 — Docker Basics: Build, Run, Inspect

### Hands-On: Install Docker
```bash
# On Ubuntu (WSL or Hetzner)
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker $USER
# Log out and back in, then:
docker run hello-world
```

### First Dockerfile for MyBookShelf
```dockerfile
# file: mybookshelf/Dockerfile
FROM python:3.11-slim

# Q: Why slim? What's the difference from python:3.11?
# Q: Why not FROM ubuntu and then install Python?

WORKDIR /app

# Copy requirements first (for layer caching)
# Q: Why copy requirements.txt separately before the rest of the code?
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# Q: What does EXPOSE do? Does it actually open a port?
EXPOSE 5000

# Q: What's the difference between CMD and ENTRYPOINT?
CMD ["python3", "api.py"]
```

```
# file: mybookshelf/requirements.txt
flask==3.0.0
psycopg2-binary==2.9.9
bcrypt==4.1.2
PyJWT==2.8.0
redis==5.0.1
gunicorn==21.2.0
```

### Build and Run
```bash
cd ~/skilldev/mybookshelf

# Build the image
docker build -t mybookshelf:v1 .

# Q: What do these flags mean?
docker run -d \
  --name mybookshelf-app \
  -p 5000:5000 \
  -e DATABASE_URL="postgresql://bookshelf_user:bookshelf_pass@host.docker.internal/mybookshelf" \
  mybookshelf:v1

# Check it's running
docker ps
docker logs mybookshelf-app

# Get inside the container
docker exec -it mybookshelf-app /bin/bash
# Look around: ls, ps aux, cat /etc/os-release

# Stop and remove
docker stop mybookshelf-app
docker rm mybookshelf-app
```

### Break It & Observe
- Build without `.dockerignore` — what gets copied? (venv, .git, __pycache__)
- Run without `-p 5000:5000` — can you access the app? Why not?
- Run two containers on the same port — what error?
- Delete the image while a container is running — what happens?

### Create .dockerignore
```
# file: mybookshelf/.dockerignore
venv/
__pycache__/
*.pyc
.git/
.env
*.md
```

---

## Level 4.3 — Docker Compose: Multi-Container Setup

### Questions to Answer First
1. Why do you need separate containers for app, database, and Redis?
2. What is Docker Compose? What problem does it solve?
3. How do containers on the same Docker network communicate?
4. What is a Docker volume? Why use one for PostgreSQL data?

### Hands-On: docker-compose.yml
```yaml
# file: mybookshelf/docker-compose.yml
version: '3.8'

services:
  app:
    build: .
    ports:
      - "5000:5000"
    environment:
      DATABASE_URL: "postgresql://bookshelf_user:bookshelf_pass@db:5432/mybookshelf"
      REDIS_URL: "redis://redis:6379"
      SECRET_KEY: "change-in-production"
    depends_on:
      db:
        condition: service_healthy
      redis:
        condition: service_started
    restart: unless-stopped

  db:
    image: postgres:16-alpine
    environment:
      POSTGRES_USER: bookshelf_user
      POSTGRES_PASSWORD: bookshelf_pass
      POSTGRES_DB: mybookshelf
    volumes:
      - pgdata:/var/lib/postgresql/data    # Q: What happens without this volume?
      - ./schema.sql:/docker-entrypoint-initdb.d/01-schema.sql  # Q: What is this?
    ports:
      - "5432:5432"
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U bookshelf_user"]
      interval: 5s
      timeout: 5s
      retries: 5

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
    volumes:
      - redisdata:/data

volumes:
  pgdata:      # Named volume for PostgreSQL persistence
  redisdata:   # Named volume for Redis persistence
```

### Run the Full Stack
```bash
# Start everything
docker compose up -d

# Watch logs
docker compose logs -f

# Check health
docker compose ps

# Run schema migration
docker compose exec db psql -U bookshelf_user -d mybookshelf -f /docker-entrypoint-initdb.d/01-schema.sql

# Stop everything
docker compose down

# Stop AND delete volumes (data loss!)
docker compose down -v
```

### Break It
- Remove the `depends_on` — what happens when app starts before DB?
- Remove the volume — add books, `docker compose down && docker compose up` — are books gone?
- Change DB password in one place but not the other — what error?

---

## Level 4.4 — CI/CD: Automated Testing & Deployment

### Questions to Answer First
1. What is CI (Continuous Integration)? What is CD (Continuous Deployment)?
2. Why run tests automatically on every push?
3. What is a pipeline? What stages does it typically have?
4. What is GitHub Actions? How does it work?

### Theory (Concise)
```
CI/CD Pipeline:
  Push code → Lint → Test → Build Docker image → Push to registry → Deploy

Why?
  - Catch bugs before merge (automated tests)
  - Ensure code style consistency (linting)
  - Automate the boring stuff (build + deploy)
  - Every commit is deployable (or you know it's not)
```

### Hands-On: GitHub Actions
```yaml
# file: mybookshelf/.github/workflows/ci.yml
name: CI Pipeline

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest

    services:
      postgres:
        image: postgres:16
        env:
          POSTGRES_USER: test_user
          POSTGRES_PASSWORD: test_pass
          POSTGRES_DB: test_db
        ports:
          - 5432:5432
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5

    steps:
      - uses: actions/checkout@v4

      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: '3.11'

      - name: Install dependencies
        run: |
          pip install -r requirements.txt
          pip install pytest pytest-cov

      - name: Run linting
        run: |
          pip install flake8
          flake8 --max-line-length=120 *.py

      - name: Run tests
        env:
          DATABASE_URL: postgresql://test_user:test_pass@localhost/test_db
        run: |
          pytest tests/ -v --cov=. --cov-report=term-missing

  build:
    needs: test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'

    steps:
      - uses: actions/checkout@v4

      - name: Build Docker image
        run: docker build -t mybookshelf:${{ github.sha }} .

      # In a real setup, push to Docker Hub or GitHub Container Registry
```

### Write Your First Tests
```python
# file: mybookshelf/tests/test_api.py
import pytest
from api import app

@pytest.fixture
def client():
    app.config['TESTING'] = True
    with app.test_client() as client:
        yield client

def test_list_books(client):
    """GET /api/books should return 200 and a list."""
    response = client.get('/api/books')
    assert response.status_code == 200
    data = response.get_json()
    assert 'books' in data
    assert isinstance(data['books'], list)

def test_create_book_requires_auth(client):
    """POST /api/books without token should return 401."""
    response = client.post('/api/books', json={
        "title": "Test", "author": "Test", "year": 2024, "rating": 5
    })
    assert response.status_code == 401

def test_create_book_validates_input(client):
    """POST /api/books with missing fields should return 400."""
    # (You'd need a valid token here — use a test fixture for that)
    pass

def test_get_nonexistent_book(client):
    """GET /api/books/99999 should return 404."""
    response = client.get('/api/books/99999')
    assert response.status_code == 404
```

---

## Level 4.5 — Monitoring & Logging

### Questions to Answer First
1. Your app is running — how do you know it's healthy?
2. What's the difference between logging and monitoring?
3. What are metrics? What should you track for a web app?
4. What is structured logging? Why is it better than `print()`?

### Hands-On: Health Check Endpoint
```python
# Add to api.py
@app.route('/health')
def health():
    """Health check endpoint for monitoring."""
    checks = {"app": "ok"}

    # Check DB
    try:
        conn = get_db()
        cur = conn.cursor()
        cur.execute("SELECT 1")
        cur.close()
        conn.close()
        checks["database"] = "ok"
    except Exception as e:
        checks["database"] = f"error: {str(e)}"

    # Check Redis
    try:
        import redis
        r = redis.Redis(host='localhost', port=6379)
        r.ping()
        checks["redis"] = "ok"
    except Exception as e:
        checks["redis"] = f"error: {str(e)}"

    status = 200 if all(v == "ok" for v in checks.values()) else 503
    return jsonify(checks), status
```

### Structured Logging
```python
# file: mybookshelf/logger.py
import logging
import json
from datetime import datetime

class JSONFormatter(logging.Formatter):
    def format(self, record):
        log_entry = {
            "timestamp": datetime.utcnow().isoformat(),
            "level": record.levelname,
            "message": record.getMessage(),
            "module": record.module,
        }
        if record.exc_info:
            log_entry["exception"] = self.formatException(record.exc_info)
        return json.dumps(log_entry)

def setup_logging():
    logger = logging.getLogger()
    handler = logging.StreamHandler()
    handler.setFormatter(JSONFormatter())
    logger.addHandler(handler)
    logger.setLevel(logging.INFO)
    return logger
```

---

## Level 4.6 — Production Deployment Basics

### Questions to Answer First
1. Why not run Flask's dev server in production? (`app.run(debug=True)`)
2. What is Gunicorn? What is a WSGI server?
3. What is nginx reverse proxy? Why put nginx in front of Gunicorn?

### Hands-On: Production Setup
```dockerfile
# Updated CMD in Dockerfile
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "--workers", "4", "api:app"]
# Q: Why 4 workers? How do you decide the number?
```

```nginx
# nginx config (for Hetzner deployment)
# file: mybookshelf/nginx.conf
server {
    listen 80;
    server_name your-domain.com;

    location / {
        proxy_pass http://app:5000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    location /static/ {
        alias /app/static/;
        expires 30d;
    }
}
```

---

## Checkpoint Questions (Answer Before Moving to Layer 5)

1. What is a Docker layer? Why does layer ordering in a Dockerfile matter?
2. Explain the difference between `docker run` and `docker compose up`.
3. What is a Docker volume? What happens to data without one?
4. Draw a CI/CD pipeline from push to deploy. Label each stage.
5. Why use Gunicorn instead of Flask's built-in server?
6. What does a health check endpoint tell you that logs don't?
7. Container vs VM: when would you use each?

---

## Files Created in This Layer

```
mybookshelf/
├── Dockerfile
├── .dockerignore
├── docker-compose.yml
├── requirements.txt
├── nginx.conf
├── .github/workflows/ci.yml
├── tests/
│   └── test_api.py
└── logger.py
```

---

**Previous**: [Layer 3 — APIs, Auth & Authorization](layer3-apis-auth.md)
**Next**: [Layer 5 — Cloud & Microservices](layer5-cloud-microservices.md)
