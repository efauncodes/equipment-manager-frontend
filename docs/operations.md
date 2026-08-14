---
type: concept
title: Equipment Manager frontend operations
status: draft
---

# Betrieb und Workflow

## Lokaler Start

Issue #1 definiert den reproduzierbaren Docker-Desktop-Start des Flutter-Web-Frontends. Die vollständigen Befehle stehen in [Containerisierung](containerization.md):

- Host-Port: `8080` (änderbar über `FRONTEND_PORT`)
- Container-Port: `80`
- Healthcheck: `GET /healthz` mit Body `ok`
- Smoke-Test: Healthcheck und Startseite mit `curl`
- Backend: bewusst nicht Bestandteil dieses Frontend-Compose-Setups

## Entwicklungsprozess

Manager erstellt Issues -> Product Owner setzt `ready-for-dev` -> Entwickler arbeitet auf Feature-Branch -> QA prüft -> Product Owner merged nach `test` -> erfolgreicher Test wird nach `main` promoted. Der Main-Merge verwendet `Closes #<issue-number>`.

Bei einem fehlgeschlagenen Test geht die Rückmeldung an den Manager; die nächste Iteration wird erst nach erneuter Product-Owner-Freigabe gestartet.
