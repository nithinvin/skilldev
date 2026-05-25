# Layer 4: Containers & DevOps

## What You'll Learn
- Docker: images, containers, Dockerfile, layer caching
- Docker Compose: multi-container apps (app + DB + Redis + nginx)
- Nginx: reverse proxy, rate limiting, security headers
- CI/CD: GitHub Actions, automated testing, build pipelines
- Production concerns: health checks, logging, non-root users

## File Structure

```
mybookshelf/layer4/
├── Dockerfile              ← Build the app image
├── .dockerignore           ← Files to exclude from image
├── docker-compose.yml      ← Multi-container orchestration
├── nginx.conf              ← Reverse proxy configuration
├── schema.sql              ← (symlink to layer2's schema for Docker init)
├── .github/
│   └── workflows/
│       └── ci.yml          ← GitHub Actions CI/CD pipeline
├── README.md               ← This file
└── checkpoint_quiz.py      ← Self-test: 15 questions
```

## Quick Start

```bash
# Install Docker (if not already installed)
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker $USER
# Log out and back in

# Build and run everything
cd mybookshelf/layer4
docker compose up -d

# Check status
docker compose ps
docker compose logs -f app

# Test
curl http://localhost/api/books | python3 -m json.tool
curl http://localhost/health

# Stop
docker compose down

# Stop AND delete data (⚠️ destructive!)
docker compose down -v
```

## Study Order

1. **Read Dockerfile** — understand FROM, COPY, RUN, CMD, layer caching
2. **Build the image**: `docker build -t mybookshelf:latest .`
3. **Read docker-compose.yml** — understand services, networks, volumes, depends_on
4. **Run the stack**: `docker compose up -d`
5. **Explore running containers**: `docker exec -it layer4-app-1 /bin/bash`
6. **Read nginx.conf** — understand reverse proxy, rate limiting, headers
7. **Read .github/workflows/ci.yml** — understand CI/CD pipeline stages
8. **Break it**: remove volumes, change ports, kill containers

## Key Docker Commands

```bash
# Images
docker build -t name:tag .        # Build image from Dockerfile
docker images                     # List images
docker rmi image_name             # Remove image

# Containers
docker run -d -p 5000:5000 name   # Run container (detached)
docker ps                         # List running containers
docker logs container_name        # View logs
docker exec -it container bash    # Get shell inside container
docker stop container             # Stop container
docker rm container               # Remove container

# Compose
docker compose up -d              # Start all services
docker compose down               # Stop all services
docker compose logs -f service    # Follow logs
docker compose exec service cmd   # Run command in service
docker compose ps                 # Status of services
```

## Connection to Other Layers
- **Layer 3** → The API we Dockerize is the one built in Layer 3
- **Layer 5** → We deploy this Docker Compose setup to Hetzner cloud
- **Layer 6** → Security headers in nginx, non-root containers
