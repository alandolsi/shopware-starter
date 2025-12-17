# Shopware 6 Starter Project (Coolify & DDEV)

This project is a pre-configured Shopware 6 environment optimized for local development with **DDEV** and production deployment via **Coolify**.

## 🚀 Quick Start (Local)

1.  **Start DDEV:**
    ```bash
    ddev start
    ```
2.  **Install Dependencies:**
    ```bash
    ddev composer install
    ```
3.  **Access Shopware:**
    *   **Storefront:** [https://shopware.landolsi.local](https://shopware.landolsi.local)
    *   **Admin:** [https://shopware.landolsi.local/admin](https://shopware.landolsi.local/admin) (User: `admin`, Pass: `shopware`)

## 🛠 Commands

*   `ddev exec bin/console`: Access Shopware CLI.
*   `ddev pull coolify`: Import Database and Media from production (Requires SSH setup).
*   `ddev composer require shopware/dev-tools --dev`: (Installed) For demo data generation.

## 📦 Production (Coolify)

The project uses a custom `Dockerfile` that combines PHP 8.3-FPM and Nginx using Supervisor.

### Deployment Flow
1.  **Development:** Work on `main` or branches.
2.  **Release:** Push a tag (e.g., `v1.0.0`).
3.  **CI/CD:** GitHub Actions builds the image and pushes it to **GHCR**.
4.  **Coolify:** Deployment happens via the Docker image `ghcr.io/YOUR_GITHUB_USER/shopware-starter:v1.0.0`.

### Database Sync
To import the production database to your local machine:
1. Edit `.ddev/providers/coolify.yaml` with your server credentials.
2. Run:
   ```bash
   ddev pull coolify
   ```

## 📂 Project Structure
- `.ddev/`: Local environment config.
- `.github/workflows/`: CI/CD pipelines (Build & Release).
- `Dockerfile`: Production image definition.
- `supervisord.conf`: Process management for the container.
- `custom/plugins/`: Your custom plugins.
- `custom/static-plugins/`: Static plugins included via composer.
