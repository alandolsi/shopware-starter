#!/bin/bash
# Generiert sichere Passwörter für Production Deployment

echo "=== Shopware Production Secrets Generator ==="
echo ""

# APP_SECRET (64 Zeichen)
APP_SECRET=$(openssl rand -hex 32)
echo "APP_SECRET=${APP_SECRET}"

# INSTANCE_ID (32 Zeichen Hex)
INSTANCE_ID=$(openssl rand -hex 16)
echo "INSTANCE_ID=${INSTANCE_ID}"

# DB_PASSWORD (32 Zeichen)
DB_PASSWORD=$(openssl rand -base64 24 | tr -d '/+=' | head -c 32)
echo "DB_PASSWORD=${DB_PASSWORD}"

# DB_ROOT_PASSWORD (32 Zeichen)
DB_ROOT_PASSWORD=$(openssl rand -base64 24 | tr -d '/+=' | head -c 32)
echo "DB_ROOT_PASSWORD=${DB_ROOT_PASSWORD}"

# OPENSEARCH_PASSWORD (24 Zeichen, mind. 8)
OPENSEARCH_PASSWORD=$(openssl rand -base64 18 | tr -d '/+=' | head -c 24)
echo "OPENSEARCH_PASSWORD=${OPENSEARCH_PASSWORD}"

echo ""
echo "✅ Kopiere diese Werte in deine .env.production Datei in Coolify!"
echo "⚠️  WICHTIG: Speichere diese Werte sicher - sie werden nicht nochmal angezeigt!"
