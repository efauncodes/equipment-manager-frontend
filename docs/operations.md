---
type: concept
title: Equipment Manager frontend operations
status: draft
---

# Betrieb und Workflow

## Lokaler Start

Issue #1 definiert den reproduzierbaren Docker-Desktop-Start des Flutter-Web-Frontends. API-URL, Ports, Healthcheck und Smoke-Test werden dort verbindlich dokumentiert.

## Entwicklungsprozess

Manager erstellt Issues -> Product Owner setzt `ready-for-dev` -> Entwickler arbeitet auf Feature-Branch -> QA prüft -> Product Owner merged nach `test` -> erfolgreicher Test wird nach `main` promoted. Der Main-Merge verwendet `Closes #<issue-number>`.

Bei einem fehlgeschlagenen Test geht die Rückmeldung an den Manager; die nächste Iteration wird erst nach erneuter Product-Owner-Freigabe gestartet.
