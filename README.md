# Equipment Manager Frontend

Flutter-Frontend des Equipment Manager Produkts.

## Lokaler Start

Voraussetzungen: Docker Desktop mit aktivem Docker Engine sowie `docker compose`.

```sh
docker compose up --build -d
curl --fail http://localhost:8080/healthz
```

Das Frontend ist anschließend unter <http://localhost:8080> erreichbar. Der
Container meldet sich über `/healthz` als gesund. Der Build verwendet die
bestätigte API-Basis-URL `https://equipment-api.sentient-octopus.dev`.

Zum Stoppen genügt `docker compose down`.

## Projektstatus

Das Repository ist frisch initialisiert. Issue #1 definiert die verbindliche Containerisierung als ersten technischen Schritt.

## Projekt-Wiki

Die kanonische projektbezogene Knowledge-Wiki liegt außerhalb dieses
Repositories in der gebundenen Obsidian-Wiki unter
`/Users/efaun/Documents/ChatGPT/equipment-manager-frontend/wiki`.

Die technische Dokumentation dieses Repositories bleibt versioniert:

- [Architektur](docs/architecture.md)
- [Betrieb und Workflow](docs/operations.md)
- [Containerisierung](docs/containerization.md)
- [Entscheidungen](docs/decisions.md)

## Zuständigkeit

Miharu koordiniert Anforderungen und Issues. Flutter-Entwicklung und QA laufen über die gebundenen Studio-Rollen. `ready-for-dev` wird ausschließlich vom Product Owner gesetzt.
