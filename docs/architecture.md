---
type: concept
title: Equipment Manager frontend architecture
status: draft
---

# Architektur

- Technologie: Flutter/Dart.
- Repository-Grenze: Frontend only.
- Das Go-Backend liegt in `equipment-manager-backend`.
- Das Flutter-Web-Bundle wird mehrstufig gebaut und durch nginx ausgeliefert.
- Der Container veröffentlicht Port 80; lokal wird er standardmäßig auf Port 8080 gemappt.
- API-URL, Ports und Healthcheck sind in [Containerisierung](containerization.md) dokumentiert.
- Keine produktiven Daten oder Secrets in diesem Repository.
