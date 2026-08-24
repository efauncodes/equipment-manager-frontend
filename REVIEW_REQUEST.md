# Review Request

## Issue

Issue #3 — Frontend auf externem Docker-Server installieren und remote abnehmen.

## Handoff

- Branch: `feature/3-external-docker-server-acceptance`
- PR head: verify the current commit SHA directly on [PR #6](https://github.com/efauncodes/equipment-manager-frontend/pull/6); the PR metadata is authoritative and this handoff intentionally avoids a self-referential commit hash.
- Review baseline SHA before this test-contract correction: `37c22ccbcf8663c119df789c8f4efc48014c5844`.
- Target branch: `main`
- QA verdict: `changes requested — correction in progress`

## Test-contract correction

- Fresh-server checkout resolves PR #6 and verifies the detached `PR_HEAD_SHA`
  before the build; it never relies on the moving `main` branch.
- Local and external curl checks assert HTTP 200 explicitly and still verify
  the `ok` body, the `Equipment Manager` title, and the SPA fallback.
- Compose assertions verify exactly one running `frontend` service, JSON
  health `healthy`, and no remaining Compose containers after `down`.

## Checks

- `dart format --output=none --set-exit-if-changed .` passed.
- `flutter analyze` passed with no issues.
- Flutter web release build completed and produced `build/web/index.html`.
- Static acceptance, documentation-link, scope, and secret checks passed.
- Runbook test-contract assertions are documented for exact HTTP 200, healthy
  service state, complete shutdown, and PR-head pinning.
- `flutter test` could not run because the repository has no `test/` directory.
- Docker, Compose, external server, and browser checks are pending because Docker is not installed on the current host and no remote server was supplied.

## Product-Owner action

Review the runbook and execute the documented server-side and external IP-based
acceptance checks on a Docker-capable `linux/amd64` server. Record the server
versions, commit SHA, local/external check results, restart result, and
controlled shutdown result in the Pull Request before merging to `main`.
