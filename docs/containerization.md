---
type: concept
title: Equipment Manager frontend containerization
status: draft
---

# Containerisierung — Issue #1

Die erste technische Aufgabe ist ein reproduzierbares Flutter-Web-Container-Setup für Docker Desktop.

## Akzeptanzkriterien

- Reproduzierbarer Flutter-Web-Build im Container.
- Dockerfile und Docker-Compose-Start.
- Dokumentierte API-URL, Ports und Umgebungsvariablen.
- Healthcheck und kurzer lokaler Smoke-Test.
- Keine produktiven Secrets oder Daten.
- Der Start ist gemeinsam mit dem separaten Go-Backend integrierbar.
