#!/usr/bin/env python3
"""
=============================================================================
Layer 4 Checkpoint Quiz — Docker, Compose, CI/CD, Nginx
=============================================================================
Score 12/15 to proceed to Layer 5 (Cloud & Microservices).
Run: python3 checkpoint_quiz.py
=============================================================================
"""

QUESTIONS = [
    {
        "q": "What is the difference between a Docker IMAGE and a CONTAINER?",
        "options": [
            "A) They are the same thing",
            "B) Image is a template (read-only), container is a running instance of an image",
            "C) Container is the file on disk, image is in memory",
            "D) Image runs on the host, container runs in the cloud",
        ],
        "answer": "B",
        "explain": "Image = blueprint (like a class). Container = running instance (like an object). "
                   "One image → many containers.",
    },
    {
        "q": "In a Dockerfile, why should you COPY requirements.txt BEFORE copying the full source code?",
        "options": [
            "A) Docker requires this order",
            "B) Layer caching: dependencies change rarely, code changes often. Separate layers = faster rebuilds",
            "C) It prevents security vulnerabilities",
            "D) It makes the image smaller",
        ],
        "answer": "B",
        "explain": "Each Dockerfile instruction = a layer. If requirements.txt hasn't changed, Docker "
                   "reuses the cached pip install layer. Only the code COPY layer rebuilds.",
    },
    {
        "q": "What does 'docker compose down -v' do differently from 'docker compose down'?",
        "options": [
            "A) -v shows verbose output",
            "B) -v also removes named volumes (DATA LOSS for databases!)",
            "C) -v removes the Docker network",
            "D) -v forces container removal",
        ],
        "answer": "B",
        "explain": "Without -v: containers stop, volumes preserved. With -v: volumes deleted = "
                   "all DB data, Redis data GONE. Use carefully!",
    },
    {
        "q": "In docker-compose.yml, what does 'depends_on: db: condition: service_healthy' do?",
        "options": [
            "A) Makes the DB start first (but doesn't wait for it to be ready)",
            "B) Ensures the DB container's healthcheck passes BEFORE starting the app",
            "C) Automatically creates the database",
            "D) Shares the DB's network with the app",
        ],
        "answer": "B",
        "explain": "Without condition: service_healthy, Docker only waits for the container to START "
                   "(not for PostgreSQL to be ready). Your app would get connection refused.",
    },
    {
        "q": "How do Docker containers communicate with each other in docker-compose?",
        "options": [
            "A) Via localhost",
            "B) Via service names as DNS hostnames (e.g., 'db:5432', 'redis:6379')",
            "C) Via shared files on disk",
            "D) They can't communicate directly",
        ],
        "answer": "B",
        "explain": "Docker Compose creates a network. Each service name becomes a DNS entry. "
                   "App connects to 'db:5432', not 'localhost:5432'.",
    },
    {
        "q": "What is a reverse proxy (nginx in front of your app)?",
        "options": [
            "A) A proxy that hides the client's identity",
            "B) A server that sits in front of your app, forwarding client requests to it",
            "C) A tool for caching DNS queries",
            "D) A firewall that blocks all traffic",
        ],
        "answer": "B",
        "explain": "Reverse proxy: client → nginx → app. Benefits: TLS termination, rate limiting, "
                   "static file serving, load balancing, security headers.",
    },
    {
        "q": "In nginx, what does 'proxy_set_header X-Real-IP $remote_addr' accomplish?",
        "options": [
            "A) Encrypts the client IP",
            "B) Passes the real client IP to the app (otherwise app sees nginx's IP)",
            "C) Blocks requests from that IP",
            "D) Logs the IP to a file",
        ],
        "answer": "B",
        "explain": "Without this header, request.remote_addr in Flask shows nginx's internal IP "
                   "(e.g., 172.18.0.3) instead of the actual client's IP.",
    },
    {
        "q": "What is CI (Continuous Integration)?",
        "options": [
            "A) Manually testing code before merging",
            "B) Automatically running tests on every push/PR to catch bugs early",
            "C) Deploying code to production continuously",
            "D) Writing code in small increments",
        ],
        "answer": "B",
        "explain": "CI = every push triggers: lint, test, build. If ANY step fails, the PR is blocked. "
                   "You catch bugs BEFORE they reach main branch.",
    },
    {
        "q": "In GitHub Actions, what does 'needs: test' mean on the build job?",
        "options": [
            "A) The build job runs in parallel with tests",
            "B) The build job only runs if the test job succeeds",
            "C) The build job provides test data",
            "D) It's a comment, no effect",
        ],
        "answer": "B",
        "explain": "Job dependencies. Failed tests → build never runs → broken code never "
                   "gets packaged into a Docker image.",
    },
    {
        "q": "Why should you run containers as a NON-ROOT user?",
        "options": [
            "A) Root containers use more memory",
            "B) If an attacker exploits the app, they get root in the container (and possibly the host)",
            "C) Docker requires non-root",
            "D) Non-root containers start faster",
        ],
        "answer": "B",
        "explain": "Principle of least privilege. Root in container + kernel exploit = root on host. "
                   "Non-root user limits blast radius of a compromise.",
    },
    {
        "q": "What does HEALTHCHECK in a Dockerfile do?",
        "options": [
            "A) Sends an alert email when the container is unhealthy",
            "B) Docker periodically runs the command; if it fails, container is marked 'unhealthy'",
            "C) Prevents the container from starting",
            "D) Monitors CPU and memory usage",
        ],
        "answer": "B",
        "explain": "HEALTHCHECK CMD curl -f http://localhost:5000/health. Docker checks every N seconds. "
                   "Unhealthy containers can be auto-restarted by orchestrators.",
    },
    {
        "q": "What is the purpose of .dockerignore?",
        "options": [
            "A) Lists files Docker should not track in version control",
            "B) Lists files/dirs excluded from the build context (not sent to Docker daemon)",
            "C) Specifies which containers to ignore",
            "D) Configures Docker logging",
        ],
        "answer": "B",
        "explain": "COPY . . would copy EVERYTHING (venv, .git, secrets). .dockerignore excludes them. "
                   "Benefits: smaller context → faster builds, no secrets in images.",
    },
    {
        "q": "In nginx, what does 'limit_req_zone $binary_remote_addr zone=api_limit:10m rate=10r/s' do?",
        "options": [
            "A) Limits total server bandwidth to 10MB/s",
            "B) Creates a rate limit zone: max 10 requests/second per IP address",
            "C) Limits file upload size to 10MB",
            "D) Blocks IPs after 10 failed login attempts",
        ],
        "answer": "B",
        "explain": "Rate limiting prevents abuse/DDoS. Each IP gets 10 req/s. Excess requests "
                   "are rejected with 503. The 10m = 10MB memory for tracking IPs.",
    },
    {
        "q": "What happens if you change source code but NOT requirements.txt, then rebuild?",
        "options": [
            "A) Docker reinstalls all pip packages",
            "B) Docker uses cached pip layer (fast), only re-copies source code",
            "C) The build fails",
            "D) Docker ignores the change",
        ],
        "answer": "B",
        "explain": "Layer caching! COPY requirements.txt + RUN pip install are cached. "
                   "Only COPY . . layer invalidates. Rebuild takes seconds, not minutes.",
    },
    {
        "q": "What is the 'restart: unless-stopped' policy in docker-compose?",
        "options": [
            "A) Never restart the container",
            "B) Restart on crash/reboot, but NOT if manually stopped with docker stop",
            "C) Always restart, even after manual stop",
            "D) Restart only on exit code 0",
        ],
        "answer": "B",
        "explain": "'always' = restarts even after docker stop (annoying in dev). "
                   "'unless-stopped' = auto-restart on crash/reboot but respects manual stops.",
    },
]


def run_quiz():
    print("\n" + "=" * 60)
    print("  LAYER 4 CHECKPOINT: Docker, Compose, CI/CD, Nginx")
    print("  Score 12/15 to proceed to Layer 5")
    print("=" * 60)

    score = 0
    for i, q in enumerate(QUESTIONS, 1):
        print(f"\nQ{i}. {q['q']}")
        for opt in q["options"]:
            print(f"    {opt}")

        while True:
            ans = input(f"\n  Your answer (A/B/C/D): ").strip().upper()
            if ans in ("A", "B", "C", "D"):
                break
            print("  Please enter A, B, C, or D.")

        if ans == q["answer"]:
            score += 1
            print(f"  ✓ Correct!")
        else:
            print(f"  ✗ Wrong. Answer: {q['answer']}")
        print(f"  → {q['explain']}")

    print("\n" + "=" * 60)
    print(f"  SCORE: {score}/15")
    if score >= 12:
        print("  ✓ PASSED! Ready for Layer 5: Cloud & Microservices")
    else:
        print("  ✗ Review the material and try again.")
        print("  Focus on: Dockerfile layer caching, compose networking, CI/CD flow")
    print("=" * 60 + "\n")


if __name__ == "__main__":
    run_quiz()
