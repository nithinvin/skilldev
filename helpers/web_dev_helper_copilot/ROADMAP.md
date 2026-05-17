# Full-Stack Engineering Learning Roadmap

> **Student**: Nithin | **Background**: B.Tech CSE Year 1 (VIT Chennai)
> **Known**: C, C++, Python, DSA, OOPS, Digital Design, Computer Architecture
> **Style**: INTP — bottom-up learner, wants to know *why* before *how*
> **Environment**: Ubuntu (WSL local) + Ubuntu VM (Hetzner)

---

## Philosophy

Each layer follows this cycle:

```
1. QUESTION  → What problem does this solve? Why can't we do without it?
2. THEORY    → Concise mental model (≤ 1 page)
3. BUILD     → Minimal working code you fully understand
4. BREAK     → Intentionally break it, observe what happens
5. EXTEND    → Add one feature, answer new questions that arise
6. REFLECT   → Write 3 sentences: what you learned, what surprised you, what's still unclear
```

---

## Layer Map

| Layer | Topic | Key Outcome |
|-------|-------|-------------|
| **0** | [Linux & Networking Foundations](plans/layer0-foundations.md) | Understand what happens when you type a URL |
| **1** | [Static Web — HTML/CSS/JS](plans/layer1-static-web.md) | Serve a hand-crafted website from your own machine |
| **2** | [Backend Server & Databases](plans/layer2-backend-db.md) | Dynamic pages, CRUD, SQL, data modeling |
| **3** | [APIs, Auth & Authorization](plans/layer3-apis-auth.md) | REST API, JWT, OAuth, role-based access |
| **4** | [Containers & DevOps](plans/layer4-containers-devops.md) | Dockerize your app, CI/CD pipeline, monitoring |
| **5** | [Cloud & Microservices](plans/layer5-cloud-microservices.md) | Deploy to cloud, split monolith, service mesh basics |
| **6** | [Cryptography & Security](plans/layer6-security-crypto.md) | TLS, hashing, OWASP Top 10, pen-testing basics |
| **7** | [ML, Deep Learning & LLMs](plans/layer7-ml-dl-llms.md) | Train a model, fine-tune an LLM, build an MCP server |
| **8** | [Data Analytics](plans/layer8-data-analytics.md) | ETL pipelines, dashboards, statistical thinking |

---

## How Layers Connect (The Big Picture)

```
┌─────────────────────────────────────────────────────────┐
│                    Layer 8: Analytics                     │
│              (Make sense of data at scale)                │
├─────────────────────────────────────────────────────────┤
│                 Layer 7: ML / DL / LLMs                  │
│            (Teach machines to learn from data)            │
├─────────────────────────────────────────────────────────┤
│              Layer 6: Security & Crypto                   │
│         (Protect everything you've built)                 │
├─────────────────────────────────────────────────────────┤
│           Layer 5: Cloud & Microservices                  │
│       (Scale out, deploy anywhere, split services)        │
├─────────────────────────────────────────────────────────┤
│            Layer 4: Containers & DevOps                   │
│       (Package, ship, automate, monitor)                  │
├─────────────────────────────────────────────────────────┤
│           Layer 3: APIs, Auth & Authorization             │
│       (Expose services, control access)                   │
├─────────────────────────────────────────────────────────┤
│           Layer 2: Backend Server & Databases             │
│       (Dynamic logic, persistent data)                    │
├─────────────────────────────────────────────────────────┤
│            Layer 1: Static Web (HTML/CSS/JS)              │
│       (What users see, browser rendering)                 │
├─────────────────────────────────────────────────────────┤
│          Layer 0: Linux & Networking Foundations           │
│       (The ground everything runs on)                     │
└─────────────────────────────────────────────────────────┘
```

---

## Running Project: "MyBookShelf"

Across all layers, we build **one evolving project** — a personal book collection manager.
- Layer 0: Understand the machine it will run on
- Layer 1: Static HTML page listing books
- Layer 2: Backend stores books in PostgreSQL, dynamic pages
- Layer 3: REST API, user login, roles (admin vs reader)
- Layer 4: Dockerize it, set up CI/CD
- Layer 5: Deploy to Hetzner, add Redis cache, split into services
- Layer 6: Harden it — TLS, input validation, security audit
- Layer 7: Add ML-powered book recommendations, LLM-based search
- Layer 8: Analytics dashboard — reading trends, popular genres

This way every layer has **context** and **purpose**, not just isolated exercises.

---

## Time Estimate

Not prescribing rigid timelines — go at your own pace. But roughly:
- Layers 0–1: ~1–2 weeks each
- Layers 2–3: ~2–3 weeks each
- Layers 4–6: ~2–3 weeks each
- Layers 7–8: ~3–4 weeks each

Total: ~5–6 months if consistent (2–3 hours/day).

---

## Quick Start

```bash
# On your Ubuntu machine (WSL or Hetzner)
mkdir -p ~/skilldev/mybookshelf
cd ~/skilldev/mybookshelf
git init
```

Now open [Layer 0](plans/layer0-foundations.md) and begin.
