# Layer 5: Cloud Deployment & Microservices

## What You'll Learn
- Cloud provisioning (Hetzner Cloud API)
- Production Docker Compose (resource limits, logging, TLS)
- TLS/HTTPS with Let's Encrypt (nginx + certbot)
- Microservice architecture (when & how to split a monolith)
- API Gateway pattern (aggregation, auth, rate limiting)
- Infrastructure as Code (deploy.py)

## File Structure

```
mybookshelf/layer5/
├── deploy.py               ← Cloud server provisioning script
├── docker-compose.prod.yml ← Production compose (TLS, limits, logging)
├── nginx.prod.conf         ← Production nginx (HTTPS, HSTS, CSP)
├── microservices.py        ← Microservice demo (3 Flask apps)
├── .env.example            ← Template for secrets
├── README.md               ← This file
└── checkpoint_quiz.py      ← Self-test: 15 questions
```

## Study Order

1. **Read deploy.py** — understand cloud API, SSH, cloud-init
2. **Read docker-compose.prod.yml** — compare with layer4 (what changed?)
3. **Read nginx.prod.conf** — understand TLS, HSTS, certificate flow
4. **Read microservices.py** — understand monolith → microservice split
5. **Run microservices demo**: `python3 microservices.py`
6. **Try**: `curl http://localhost:5000/api/books/1` (see aggregation)

## Key Concepts

### Dev vs Production Differences

| Aspect | Dev (Layer 4) | Prod (Layer 5) |
|--------|---------------|-----------------|
| DB port | Exposed (5432) | Internal only |
| TLS | None (HTTP) | Let's Encrypt (HTTPS) |
| Secrets | Hardcoded | .env file |
| Resources | Unlimited | Capped (512MB, 1 CPU) |
| Logs | Console | Rotated files (30MB max) |
| Restart | unless-stopped | always |
| Build | docker build | Pre-built image from CI |

### Deployment Flow

```
Developer → git push → CI/CD (Layer 4) → Docker image built
                                        → Tests pass
                                        → Image pushed to registry
                                        → Server pulls new image
                                        → docker compose up -d
                                        → Zero-downtime deploy ✓
```

## Connection to Other Layers
- **Layer 4** → We deploy the Docker setup built in Layer 4
- **Layer 6** → TLS configuration, security headers, secret management
- **Layer 8** → Monitoring & analytics for production systems
