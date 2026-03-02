# Learn@Home

Plateforme de soutien scolaire en ligne mettant en relation des élèves et des bénévoles tuteurs.

## Stack

| App | Technologies |
|-----|-------------|
| Web | Angular 21, TypeScript, RxJS |
| Mobile | Flutter 3.41 |
| Backend | Firebase Auth, Firestore, Firebase Storage |

## Structure

```
projet_web_efrei_2026/
├── apps/
│   ├── angular-app/     # Frontend Angular (web)
│   └── flutter-app/     # Frontend Flutter (iOS & Android)
├── docker-compose.yml
├── package.json
└── pnpm-workspace.yaml
```

## Prérequis

- Node >= 20
- pnpm >= 8
- Flutter >= 3.41
- Docker & Docker Compose

## Installation

```bash
# Web
pnpm install

# Mobile
cd apps/flutter-app && flutter pub get
```

## Développement

```bash
# Angular
pnpm dev:angular

# Flutter
cd apps/flutter-app && flutter run
```

## Docker

```bash
docker compose up --build
```

Les applications sont exposées sur :
- Angular → http://localhost:4200
- Flutter (web) → http://localhost:8080
