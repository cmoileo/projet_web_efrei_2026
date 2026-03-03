"""
Initialise la collection Firestore `conversations` et sa sous-collection
`messages` avec des documents placeholder.

Usage : python3 scripts/seed_conversations_collection.py
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
OAUTH_CLIENT_ID = (
    "563584335869-fgrhgmd47bqnekij5i8b5pr03ho849e6.apps.googleusercontent.com"
)
OAUTH_CLIENT_SECRET = "j9iVZfS8SkqLPHlbpVb0-sHF"
TOKEN_URL = "https://oauth2.googleapis.com/token"
BASE_URL = (
    f"https://firestore.googleapis.com/v1/projects/{PROJECT_ID}"
    "/databases/(default)/documents"
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

# ─── REST helper ─────────────────────────────────────────────────────────────

def post_document(url: str, document: dict, access_token: str) -> str:
    body = json.dumps(document).encode()
    req = urllib.request.Request(url, data=body, method="POST")
    req.add_header("Authorization", f"Bearer {access_token}")
    req.add_header("Content-Type", "application/json")
    with urllib.request.urlopen(req) as resp:
        result = json.loads(resp.read())
    return result.get("name", "").split("/")[-1]

# ─── Create conversation ──────────────────────────────────────────────────────

def create_placeholder_conversation(access_token: str) -> str:
    document = {
        "fields": {
            "type":      {"stringValue": "direct"},
            "name":      {"nullValue": None},
            "createdBy": {"stringValue": "__placeholder__"},
            "members":   {"arrayValue": {"values": [
                {"stringValue": "__placeholder__"},
            ]}},
            "createdAt": {"timestampValue": "2026-01-01T00:00:00Z"},
            "updatedAt": {"timestampValue": "2026-01-01T00:00:00Z"},
            "lastMessage": {"nullValue": None},
        }
    }
    doc_id = post_document(
        f"{BASE_URL}/conversations",
        document,
        access_token,
    )
    print(f"✅ Collection 'conversations' créée — document : {doc_id}")
    return doc_id

# ─── Create message sub-document ─────────────────────────────────────────────

def create_placeholder_message(access_token: str, conversation_id: str) -> None:
    document = {
        "fields": {
            "content":  {"stringValue": "_init"},
            "senderId": {"stringValue": "__placeholder__"},
            "sentAt":   {"timestampValue": "2026-01-01T00:00:00Z"},
            "readBy":   {"arrayValue": {"values": []}},
        }
    }
    doc_id = post_document(
        f"{BASE_URL}/conversations/{conversation_id}/messages",
        document,
        access_token,
    )
    print(f"✅ Sous-collection 'messages' créée — document : {doc_id}")

# ─── Main ─────────────────────────────────────────────────────────────────────

def main() -> None:
    with open(FIREBASE_CLI_CONFIG) as f:
        config = json.load(f)

    access_token = config["tokens"]["access_token"]
    print("🔐 Token récupéré depuis le cache Firebase CLI.")

    print(f"📝 Initialisation de 'conversations' dans '{PROJECT_ID}'...")
    conversation_id = create_placeholder_conversation(access_token)

    print(f"📝 Initialisation de 'messages' sous '{conversation_id}'...")
    create_placeholder_message(access_token, conversation_id)

    print()
    print("💡 Ces documents placeholder peuvent être supprimés depuis la console Firebase.")
    print(f"   https://console.firebase.google.com/project/{PROJECT_ID}/firestore")

if __name__ == "__main__":
    main()
