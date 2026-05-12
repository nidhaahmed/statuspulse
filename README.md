# StatusPulse

Production-style monitoring and incident management platform built with FastAPI, Docker, CI/CD, observability tooling, Infrastructure as Code, automated backups, and security hardening.

---

# Architecture Diagram

```text
                         ┌─────────────────────┐
                         │    GitHub Actions   │
                         │  CI/CD Pipelines    │
                         └──────────┬──────────┘
                                    │
                                    ▼
                         ┌─────────────────────┐
                         │ GitHub Container    │
                         │ Registry (GHCR)     │
                         └──────────┬──────────┘
                                    │
                                    ▼
┌────────────────────────────────────────────────────────────────┐
│                        Docker Network                         │
│                                                                │
│   ┌──────────────┐       ┌────────────────┐                    │
│   │    Caddy     │──────▶│  FastAPI App   │                    │
│   │ Reverse Proxy│       │  StatusPulse   │                    │
│   └──────┬───────┘       └───────┬────────┘                    │
│          │                       │                             │
│          │                       │                             │
│          ▼                       ▼                             │
│   HTTPS/TLS               PostgreSQL DB                        │
│                                  │                             │
│                                  ▼                             │
│                               Redis                            │
│                                                                │
│   ┌──────────────────────────────────────────────────────┐      │
│   │                  Uptime Kuma                        │      │
│   │      Health Monitoring + Public Status Page         │      │
│   └──────────────────────────────────────────────────────┘      │
│                                                                │
│   ┌──────────────────────────────────────────────────────┐      │
│   │          Health Monitor Cron Container              │      │
│   │    Automated checks + alerts + operational logs     │      │
│   └──────────────────────────────────────────────────────┘      │
└────────────────────────────────────────────────────────────────┘
```

---

# Features

* FastAPI-based service monitoring API
* Dockerized infrastructure
* PostgreSQL + Redis integration
* HTTPS reverse proxy with Caddy
* CI/CD using GitHub Actions
* GitHub Container Registry (GHCR) deployment pipeline
* Automated rollback deployment script
* Uptime Kuma monitoring and public status page
* Discord + ntfy alert notifications
* Infrastructure as Code using Ansible
* Automated PostgreSQL backups
* Security hardening with Trivy scanning
* Health monitoring automation
* Containerized cron jobs

---

# Tech Stack

| Component         | Technology                |
| ----------------- | ------------------------- |
| Backend API       | FastAPI                   |
| WSGI Server       | Gunicorn + Uvicorn        |
| Database          | PostgreSQL                |
| Cache             | Redis                     |
| Reverse Proxy     | Caddy                     |
| Monitoring        | Uptime Kuma               |
| CI/CD             | GitHub Actions            |
| Registry          | GitHub Container Registry |
| IaC               | Ansible                   |
| Security Scanning | Trivy                     |
| Containers        | Docker + Docker Compose   |

---

# Prerequisites

Install the following:

* Docker Desktop
* Docker Compose
* Git
* Python 3.11+
* VS Code (recommended)
* GitHub account

Optional:

* WSL Ubuntu
* Trivy
* Ansible

---

# Project Structure

```text
statuspulse/
│
├── app/
├── ansible/
├── caddy/
├── cron/
├── logs/
├── scripts/
├── server-hardening/
├── security/
├── tests/
├── .github/workflows/
├── docker-compose.yml
├── Dockerfile
├── README.md
└── SECURITY.md
```

---

# Running Locally with Docker Compose

## 1. Clone Repository

```bash
git clone <repo-url>
cd statuspulse
```

---

## 2. Create Environment File

```bash
cp .env.example .env
```

Update values if required.

---

## 3. Start Infrastructure

```bash
docker compose up -d
```

---

## 4. Verify Services

```bash
curl http://localhost:8000/health
```

Expected:

```json
{
  "status": "healthy"
}
```

---

# Service URLs

