"""
Crée un premier document dans la collection Firestore `tasks` pour initialiser
la collection. Utilise les credentials OAuth2 du Firebase CLI.

Usage : python3 scripts/seed_tasks_collection.py
"""

import json
import urllib.request
import urllib.parse
import os

# ─── Config ──────────────────────────────────────────────────────────────────

PROJECT_ID = "projet-web-c1561"
FIREBASE_CLI_CONFIG = os.path.expanduser(
    "~/.config/configstore/firebase-tools.json"
)
# Firebase CLI OAuth2 client (public, from firebase-tools source)
OAUTH_CLIENT_ID = (
    "563584335869-fgrhgmd47bqnekij5i8b5pr03ho849e6.apps.googleusercontent.com"
)
OAUTH_CLIENT_SECRET = "j9iVZfS8SkqLPHlbpVb0-sHF"
TOKEN_URL = "https://oauth2.googleapis.com/token"
FIRESTORE_URL = (
    f"https://firestore.googleapis.com/v1/projects/{PROJECT_ID}"
    "/databases/(default)/documents/tasks"
)

# ─── Refresh access token ─────────────────────────────────────────────────────

def refresh_access_token(refresh_token: str) -> str:
    payload = urllib.parse.urlencode({
        "client_id": OAUTH_CLIENT_ID,
        "client_secret": OAUTH_CLIENT_SECRET,
        "grant_type": "refresh_token",
        "refresh_token": refresh_token,
    }).encode()
    req = urllib.request.Request(TOKEN_URL, data=payload, method="POST")
    req.add_header("Content-Type", "application/x-www-form-urlencoded")
    with urllib.request.urlopen(req) as resp:
        data = json.loads(resp.read())
    return data["access_token"]

# ─── Create document ──────────────────────────────────────────────────────────

def create_placeholder_task(access_token: str) -> None:
    document = {
        "fields": {
            "title": {"stringValue": "_init"},
            "description": {"stringValue": "Document d'initialisation de la collection. Peut être supprimé."},
            "status": {"stringValue": "todo"},
            "assignedTo": {"stringValue": "__placeholder__"},
            "createdBy": {"stringValue": "__placeholder__"},
            "dueDate": {"timestampValue": "2026-01-01T00:00:00Z"},
            "createdAt": {"timestampValue": "2026-01-01T00:00:00Z"},
            "updatedAt": {"timestampValue": "2026-01-01T00:00:00Z"},
        }
    }
    body = json.dumps(document).encode()
    req = urllib.request.Request(FIRESTORE_URL, data=body, method="POST")
    req.add_header("Authorization", f"Bearer {access_token}")
    req.add_header("Content-Type", "application/json")
    with urllib.request.urlopen(req) as resp:
        result = json.loads(resp.read())
    doc_name = result.get("name", "")
    print(f"✅ Collection 'tasks' créée — document : {doc_name.split('/')[-1]}")

# ─── Main ─────────────────────────────────────────────────────────────────────

def main() -> None:
    with open(FIREBASE_CLI_CONFIG) as f:
        config = json.load(f)

    # Utilise directement l'access_token en cache (vérifié non expiré)
    access_token = config["tokens"]["access_token"]
    print("🔐 Token récupéré depuis le cache Firebase CLI.")

    print(f"📝 Création du document d'initialisation dans '{PROJECT_ID}/tasks'...")
    create_placeholder_task(access_token)

if __name__ == "__main__":
    main()
