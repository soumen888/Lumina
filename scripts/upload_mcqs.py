"""
upload_mcqs.py — Step 3b of the Lumina Pipeline
-------------------------------------------------
Uploads MCQ.json to the Firestore collection defined in config.yaml.
"""
import os
import json
import yaml
import firebase_admin
from firebase_admin import credentials, firestore

script_dir = os.path.dirname(os.path.abspath(__file__))

with open(os.path.join(script_dir, "config.yaml"), "r") as f:
    cfg = yaml.safe_load(f)


def upload_mcqs():
    json_path            = os.path.join(script_dir, "..", "data", "MCQ.json")
    service_account_path = os.path.join(script_dir, "..", "serviceAccountKey.json")
    collection_name      = cfg["mcqs_collection"]

    if not os.path.exists(json_path):
        print("❌ MCQ.json not found. Run generate_mcqs.py first.")
        return

    if not os.path.exists(service_account_path):
        print("❌ serviceAccountKey.json not found.")
        print("   ➡ Copy serviceAccountKey.example.json, fill in your credentials, and rename it.")
        return

    print("🔥 Initializing Firebase...")
    if not firebase_admin._apps:
        firebase_admin.initialize_app(credentials.Certificate(service_account_path))
    db = firestore.client()

    with open(json_path, "r", encoding="utf-8") as f:
        mcqs = json.load(f)

    print(f"📤 Uploading {len(mcqs)} MCQs to '{collection_name}' collection...")
    count = 0
    for mcq in mcqs:
        try:
            db.collection(collection_name).add(mcq)
            count += 1
            if count % 10 == 0 or count == len(mcqs):
                print(f"   ✅ {count}/{len(mcqs)} uploaded...")
        except Exception as e:
            print(f"❌ Failed to upload MCQ {count + 1}: {e}")

    print(f"🎉 Done! {count} MCQs uploaded to Firestore '{collection_name}'.")


if __name__ == "__main__":
    upload_mcqs()
