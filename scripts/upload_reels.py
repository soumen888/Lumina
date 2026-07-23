"""
upload_reels.py — Step 3a of the Lumina Pipeline
--------------------------------------------------
Uploads generated_reels.json to the Firestore collection defined in config.yaml.
"""
import os
import json
import yaml
import firebase_admin
from firebase_admin import credentials, firestore

script_dir = os.path.dirname(os.path.abspath(__file__))

with open(os.path.join(script_dir, "config.yaml"), "r") as f:
    cfg = yaml.safe_load(f)


def upload_reels():
    json_path            = os.path.join(script_dir, "..", "data", "generated_reels.json")
    service_account_path = os.path.join(script_dir, "..", "serviceAccountKey.json")
    collection_name      = cfg["reels_collection"]

    if not os.path.exists(json_path):
        print(f"❌ generated_reels.json not found. Run generate_reels.py first.")
        return

    if not os.path.exists(service_account_path):
        print(f"❌ serviceAccountKey.json not found.")
        print(f"   ➡ Copy serviceAccountKey.example.json, fill in your credentials, and rename it.")
        return

    print("🔥 Initializing Firebase...")
    if not firebase_admin._apps:
        firebase_admin.initialize_app(credentials.Certificate(service_account_path))
    db = firestore.client()

    with open(json_path, "r", encoding="utf-8") as f:
        reels = json.load(f)

    print(f"📤 Uploading {len(reels)} reels to '{collection_name}' collection...")
    count = 0
    for reel in reels:
        db.collection(collection_name).add(reel)
        count += 1
        if count % 10 == 0:
            print(f"   ✅ {count}/{len(reels)} uploaded...")

    print(f"🎉 Done! {count} reels uploaded to Firestore '{collection_name}'.")


if __name__ == "__main__":
    upload_reels()
