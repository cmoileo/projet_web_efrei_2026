# 📐 Charte Graphique — UI.doc.md

> Document de référence partagé entre l'app Web (Angular) et l'app Mobile (Flutter).  
> Toute décision UI doit respecter ces règles. Dernière mise à jour : 2025.

---

## 1. Principes

- **Épuré** — pas de décoration inutile, chaque élément a un rôle
- **Cohérent** — mêmes tokens, mêmes composants, même logique sur les 2 apps
- **Accessible** — contraste minimum AA (WCAG 2.1), zones tactiles ≥ 44px
- **Professionnel** — adapté à un contexte scolaire/universitaire

---

## 2. Tokens de Design

### 🎨 Couleurs

| Token | Hex | Usage |
|-------|-----|-------|
| `color-primary` | `#4F6EF7` | Actions principales, liens actifs |
| `color-primary-light` | `#EEF1FE` | Fond des éléments actifs |
| `color-secondary` | `#7C3AED` | Accents, badges spéciaux |
| `color-success` | `#16A34A` | Statut complété, validation |
| `color-warning` | `#D97706` | Statut en attente, alertes |
| `color-danger` | `#DC2626` | Erreurs, suppression |
| `color-bg` | `#F8F9FB` | Fond de page |
| `color-surface` | `#FFFFFF` | Cards, modals, inputs |
| `color-border` | `#E4E7EC` | Bordures, séparateurs |
| `color-text-primary` | `#111827` | Titres, texte principal |
| `color-text-secondary` | `#6B7280` | Sous-titres, labels |
| `color-text-disabled` | `#D1D5DB` | Éléments inactifs |

> **Mode sombre** : non prévu en V1, prévoir les tokens pour faciliter l'ajout plus tard.

---

### 🔤 Typographie

**Police** : `Inter` (Google Fonts)  
**Fallback** : `system-ui, sans-serif`

| Token | Taille | Poids | Usage |
|-------|--------|-------|-------|
| `text-display` | 28px | 700 | Titre de page |
| `text-heading` | 20px | 600 | Titre de section |
| `text-subheading` | 16px | 600 | Sous-titre, card header |
| `text-body` | 14px | 400 | Texte courant |
| `text-small` | 12px | 400 | Labels, métadonnées |
| `text-tiny` | 11px | 500 | Badges, chips |

---

### 📏 Espacements

Basé sur une grille de `4px`.

| Token | Valeur | Usage |
|-------|--------|-------|
| `space-1` | 4px | Micro espacement |
| `space-2` | 8px | Espacement interne compact |
| `space-3` | 12px | Padding inputs, gaps internes |
| `space-4` | 16px | Padding standard |
| `space-5` | 24px | Espacement entre sections |
| `space-6` | 32px | Marges de page |
| `space-8` | 48px | Espacement macro |

---

### 🔘 Rayons de bordure

| Token | Valeur | Usage |
|-------|--------|-------|
| `radius-sm` | 4px | Inputs, badges |
| `radius-md` | 8px | Cards, boutons |
| `radius-lg` | 12px | Modals, drawers |
| `radius-full` | 9999px | Avatars, chips ronds |

---

### 🌑 Ombres

| Token | Valeur CSS | Usage |
|-------|-----------|-------|
| `shadow-sm` | `0 1px 3px rgba(0,0,0,0.08)` | Cards au repos |
| `shadow-md` | `0 4px 12px rgba(0,0,0,0.10)` | Cards hover, dropdowns |
| `shadow-lg` | `0 8px 24px rgba(0,0,0,0.12)` | Modals |

---

### ⚡ Transitions

| Token | Valeur | Usage |
|-------|--------|-------|
| `transition-fast` | `150ms ease` | Hover, focus |
| `transition-base` | `250ms ease` | Apparition composants |
| `transition-slow` | `400ms ease` | Modals, drawers |

---

## 3. Atomic Design

---

### ⚛️ Atoms

#### Bouton

4 variantes, 3 tailles.

| Variante | Fond | Texte | Bordure |
|----------|------|-------|---------|
| `primary` | `color-primary` | blanc | — |
| `secondary` | `color-surface` | `color-primary` | `color-primary` |
| `ghost` | transparent | `color-text-secondary` | — |
| `danger` | `color-danger` | blanc | — |

| Taille | Padding | Font |
|--------|---------|------|
| `sm` | 6px 12px | `text-small` |
| `md` | 10px 20px | `text-body` |
| `lg` | 14px 28px | `text-subheading` |

**Règles :**
- Toujours `border-radius: radius-md`
- État `disabled` : opacité 40%, non cliquable
- État `loading` : spinner à la place du label, désactivé
- Icône possible à gauche du label uniquement

---

#### Input

```
border: 1px solid color-border
border-radius: radius-sm
padding: space-2 space-3
font: text-body / color-text-primary
background: color-surface

:focus   → border-color: color-primary, shadow-sm
:error   → border-color: color-danger
:disabled → background: color-bg, color-text-disabled
```

---

#### Badge de statut

| Statut | Fond | Texte | Label FR |
|--------|------|-------|----------|
| `todo` | `#F3F4F6` | `color-text-secondary` | À faire |
| `in_progress` | `#FEF3C7` | `#D97706` | En cours |
| `done` | `#DCFCE7` | `#16A34A` | Terminé |
| `late` | `#FEE2E2` | `#DC2626` | En retard |

