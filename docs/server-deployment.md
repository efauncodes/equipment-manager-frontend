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
set -eu

git clone https://github.com/efauncodes/equipment-manager-frontend.git
cd equipment-manager-frontend

export FRONTEND_PORT=8080
export API_BASE_URL='http://<backend-host>:<backend-port>'
export PR_BRANCH=feature/3-external-docker-server-acceptance
export PR_NUMBER=6
# Set PR_HEAD_SHA to the exact verified PR head before running this block.
# The review baseline supplied for this issue is 37c22ccbcf8663c119df789c8f4efc48014c5844.
: "${PR_HEAD_SHA:?set the exact verified PR #6 head SHA}"
git fetch origin "refs/heads/${PR_BRANCH}:refs/remotes/origin/${PR_BRANCH}"
test "$(git rev-parse "refs/remotes/origin/${PR_BRANCH}")" = "$PR_HEAD_SHA"
git fetch origin "pull/${PR_NUMBER}/head:issue-${PR_NUMBER}"
git checkout --detach "$PR_HEAD_SHA"
test "$(git rev-parse HEAD)" = "$PR_HEAD_SHA"
```

`FRONTEND_PORT` wählt den externen Host-Port. `API_BASE_URL` wird beim
Flutter-Build eingebettet und ist keine Laufzeit-Umgebungsvariable des
statischen Web-Bundles. Nach jeder Änderung an `API_BASE_URL` ist daher ein
erneuter Build erforderlich. `PR_NUMBER` und `PR_HEAD_SHA` stellen sicher,
dass die Abnahme den ausdrücklich übergebenen Head des Pull Requests und nicht
versehentlich `main` prüft. Der Branch-Ref und der übergebene SHA müssen
übereinstimmen; der SHA wird anschließend lokal verifiziert. Ein beweglicher
Branch-Head allein reicht für die Testidentität nicht aus.

Vor dem Build kann die gerenderte Compose-Konfiguration geprüft werden:

```sh
docker compose config
```

## Build und Start

```sh
set -eu

docker compose up --build -d
test "$(docker compose ps --services --filter status=running | grep -cx frontend)" = 1
docker compose ps --format json | grep -q '"Health":"healthy"'
```

Der Service muss genau einmal als laufend gefunden werden und im maschinen-
lesbaren Compose-Output den Zustand `healthy` melden. Der verwendete
Git-Commit wird für den Nachweis festgehalten:

```sh
git rev-parse HEAD
```

## Lokaler Servertest

Diese Prüfungen laufen auf dem Server selbst und müssen erfolgreich sein:

```sh
set -eu

assert_http_200() {
  test "$(curl --silent --show-error --output /dev/null --write-out '%{http_code}' "$1")" = 200
}

assert_http_200 http://127.0.0.1:8080/healthz
test "$(curl --silent --show-error http://127.0.0.1:8080/healthz)" = ok
assert_http_200 http://127.0.0.1:8080/
curl --silent --show-error http://127.0.0.1:8080/ | grep -q "Equipment Manager"
```

`assert_http_200` verwirft jeden Status außer HTTP 200, einschließlich 3xx.
Der Healthcheck muss exakt `ok` ausgeben. Die Startseite muss den Titel
`Equipment Manager` enthalten.

## Externe Abnahme von einem separaten Rechner

Die folgenden Befehle werden außerhalb des Servers ausgeführt. `<server-ip>`
ist durch die IP-Adresse des Servers und `<host-port>` durch den freigegebenen
Wert von `FRONTEND_PORT` zu ersetzen. Ein DNS-Name oder HTTPS ist für diesen
Test nicht erforderlich.

```sh
set -eu

export FRONTEND_URL='http://<server-ip>:<host-port>'

assert_http_200() {
  test "$(curl --silent --show-error --output /dev/null --write-out '%{http_code}' "$1")" = 200
}

assert_http_200 "$FRONTEND_URL/healthz"
test "$(curl --silent --show-error "$FRONTEND_URL/healthz")" = ok
assert_http_200 "$FRONTEND_URL/"
curl --silent --show-error "$FRONTEND_URL/" | grep -q "Equipment Manager"
assert_http_200 "$FRONTEND_URL/qa/unknown-route"
curl --silent --show-error "$FRONTEND_URL/qa/unknown-route" | grep -q "Equipment Manager"
```

Auch die externe Matrix verwirft jeden Status außer HTTP 200, einschließlich
3xx. Der Healthcheck muss exakt `ok` ausgeben.

Zusätzlich wird die Anwendung im Browser über `FRONTEND_URL` geöffnet. Der
Browsertest bestätigt, dass die Flutter-Web-Anwendung ohne Serverfehler lädt.
Die unbekannte Route muss über den nginx-Fallback auf `index.html` auflösen.

## Neustart und kontrollierter Abbau

Der externe Healthcheck wird nach einem Container-Neustart wiederholt:

```sh
set -eu

docker compose restart frontend
test "$(docker compose ps --services --filter status=running | grep -cx frontend)" = 1
docker compose ps --format json | grep -q '"Health":"healthy"'
test "$(curl --silent --show-error --output /dev/null --write-out '%{http_code}' "$FRONTEND_URL/healthz")" = 200
```

Nach der Abnahme wird der Dienst vollständig entfernt:

```sh
set -eu

docker compose down --remove-orphans
test -z "$(docker compose ps -aq)"
```

Die letzte Assertion verlangt, dass nach `docker compose down --remove-orphans`
keine Compose-Service-Container mehr vorhanden sind.

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
