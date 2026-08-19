---
type: runbook
title: Equipment Manager frontend server deployment and external acceptance
status: implemented
---

# Serverinstallation und externe Abnahme — Issue #3

Dieses Runbook beschreibt die Installation des bereits containerisierten
Flutter-Web-Frontends auf einem Docker-kompatiblen Server und die Abnahme von
einem separaten Rechner. Das Go-Backend ist nicht Bestandteil dieses Ablaufs.

## Unterstütztes Ziel

- Serverplattform: Linux mit Docker Engine auf `linux/amd64`.
- Build-Image: `ghcr.io/cirruslabs/flutter:3.47.0` (im `Dockerfile` gepinnt).
- Runtime-Image: `nginx:1.27-alpine` (im `Dockerfile` gepinnt).
- Interner Container-Port: `80`.
- Standardmäßiger Host-Port: `8080`.
- Healthcheck: `GET /healthz` liefert HTTP 200 mit exakt `ok`.

Die konkreten Image-Tags dürfen nicht durch `latest` ersetzt werden. ARM- oder
andere Architekturen sind nur zulässig, wenn beide gepinnten Images und der
Server vorab ausdrücklich dafür verifiziert wurden.

## Servervoraussetzungen

Vor dem Start müssen auf dem Server vorhanden und geprüft sein:

- Linux oder eine Docker-kompatible Serverplattform auf `linux/amd64`.
- Docker Engine.
- Docker Compose v2 mit dem Befehl `docker compose`.
- Git oder eine gleichwertige Möglichkeit, den Repository-Stand zu übertragen.
- Ausgehender Zugriff auf GitHub und die Container-Registry beim Build.
- Ein freier TCP-Port für den Frontend-Service.
- Eine Firewall-/Security-Group-Freigabe für diesen externen Port.

Die Versionen und die Serverarchitektur werden für den Testnachweis erfasst:

```sh
uname -s -m
docker version
docker compose version
```

## Checkout und Konfiguration

Der Ablauf ist auf einem frischen Server ohne lokale Flutter- oder Dart-
Installation ausführbar:

```sh
git clone https://github.com/efauncodes/equipment-manager-frontend.git
cd equipment-manager-frontend

export FRONTEND_PORT=8080
export API_BASE_URL=http://<backend-host>:<backend-port>
```

`FRONTEND_PORT` wählt den externen Host-Port. `API_BASE_URL` wird beim
Flutter-Build eingebettet und ist keine Laufzeit-Umgebungsvariable des
statischen Web-Bundles. Nach jeder Änderung an `API_BASE_URL` ist daher ein
erneuter Build erforderlich.

Vor dem Build kann die gerenderte Compose-Konfiguration geprüft werden:

```sh
docker compose config
```

## Build und Start

```sh
docker compose up --build -d
docker compose ps
```

Der Service muss in `docker compose ps` als `healthy` erscheinen. Der
verwendete Git-Commit wird für den Nachweis festgehalten:

```sh
git rev-parse HEAD
```

## Lokaler Servertest

Diese Prüfungen laufen auf dem Server selbst und müssen erfolgreich sein:

```sh
curl --fail --silent --show-error http://127.0.0.1:8080/healthz
test "$(curl --fail --silent --show-error http://127.0.0.1:8080/healthz)" = ok
curl --fail --silent --show-error http://127.0.0.1:8080/ | grep -q "Equipment Manager"
```

Der erste Befehl muss exakt `ok` ausgeben. Der zweite prüft, dass die
Startseite den Titel `Equipment Manager` enthält.

## Externe Abnahme von einem separaten Rechner

Die folgenden Befehle werden außerhalb des Servers ausgeführt. `<server-ip>`
ist durch die IP-Adresse des Servers und `<host-port>` durch den freigegebenen
Wert von `FRONTEND_PORT` zu ersetzen. Ein DNS-Name oder HTTPS ist für diesen
Test nicht erforderlich.

```sh
export FRONTEND_URL=http://<server-ip>:<host-port>

curl --fail --silent --show-error "$FRONTEND_URL/healthz"
test "$(curl --fail --silent --show-error "$FRONTEND_URL/healthz")" = ok
curl --fail --silent --show-error "$FRONTEND_URL/" | grep -q "Equipment Manager"
curl --fail --silent --show-error "$FRONTEND_URL/qa/unknown-route" | grep -q "Equipment Manager"
```

Zusätzlich wird die Anwendung im Browser über `FRONTEND_URL` geöffnet. Der
Browsertest bestätigt, dass die Flutter-Web-Anwendung ohne Serverfehler lädt.
Die unbekannte Route muss über den nginx-Fallback auf `index.html` auflösen.

## Neustart und kontrollierter Abbau

Der externe Healthcheck wird nach einem Container-Neustart wiederholt:

```sh
docker compose restart frontend
docker compose ps
curl --fail --silent --show-error "$FRONTEND_URL/healthz"
```

Nach der Abnahme wird der Dienst vollständig entfernt:

```sh
docker compose down --remove-orphans
docker compose ps
```

Der letzte Befehl darf keinen laufenden Frontend-Service mehr anzeigen.

## Testnachweis für den Pull Request

Der Nachweis enthält mindestens:

- anonymisierte Serverkennung, Betriebssystem und Architektur;
- Docker- und Compose-Version;
- verwendeten Git-Branch und Commit-SHA;
- Host-Port und API-Zieladresse ohne Zugangsdaten oder Tokens;
- Ergebnis von `docker compose ps` einschließlich `healthy`;
- Ergebnis der lokalen und externen Healthchecks;
- Ergebnis der Startseiten-, Browser- und SPA-Fallback-Prüfung;
- Ergebnis des Neustarts und von `docker compose down`;
- Testzeitpunkt und bekannte Einschränkungen.

Keine Secrets, Tokens, Zugangsdaten oder privaten Logs gehören in den Issue-
oder PR-Nachweis. Wenn ein Test wegen fehlender Server- oder Docker-
Voraussetzungen nicht ausgeführt werden kann, wird er als nicht ausgeführt mit
konkreter Ursache und nächstem Schritt dokumentiert.
