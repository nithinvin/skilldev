# Layer 5: Cloud Deployment & Microservices

> **Goal**: Deploy MyBookShelf to your Hetzner VM, then split the monolith into services.
> **Pre-req**: Layer 4 complete — Dockerized app with CI/CD, tests, monitoring.
> **Why?** Deploying locally is practice. Real software runs on remote servers. Microservices let teams scale independently, but add complexity you need to understand.

---

## Level 5.1 — Deploy to Hetzner VM

### Questions to Answer First
1. What is SSH? How does public-key authentication work?
2. What is a reverse proxy? Why put nginx in front of your app?
3. What is a domain name? How does DNS map it to your server's IP?
4. What is TLS/HTTPS? Why is it non-negotiable for production?
5. What is Let's Encrypt? How does ACME challenge work?

### Hands-On: Deploy with Docker on Hetzner
```bash
# 1. SSH into your Hetzner VM
ssh user@<your-hetzner-ip>

# 2. Install Docker (if not done)
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker $USER

# 3. Clone your repo
git clone https://github.com/your-username/mybookshelf.git
cd mybookshelf

# 4. Create production .env file
cat > .env << 'EOF'
DATABASE_URL=postgresql://bookshelf_user:STRONG_PASSWORD_HERE@db:5432/mybookshelf
REDIS_URL=redis://redis:6379
SECRET_KEY=generate-a-real-secret-with-python-c-import-secrets;print(secrets.token_hex(32))
POSTGRES_USER=bookshelf_user
POSTGRES_PASSWORD=STRONG_PASSWORD_HERE
POSTGRES_DB=mybookshelf
EOF

# 5. Start with docker compose
docker compose -f docker-compose.prod.yml up -d

# 6. Check it's running
curl http://localhost:5000/health
```

### Production docker-compose
```yaml
# file: mybookshelf/docker-compose.prod.yml
version: '3.8'

services:
  app:
    build: .
    env_file: .env
    depends_on:
      db:
        condition: service_healthy
      redis:
        condition: service_started
    restart: always
    # Don't expose port directly — nginx handles it

  db:
    image: postgres:16-alpine
    env_file: .env
    volumes:
      - pgdata:/var/lib/postgresql/data
      - ./schema.sql:/docker-entrypoint-initdb.d/01-schema.sql
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U bookshelf_user"]
      interval: 10s
      timeout: 5s
      retries: 5
    restart: always

  redis:
    image: redis:7-alpine
    volumes:
      - redisdata:/data
    restart: always

  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.prod.conf:/etc/nginx/conf.d/default.conf
      - certbot-data:/etc/letsencrypt
      - certbot-www:/var/www/certbot
    depends_on:
      - app
    restart: always

  certbot:
    image: certbot/certbot
    volumes:
      - certbot-data:/etc/letsencrypt
      - certbot-www:/var/www/certbot
    entrypoint: "/bin/sh -c 'trap exit TERM; while :; do sleep 12h & wait $${!}; certbot renew; done'"

volumes:
  pgdata:
  redisdata:
  certbot-data:
  certbot-www:
```

### Add TLS with Let's Encrypt
```nginx
# file: mybookshelf/nginx.prod.conf
server {
    listen 80;
    server_name yourdomain.com;

    location /.well-known/acme-challenge/ {
        root /var/www/certbot;
    }

    location / {
        return 301 https://$host$request_uri;
    }
}

server {
    listen 443 ssl;
    server_name yourdomain.com;

    ssl_certificate /etc/letsencrypt/live/yourdomain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/yourdomain.com/privkey.pem;

    location / {
        proxy_pass http://app:5000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

```bash
# Get initial certificate
docker compose -f docker-compose.prod.yml run --rm certbot \
  certbot certonly --webroot --webroot-path /var/www/certbot \
  -d yourdomain.com --email your@email.com --agree-tos --no-eff-email
```

---

## Level 5.2 — Deployment Strategies

### Questions to Answer First
1. What is zero-downtime deployment? Why does it matter?
2. What is a blue-green deployment?
3. What is a rolling update?
4. What is a rollback? When do you need one?

### Theory (Concise)
```
Blue-Green:
  [Blue: v1 running] ← traffic
  [Green: v2 starting]
  Switch:
  [Blue: v1 idle]
  [Green: v2 running] ← traffic

