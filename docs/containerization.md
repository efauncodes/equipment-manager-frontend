---
type: concept
title: Equipment Manager frontend containerization
status: implemented
---

# Containerisierung — Issue #1

Issue #1 liefert ein reproduzierbares Flutter-Web-Container-Setup für Docker Desktop.

## Voraussetzungen

- Docker Desktop mit aktivem Docker Engine
- Docker Compose v2 (`docker compose version`)
- Freier lokaler Port 8080 (oder ein anderer Wert über `FRONTEND_PORT`)

Flutter und Dart müssen lokal nicht installiert sein; der Build verwendet das
gepinnt deklarierte Flutter-SDK-Image im `Dockerfile`.

## Build und Start

```sh
docker compose build
docker compose up -d
docker compose ps
```

Die Anwendung wird auf `http://localhost:8080` veröffentlicht. Der Container
lauscht intern auf Port 80. Für die spätere Backend-Integration kann die beim
Build eingebettete API-URL gesetzt werden:

```sh
API_BASE_URL=http://localhost:8081 docker compose up --build -d
```

`API_BASE_URL` ist eine Flutter-Compile-Time-Konfiguration und deshalb ein
Build-Argument, keine Laufzeit-Umgebungsvariable im statischen Web-Bundle.

## Healthcheck und Smoke-Test

```sh
curl --fail --silent http://localhost:8080/healthz
curl --fail --silent http://localhost:8080/ | grep -q "Equipment Manager"
docker compose ps --format json
docker compose down
```

Der erwartete Healthcheck-Body ist `ok`. Die SPA-Fallback-Regel in nginx sorgt
dafür, dass auch unbekannte Frontend-Routen auf `index.html` zurückfallen.

## Akzeptanzkriterien

- Reproduzierbarer Flutter-Web-Build im Container.
- Dockerfile und Docker-Compose-Start.
- Dokumentierte API-URL, Ports und Umgebungsvariablen.
- Healthcheck und kurzer lokaler Smoke-Test.
- Keine produktiven Secrets oder Daten.
- Der Start ist gemeinsam mit dem separaten Go-Backend integrierbar.