Style : `text-tiny`, `radius-full`, padding `2px 8px`, poids `500`.

---

#### Avatar

- Forme : cercle (`radius-full`)
- Tailles : `24px` / `32px` / `40px` / `48px`
- Fallback (pas de photo) : initiales en `color-primary` sur fond `color-primary-light`
- Police fallback : `text-small`, poids `600`

---

#### Icônes

- Librairie : **Lucide** (Web : `lucide-angular` / Mobile : `lucide-flutter`)
- Taille standard : `16px` (inline), `20px` (bouton), `24px` (navigation)
- Couleur : hérite du contexte, jamais hardcodée
- Pas d'icône sans label accessible (tooltip ou aria-label)

---

#### Divider

```
height: 1px
background: color-border
margin: space-4 0
```

---

### 🧩 Molecules

#### Form Field

```
[Label]        → text-small, color-text-secondary, margin-bottom: space-1
[Input]        → atom Input
[Message]      → text-tiny, color-danger (erreur) ou color-text-secondary (hint)
```

---

#### Card

```
background: color-surface
border: 1px solid color-border
border-radius: radius-md
padding: space-4
shadow: shadow-sm

:hover → shadow-md, transition-fast
```

Variante `flat` : pas d'ombre, bordure uniquement.

---

#### Task Item

```
[ Checkbox ] [ Titre tâche ]         [ Badge statut ]
             [ Sous-texte : échéance / assigné ]   [ Icône action ]
```

- Titre : `text-body`, poids `500`
- Sous-texte : `text-small`, `color-text-secondary`
- Tâche terminée : titre barré, opacité 60%

---

#### Message Bubble (Chat)

```
Moi   → aligné droite, fond color-primary, texte blanc, radius-lg radius-sm en bas droite
Autre → aligné gauche, fond color-bg, texte color-text-primary, radius-lg radius-sm en bas gauche
```

- Heure : `text-tiny`, `color-text-secondary`, sous la bulle
- Max-width : 70% du conteneur

---

#### Toast / Notification

| Type | Couleur bordure gauche | Icône |
|------|----------------------|-------|
| `success` | `color-success` | `check-circle` |
| `error` | `color-danger` | `x-circle` |
| `warning` | `color-warning` | `alert-triangle` |
| `info` | `color-primary` | `info` |

- Position : bas droite (web), bas centré (mobile)
- Durée : 4 secondes auto-dismiss
- `border-radius: radius-md`, `shadow-md`

---

### 🏗️ Organisms

#### Sidebar (Web) / Navigation Rail (Mobile)

**Web — Sidebar**
```
Largeur : 240px (expanded) / 64px (collapsed)
Fond : color-surface
Bordure droite : color-border

Éléments :
  - Logo / Nom app (top)
  - Nav items : icône + label, padding space-3 space-4
  - Item actif : fond color-primary-light, texte color-primary, bordure gauche 3px color-primary
  - Séparateur entre groupes
  - Avatar + nom utilisateur (bottom)
```

**Mobile — Bottom Navigation**
```
4 items max
Icône 24px + label text-tiny
Actif : color-primary
Inactif : color-text-secondary
Fond : color-surface, bordure top color-border
```

---

#### Top App Bar

```
Height : 56px (mobile) / 64px (web)
Fond : color-surface
Bordure bas : color-border
Shadow : shadow-sm en scroll uniquement

Contenu gauche : titre de page (text-heading)
Contenu droite : actions (icônes), avatar
```

---

#### Modal / Dialog

```
Overlay : rgba(0,0,0,0.4)
Conteneur : color-surface, radius-lg, shadow-lg
Largeur web : 480px (sm) / 640px (md) / 800px (lg)
Padding : space-5

Structure :
  [Header]  : titre (text-heading) + bouton fermeture
  [Body]    : contenu
  [Footer]  : actions alignées à droite (bouton ghost + bouton primary)
```

---

### 📄 Templates

#### Layout Web

```
┌─────────────────────────────────┐
│         Top App Bar             │
├──────────┬──────────────────────┤
│          │                      │
│ Sidebar  │   Main Content       │
│ 240px    │   padding: space-6   │
│          │   max-width: 1200px  │
│          │                      │
└──────────┴──────────────────────┘
```

---

#### Layout Mobile

```
┌─────────────────┐
│   Top App Bar   │
├─────────────────┤
│                 │
│  Main Content   │
│  padding: sp-4  │
│                 │
├─────────────────┤
│  Bottom Nav Bar │
└─────────────────┘
```

---

## 4. Règles à respecter

| ✅ Faire | ❌ Ne pas faire |
|---------|----------------|
| Utiliser les tokens de couleur | Hardcoder des hex dans les composants |
| Inter comme police | Mélanger plusieurs polices |
| Icônes Lucide uniquement | Mélanger FontAwesome, Material, etc. |
| Labels accessibles sur chaque icône | Icônes seules sans contexte |
| Espacements multiples de 4px | Valeurs arbitraires (13px, 17px...) |
| Feedback visuel sur chaque action | Boutons sans état hover/focus/loading |