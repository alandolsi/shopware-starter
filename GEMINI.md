# Shopware 6 Starter Project

## Overview
This project is a Shopware 6 environment designed for local development with DDEV and production deployment via Coolify.

### Core Technologies
- **Framework:** Shopware 6.7
- **Local Dev:** DDEV (PHP 8.3, Nginx, MariaDB)
- **Production:** Docker (PHP 8.3 FPM + Nginx via Supervisor)
- **CI/CD:** GitHub Actions + GHCR (GitHub Container Registry)

## Local Development (DDEV)
The local environment is accessible at: `https://shopware.landolsi.local`

**Commands:**
- `ddev start`: Start the environment.
- `ddev stop`: Stop the environment.
- `ddev composer install`: Install dependencies.
- `ddev exec bin/console`: Access Shopware CLI.

**Admin Credentials:**
- **URL:** `https://shopware.landolsi.local/admin`
- **User:** `admin`
- **Password:** `shopware`

## Production (Coolify)
For production, a custom `Dockerfile` is used that combines PHP-FPM and Nginx into a single container managed by Supervisor.

### Deployment Process
1.  **Push Code:** Push changes to `main` or `develop` to trigger CI checks.
2.  **Create Release:** Push a tag (e.g., `v1.0.0`) to trigger the Docker Build & Push to GHCR.
3.  **Coolify Sync:** Coolify pulls the image from GHCR or builds from the repository using the provided `Dockerfile`.

## Important Files
- `.ddev/config.yaml`: DDEV local configuration.
- `Dockerfile`: Production image definition.
- `docker-nginx.conf`: Nginx configuration for production.
- `supervisord.conf`: Process management for production.
- `.github/workflows/`: CI/CD pipelines.
