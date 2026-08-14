---
type: concept
title: Equipment Manager frontend decisions
status: draft
---

# Entscheidungen

## 0001 — Getrennte Repository-Grenze

Flutter-Frontend und Go-Backend werden in getrennten Repositories entwickelt und über einen dokumentierten API-Vertrag integriert.

## 0002 — Container zuerst

Docker-Desktop-Start, Healthcheck und Smoke-Test werden vor externer CI/CD und Cloud-Deployment fertiggestellt.

## 0003 — Test vor Main

Nur ein erfolgreicher Product-Owner-Merge nach `test` darf nach `main` promoted werden; erst der Main-Merge schließt das Issue.
