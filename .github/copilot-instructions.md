# Learn@Home — Instructions pour Agents IA

## 🎯 Présentation du Projet

**Learn@Home** est une application multiplateforme de gestion des tâches et de suivi scolaire, développée dans le cadre d'un projet Master 2 à l'EFREI. Elle met en relation des **élèves en difficulté scolaire** avec des **bénévoles tuteurs**, entièrement en ligne.

### Fonctionnalités Principales

| Domaine | Description |
|---------|-------------|
| **Authentification** | Connexion élève/bénévole, récupération de mot de passe, création de compte |
| **Chat** | Messagerie instantanée élève ↔ bénévole, historique, gestion des contacts |
| **Calendrier** | Affichage des événements et rendez-vous, synchronisation cross-plateforme |
| **Gestion des tâches** | Création/suppression de tâches, règles métier selon le rôle (élève / bénévole) |
| **Tableau de bord** | Récapitulatif des tâches, prochains événements, compteur de messages non lus |

---

## 🏗️ Architecture Monorepo

```
learnathome-monorepo/
├── apps/
│   ├── angular-app/       # Frontend Angular (version Web)
│   └── flutter-app/    # Frontend Flutter (iOS & Android)
├── packages/
│   └── shared-types/  # Types partagés entre les apps
└── firebase/          # Configuration Firebase (règles, indexes, etc.)
```

### Stack Technique

| App | Technologies |
|-----|--------------|
| **Web** | Angular, TypeScript, RxJS |
| **Mobile** | Flutter, Dart |
| **Cloud / Backend** | Firebase Auth, Firestore, Firebase Storage |

---

## 📦 Package Manager & Commandes

**npm** est le package manager. Node >= 18.

```bash
# Web (Angular)
cd apps/angular-app
npm install
npm run start       # Développement
npm run build       # Build production
npm run lint        # Linting

# Mobile (Flutter)
cd apps/flutter-app
flutter pub get
flutter run         # Lancement sur émulateur/device
flutter build apk   # Build Android
flutter build ios   # Build iOS
```

---

## 🔗 Types Partagés (`packages/shared-types`)

**RÈGLE FONDAMENTALE** : Tout type utilisé à la fois par le web et le mobile doit être défini dans `packages/shared-types`.

### Domaines Couverts

- `auth.types` → User, UserRole, LoginPayload...
- `task.types` → Task, TaskStatus, CreateTaskPayload...
- `chat.types` → Message, Conversation, Contact...
- `calendar.types` → Event, CalendarEntry...
- `api.types` → ApiResponse, ApiError...

---

## ⚡ Bonnes Pratiques Générales

### 1. Typage

- **Toujours** typer les paramètres et les retours de fonctions
- Utiliser `type` plutôt que `interface` pour la cohérence
- Éviter `any` — utiliser `unknown` si le type est indéterminé
- Préfixer les variables intentionnellement non utilisées avec `_`

### 2. Gestion des Erreurs

- Toujours traiter les cas d'erreur de manière explicite
- Ne jamais laisser une Promise sans `.catch()` ou un `await` sans `try/catch`
- Utiliser les types `ApiError` définis dans `shared-types` pour les erreurs remontées

### 3. Rôles Métier

- L'application distingue deux rôles : **élève** (`student`) et **bénévole** (`volunteer`)
- Les règles métier liées aux rôles doivent être centralisées (services, guards, règles Firestore)
- Ne jamais hardcoder un comportement de rôle directement dans un composant UI

### 4. Git & Branches

- Branches de fonctionnalité : `feature/nom-de-la-feature`
- Branches de correction : `fix/description-du-bug`
- Format des commits : **Conventional Commits** (en français autorisé)
  ```
  feat: ajout de la page de gestion des tâches
  fix: correction de l'affichage du calendrier sur mobile
  chore: mise à jour des dépendances Flutter
  ```
- **Jamais** de push direct sur `main`
- Toute fonctionnalité passe par une Pull Request

### 5. Variables d'Environnement

- Les credentials Firebase ne doivent **jamais** être commités
- Utiliser les fichiers `.env.example` comme référence
- Chaque app gère ses propres variables d'environnement

### 6. Qualité de Code

- **DRY** : toute logique utilisée 2+ fois doit être extraite (service, helper, widget)
- **KISS** : privilégier la solution la plus simple et lisible
- **YAGNI** : ne pas anticiper des besoins non exprimés
- **SOLID** : respecter les principes de conception orientée objet
- Linting obligatoire avant tout commit

### 7. TDD (Test-Driven Development)

Toute implémentation doit suivre le cycle **Red → Green → Refactor** :

1. **Red** — écrire un test qui échoue décrivant le comportement attendu
2. **Green** — écrire le code minimal pour faire passer le test
3. **Refactor** — améliorer le code sans casser les tests

- Ne jamais écrire du code de production avant d'avoir un test qui l'exige
- Chaque test doit cibler un seul comportement (une assertion par cas)
- Les tests constituent la documentation vivante du code : ils doivent être lisibles et expressifs
- Un agent ne considère une tâche comme terminée que lorsque tous les tests passent

---

## ⛔ Règles Strictes (Ne Jamais Faire)

- **JAMAIS** de `any` TypeScript — utiliser `unknown` si nécessaire
- **JAMAIS** de `console.log` ou `print()` laissé en production
- **JAMAIS** de credentials Firebase en dur dans le code
- **JAMAIS** d'import relatif cross-package (`../../packages/` ❌)
- **JAMAIS** de logique métier dans un composant ou widget UI
- **JAMAIS** de push direct sur `main`
- **JAMAIS** de code commenté laissé dans le dépôt

---

## 🔒 Sécurité

### Authentification

- Gérée intégralement par **Firebase Auth**
- Toutes les pages (sauf connexion/inscription) sont protégées
- Les règles d'accès par rôle sont définies côté **Firestore Security Rules**

### Données Firestore

- Les collections suivent la convention `snake_case` : `users`, `tasks`, `messages`, `calendar_events`
- Les règles Firestore doivent refléter les règles métier (ex : un élève ne peut lire que ses propres tâches)
- Ne jamais exposer de données sensibles dans les règles permissives

---

## 📁 Conventions de Nommage

### Fichiers

| Type | Convention | Exemple |
|------|------------|---------|
| Composants Angular | kebab-case | `task-list.component.ts` |
| Services Angular | kebab-case | `auth.service.ts` |
| Widgets Flutter | PascalCase | `TaskCard.dart` |
| Types partagés | kebab-case + `.types.ts` | `task.types.ts` |
| Collections Firestore | snake_case | `calendar_events` |

### Code

| Élément | Convention |
|---------|------------|
| Variables / fonctions | `camelCase` |
| Classes / Types / Composants | `PascalCase` |
| Constantes | `UPPER_SNAKE_CASE` |
| Champs Firestore | `snake_case` |

---

## 📝 Notes pour les Agents Spécialisés

### Agent Angular (Web)
→ Se référer aux instructions spécifiques Angular pour les patterns de composants, services, routing et gestion de state avec RxJS.

### Agent Flutter (Mobile)
→ Se référer aux instructions spécifiques Flutter pour les patterns de widgets, navigation, gestion de state et intégration Firebase.

