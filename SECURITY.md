# Security Hardening

## Container Security

- Scanned Docker images using Trivy
- Reduced vulnerabilities using Alpine base image
- Implemented non-root container user
- Removed unnecessary packages and caches

## Secret Management

- No secrets committed to repository
- `.env` included in `.gitignore`
- GitHub Actions secrets used for:
  - Discord webhook
  - Deployment credentials
- Environment variables used for runtime configuration

## Reverse Proxy Security

Implemented:
- HTTPS via Caddy
- HSTS headers
- X-Frame-Options
- X-Content-Type-Options
- X-XSS-Protection

## Monitoring & Alerting

- Uptime Kuma monitoring
- Discord + ntfy alerting
- Health monitor automation

## Backup & Recovery

- Automated PostgreSQL backups
- Backup rotation
- Deployment rollback support