Rolling:
  [Instance 1: v1] [Instance 2: v1] [Instance 3: v1]
  [Instance 1: v2] [Instance 2: v1] [Instance 3: v1]  ← one at a time
  [Instance 1: v2] [Instance 2: v2] [Instance 3: v1]
  [Instance 1: v2] [Instance 2: v2] [Instance 3: v2]
```

### Hands-On: Simple Deploy Script
```bash
#!/bin/bash
# file: mybookshelf/deploy.sh
set -euo pipefail

REMOTE="user@your-hetzner-ip"
APP_DIR="/home/user/mybookshelf"

echo "=== Deploying MyBookShelf ==="

# Pull latest code
ssh $REMOTE "cd $APP_DIR && git pull origin main"

# Build new image
ssh $REMOTE "cd $APP_DIR && docker compose -f docker-compose.prod.yml build"

# Rolling restart (app only, DB stays up)
ssh $REMOTE "cd $APP_DIR && docker compose -f docker-compose.prod.yml up -d --no-deps app"

# Health check
sleep 5
HEALTH=$(ssh $REMOTE "curl -s http://localhost:5000/health")
echo "Health: $HEALTH"

echo "=== Deploy complete ==="
```

---

## Level 5.3 — Kubernetes Basics: Container Orchestration

### Questions to Answer First
1. What problem does Kubernetes (k8s) solve that Docker Compose doesn't?
2. What is a Pod? A Deployment? A Service?
3. What is the difference between declarative and imperative management?
4. When do you need Kubernetes? When is it overkill?
5. What is k3s? (hint: lightweight k8s for learning and small deployments)

### Theory (Concise)
```
Docker Compose: single machine, single command
Kubernetes: multiple machines, auto-healing, auto-scaling, service discovery

Key concepts:
  Pod         = smallest unit (1+ containers sharing network)
  Deployment  = manages Pods (replicas, rolling updates)
  Service     = stable network endpoint to reach Pods
  Ingress     = HTTP routing from outside the cluster
  ConfigMap   = configuration data
  Secret      = sensitive data (passwords, keys)
```

### Hands-On: k3s on Hetzner
```bash
# Install k3s (lightweight Kubernetes)
curl -sfL https://get.k3s.io | sh -

# Check it's running
sudo k3s kubectl get nodes
```

### Kubernetes Manifests for MyBookShelf
```yaml
# file: mybookshelf/k8s/deployment.yml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mybookshelf
spec:
  replicas: 2    # Q: Why 2 replicas?
  selector:
    matchLabels:
      app: mybookshelf
  template:
    metadata:
      labels:
        app: mybookshelf
    spec:
      containers:
        - name: app
          image: mybookshelf:latest
          ports:
            - containerPort: 5000
          env:
            - name: DATABASE_URL
              valueFrom:
                secretKeyRef:
                  name: mybookshelf-secrets
                  key: database-url
          readinessProbe:
            httpGet:
              path: /health
              port: 5000
            initialDelaySeconds: 5
            periodSeconds: 10
          resources:
            requests:
              memory: "128Mi"
              cpu: "100m"
            limits:
              memory: "256Mi"
              cpu: "500m"
---
apiVersion: v1
kind: Service
metadata:
  name: mybookshelf
spec:
  selector:
    app: mybookshelf
  ports:
    - port: 80
      targetPort: 5000
  type: ClusterIP
```

```bash
# Apply
sudo k3s kubectl apply -f k8s/

# Check status
sudo k3s kubectl get pods
sudo k3s kubectl get services
sudo k3s kubectl logs -f deployment/mybookshelf

# Scale up
sudo k3s kubectl scale deployment mybookshelf --replicas=3
```

---

## Level 5.4 — Microservices: Splitting the Monolith

### Questions to Answer First
1. What is a monolith? What is a microservice?
2. When should you split? What are the trade-offs?
3. How do microservices communicate? (HTTP, message queues, gRPC)
4. What is the "distributed monolith" anti-pattern?
5. What is eventual consistency? Why is it necessary in distributed systems?

### Theory (Concise)
```
Monolith:
  ┌─────────────────────────────┐
  │  Books API + Auth + Search  │
  │  + Recommendations + Admin  │
  │       One codebase          │
  │       One database          │
  └─────────────────────────────┘

Microservices:
  ┌──────────┐  ┌──────────┐  ┌──────────┐
  │ Book Svc │  │ Auth Svc │  │Search Svc│
  │ (Python) │  │ (Python) │  │ (Python) │
  │ PostgreSQL│  │ PostgreSQL│  │  Redis   │
  └──────────┘  └──────────┘  └──────────┘
       ↕              ↕              ↕
  ─────────── Message Queue (Redis/RabbitMQ) ───────────

