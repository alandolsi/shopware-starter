# Shopware Production Deployment auf Coolify

## 🔐 Schritt 1: Sichere Credentials generieren

Führe das Script lokal aus:

```bash
./generate-secrets.sh
```

Kopiere die Ausgabe - diese Werte brauchst du für Coolify!

## 🚀 Schritt 2: Coolify Setup

### 2.1 Neues Projekt erstellen
1. In Coolify: **New Resource** → **Docker Compose**
2. Repository: Dein Git-Repository (GitHub/GitLab/etc.)
3. Branch: `main`
4. Docker Compose Datei: `compose.yaml`

### 2.2 Environment Variables konfigurieren

Gehe zu **Environment** und füge folgende Variablen hinzu:

```env
# PFLICHTFELDER - Werte vom generate-secrets.sh Script!
APP_ENV=prod
APP_URL=https://deine-domain.com
APP_SECRET=<aus Script kopieren>
INSTANCE_ID=<aus Script kopieren>

DB_NAME=shopware
DB_USER=shopware
DB_PASSWORD=<aus Script kopieren>
DB_ROOT_PASSWORD=<aus Script kopieren>

OPENSEARCH_PASSWORD=<aus Script kopieren>

# Optional - Standard-Werte funktionieren
SHOPWARE_ES_ENABLED=0
SHOPWARE_ES_INDEXING_ENABLED=0
SHOPWARE_ES_INDEX_PREFIX=sw
SHOPWARE_HTTP_CACHE_ENABLED=1
SHOPWARE_HTTP_DEFAULT_TTL=7200
LOCK_DSN=flock
TRUSTED_PROXIES=127.0.0.1,REMOTE_ADDR
MAILER_DSN=null://null
```

### 2.3 Domain konfigurieren

1. **Domains & SSL**: Füge deine Domain hinzu (z.B. `shop.example.com`)
2. Coolify generiert automatisch Let's Encrypt SSL-Zertifikate
3. Port Mapping: `80:80` (wird automatisch gemacht wenn APP_PORT nicht gesetzt)

### 2.4 Persistente Volumes prüfen

Coolify erstellt automatisch Volumes aus `compose.yaml`:
- `db-data` → MariaDB Datenbank
- `opensearch-data` → OpenSearch Index
- `media-data` → Shopware Media-Dateien
- `thumbnail-data` → Generierte Thumbnails
- `theme-data` → Theme-Assets

## 📦 Schritt 3: First Deployment

### 3.1 Deploy starten
1. In Coolify: **Deploy** Button
2. Build-Logs beobachten (dauert 5-10 Minuten beim ersten Mal)
3. Warten bis alle Services "healthy" sind

### 3.2 Shopware Installation durchführen

Nach erfolgreichem Build musst du Shopware installieren:

```bash
# In Coolify: Terminal des 'app' Containers öffnen
bin/console system:install --basic-setup --create-database --force

# Admin-User erstellen
bin/console user:create --admin --email="admin@example.com" --firstName="Admin" --lastName="User" --password="SicheresPasswort123!"

# Cache clearen
bin/console cache:clear
```

### 3.3 URL in Shopware konfigurieren

```bash
bin/console sales-channel:update:domain https://deine-domain.com
bin/console system:config:set core.basicInformation.url "https://deine-domain.com"
```

## ✅ Schritt 4: Verifikation

1. Öffne `https://deine-domain.com` → Storefront sollte laden
2. Öffne `https://deine-domain.com/admin` → Admin-Login
3. Prüfe Health-Check: `https://deine-domain.com/api/_info/health-check`

## 🔄 Updates deployen

Bei Code-Änderungen:
1. Push zu Git
2. In Coolify: **Redeploy**
3. Coolify führt automatisch aus:
   - Docker Image neu bauen
   - Rolling Update (zero downtime)
   - Health-Checks prüfen

## 🗄️ Datenbank-Backups

### Manuelles Backup erstellen

```bash
# Im 'database' Container:
mariadb-dump -u root -p$DB_ROOT_PASSWORD shopware > /tmp/backup.sql

# Backup runterladen (in Coolify: File Browser)
```

### Automatische Backups (Coolify Feature)

1. Gehe zu **Backups** in deinem Projekt
2. Aktiviere automatische Backups für `db-data` Volume
3. Konfiguriere Backup-Frequenz (täglich empfohlen)

## 🔧 Troubleshooting

### Container startet nicht
- Prüfe Logs: Coolify → **Logs** Tab
- Prüfe Environment Variables: Alle Secrets korrekt gesetzt?

### Shopware zeigt Fehler
```bash
# Im 'app' Container:
tail -f /var/www/html/var/log/prod-*.log
```

### Assets fehlen (CSS/JS)
```bash
# Im 'app' Container:
bin/build-administration.sh
bin/build-storefront.sh
bin/console cache:clear
```

### OpenSearch Verbindungsprobleme
```bash
# Prüfe ob OpenSearch läuft:
curl -u admin:$OPENSEARCH_PASSWORD http://opensearch:9200/_cluster/health

# Wenn du OpenSearch nicht brauchst:
SHOPWARE_ES_ENABLED=0
SHOPWARE_ES_INDEXING_ENABLED=0
```

## 📊 Performance-Optimierungen

Nach dem Deployment:

```bash
# Warming up cache
bin/console http:cache:warm:up
bin/console theme:compile

# Sitemap generieren
bin/console sitemap:generate
```

## 🔒 Sicherheits-Checklist

- [ ] Alle Passwörter sind stark und einzigartig
- [ ] SSL/HTTPS ist aktiv (Let's Encrypt)
- [ ] `APP_ENV=prod` ist gesetzt
- [ ] Admin-Login mit sicherem Passwort
- [ ] Firewall: Nur Port 80/443 offen
- [ ] Regular Backups konfiguriert
- [ ] `.env.local` nicht in Git committed
- [ ] OpenSearch Security aktiviert (`plugins.security.disabled: 'false'`)

## 📞 Support

Bei Problemen:
1. Prüfe Coolify Logs
2. Prüfe Shopware Logs in `var/log/`
3. Prüfe Container Health: `docker ps`