| Service         | URL                                                  |
| --------------- | ---------------------------------------------------- |
| API             | [https://localhost](https://localhost)               |
| Swagger Docs    | [https://localhost/docs](https://localhost/docs)     |
| Health Endpoint | [https://localhost/health](https://localhost/health) |
| Uptime Kuma     | [http://localhost:3001](http://localhost:3001)       |

---

# API Endpoints

| Endpoint   | Method | Description     |
| ---------- | ------ | --------------- |
| /health    | GET    | Health status   |
| /services  | POST   | Create service  |
| /services  | GET    | List services   |
| /incidents | POST   | Create incident |
| /incidents | GET    | List incidents  |

---

# CI/CD Pipeline

CI/CD is implemented using GitHub Actions.

## CI Workflow

File:

```text
.github/workflows/ci.yml
```

Pipeline steps:

1. Lint Python code using Ruff
2. Scan Dockerfile using Hadolint
3. Build Docker image
4. Start complete stack with Docker Compose
5. Run integration tests
6. Upload logs/artifacts
7. Tear down containers

---

## Deploy Workflow

File:

```text
.github/workflows/deploy.yml
```

Pipeline steps:

1. Build Docker image
2. Tag image with:

   * latest
   * commit SHA
3. Push image to GHCR
4. Run deployment script
5. Perform health verification
6. Trigger rollback on failure
7. Send deployment notifications

---

# GitHub Container Registry

Images are published to:

```text
ghcr.io/nidhaahmed/statuspulse
```

Tags:

* latest
* commit SHA tags

---

# Deployment

## Deployment Script

File:

```text
scripts/deploy.sh
```

Features:

* Pull latest image from GHCR
* Restart stack
* Health verification
* Automatic rollback
* Timestamped logging
* Idempotent execution

---

## Run Deployment

```bash
bash scripts/deploy.sh
```

---

# Monitoring & Alerting

## Uptime Kuma

Monitors configured:

* FastAPI health endpoint
* PostgreSQL TCP check
* Redis TCP check
* TLS monitoring

Public status page enabled.

---

## Notification Channels

Configured alerts:

* Discord
* ntfy.sh

Alerts triggered for:

* Service downtime
* Recovery events
* Disk usage warnings
* Container failures

---

# Health Monitoring Automation

File:

```text
scripts/health-monitor.sh
```

Checks:

* Health endpoint status
* Disk usage
* Memory usage
* Running containers
* TLS certificate validity
* Webhook alerting

Logs written to:

```text
logs/cron.log
```

---

# Automated Cron Monitoring

Containerized cron execution configured using:

```text
cron/health-monitor-cron
```

Runs every 5 minutes.

---

# Backup & Restore

## Backup Script

File:

```text
scripts/backup.sh
```

Features:

* PostgreSQL dump generation
* Gzip compression
* Backup rotation
* Timestamped logs
* Retains latest 7 backups

---

## Run Backup

```bash
bash scripts/backup.sh
```

Generated backups:

```text
backups/statuspulse_db_YYYY-MM-DD_HHMMSS.sql.gz
```

---

## Restore Backup

```bash
gunzip -c backups/<backup-file>.sql.gz | docker exec -i statuspulse-postgres psql -U statuspulse statuspulse
```

---

# Infrastructure as Code

Ansible automation is included.

Directory:

```text
ansible/
```

Features:

* Docker Compose deployment
* Infrastructure verification
* Idempotent execution
* Automated setup workflow

---

## Run Ansible Playbook

```bash
cd ansible
ansible-playbook -i inventory.ini playbook.yml
```

---

# Security Hardening

Implemented:

* Non-root containers
* Multi-stage Docker builds
* Trivy vulnerability scanning
* HTTPS via Caddy
* Security headers
* Environment-based secret management
* GitHub Secrets integration
* Health checks

---

# Security Headers

Configured headers:

* X-Content-Type-Options
* X-Frame-Options
* Strict-Transport-Security
* X-XSS-Protection

---

# Reverse Proxy

Caddy reverse proxy configuration:

```text
caddy/Caddyfile
```

Features:

* HTTPS
* Reverse proxying
* Security headers
* Gzip compression

---

# Integration Testing

Integration tests located in:

```text
tests/test_integration.sh
```

Tests:

* Health endpoint
* Service creation
* Duplicate handling
* Incident creation
* JSON response validation

---

# Troubleshooting

## Docker Compose Issues

Restart stack:

```bash
docker compose down
docker compose up -d
```

---

## Caddy Restart Loop

Check logs:

```bash
docker logs statuspulse-caddy
```

---

## Health Endpoint Failure

Verify app container:

```bash
docker compose ps
```

---

## Uptime Kuma Cannot Reach HTTPS

Use internal container networking:

```text
http://app:8000/health
```

instead of localhost inside containers.

---

## Trivy Disk Space Errors

Use custom cache directory:

```bash
trivy image --cache-dir F:\trivy-cache statuspulse-secure
```

---

## WSL Docker Integration Issues

Enable Docker Desktop WSL integration:

```text
Docker Desktop → Settings → Resources → WSL Integration
```

---

# Screenshots & Proofs

The repository includes:

* Successful CI runs
* Failed CI proof
* GHCR package screenshots
* HTTPS proof
* Uptime Kuma dashboards
* Alert notifications
* Backup logs
* Security scan results
* Ansible idempotency proof

---

# Future Improvements

* Kubernetes deployment
* Prometheus + Grafana
* Real cloud deployment
* Blue/green deployments
* Horizontal scaling
* SSO authentication
* Advanced WAF/rate limiting

---

# Author

Nidha Ahmed Mohammad

Built as a production-style DevOps and Infrastructure Engineering project.