When to split:
  ✅ Different scaling needs (search gets 100x traffic)
  ✅ Different teams own different services
  ✅ Independent deployment needed
  ❌ Don't split because "microservices are cool"
  ❌ Don't split if you have one team and one deploy target
```

### Hands-On: Split MyBookShelf
```
mybookshelf/
├── services/
│   ├── book-service/        # CRUD for books
│   │   ├── Dockerfile
│   │   ├── api.py
│   │   └── requirements.txt
│   ├── auth-service/        # User auth, JWT
│   │   ├── Dockerfile
│   │   ├── api.py
│   │   └── requirements.txt
│   └── search-service/      # Full-text search via Redis
│       ├── Dockerfile
│       ├── api.py
│       └── requirements.txt
├── gateway/                 # API gateway (nginx or custom)
│   └── nginx.conf
└── docker-compose.microservices.yml
```

```yaml
# file: mybookshelf/docker-compose.microservices.yml
version: '3.8'

services:
  gateway:
    image: nginx:alpine
    ports:
      - "80:80"
    volumes:
      - ./gateway/nginx.conf:/etc/nginx/conf.d/default.conf
    depends_on:
      - book-service
      - auth-service

  book-service:
    build: ./services/book-service
    environment:
      DATABASE_URL: "postgresql://bookshelf_user:bookshelf_pass@db:5432/mybookshelf"

  auth-service:
    build: ./services/auth-service
    environment:
      DATABASE_URL: "postgresql://bookshelf_user:bookshelf_pass@db:5432/mybookshelf"
      SECRET_KEY: "change-me"

  search-service:
    build: ./services/search-service
    environment:
      REDIS_URL: "redis://redis:6379"

  db:
    image: postgres:16-alpine
    environment:
      POSTGRES_USER: bookshelf_user
      POSTGRES_PASSWORD: bookshelf_pass
      POSTGRES_DB: mybookshelf
    volumes:
      - pgdata:/var/lib/postgresql/data

  redis:
    image: redis:7-alpine

volumes:
  pgdata:
```

```nginx
# file: mybookshelf/gateway/nginx.conf
# API Gateway — routes requests to the right service
upstream book_service {
    server book-service:5000;
}
upstream auth_service {
    server auth-service:5000;
}
upstream search_service {
    server search-service:5000;
}

server {
    listen 80;

    location /api/books {
        proxy_pass http://book_service;
    }
    location /api/auth {
        proxy_pass http://auth_service;
    }
    location /api/search {
        proxy_pass http://search_service;
    }
}
```

---

## Level 5.5 — Service Communication: Sync vs Async

### Questions to Answer First
1. What happens if Service A calls Service B, and B is down?
2. What is a message queue? How is it different from a direct HTTP call?
3. What is the difference between synchronous and asynchronous communication?
4. What is a circuit breaker pattern?

### Hands-On: Redis as a Message Queue
```python
# In book-service: publish event when book is created
import redis
import json

r = redis.Redis(host='redis', port=6379)

def publish_book_created(book):
    r.publish('book_events', json.dumps({
        'event': 'book_created',
        'data': book
    }))

# In search-service: subscribe to book events
def listen_for_books():
    pubsub = r.pubsub()
    pubsub.subscribe('book_events')
    for message in pubsub.listen():
        if message['type'] == 'message':
            event = json.loads(message['data'])
            if event['event'] == 'book_created':
                # Index in Redis for full-text search
                index_book(event['data'])
```

---

## Checkpoint Questions (Answer Before Moving to Layer 6)

1. Draw the architecture: browser → nginx → app → DB/Redis. Label each connection.
2. What is TLS? Why is HTTPS important? What does Let's Encrypt do?
3. Explain the difference between Docker Compose and Kubernetes in 3 sentences.
4. When should you use microservices? Give 2 reasons to split and 2 reasons not to.
5. What is a health check? What should it verify?
6. What happens if a microservice is down? How do you handle it gracefully?
7. SSH into your Hetzner VM and deploy MyBookShelf — verify it works from your laptop browser.

---

**Previous**: [Layer 4 — Containers & DevOps](layer4-containers-devops.md)
**Next**: [Layer 6 — Cryptography & Security](layer6-security-crypto.md)
