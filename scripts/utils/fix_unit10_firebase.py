import os
import json
import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore

def fix_all_unit10_errors():
    script_dir = os.path.dirname(os.path.abspath(__file__))
    
    unit10_json = os.path.join(script_dir, "..", "..", "data", "generated_c_reels_unit10.json")
    backup_json = os.path.join(script_dir, "..", "..", "data", "reels_backup.json")
    service_account_path = os.path.join(script_dir, "..", "..", "serviceAccountKey.json")

    print("1. Fixing data/generated_c_reels_unit10.json locally...")
    if os.path.exists(unit10_json):
        with open(unit10_json, "r") as f:
            data = json.load(f)
        for d in data:
            d["sectionTitle"] = "UNIT 10 • STRUCTURES"
        with open(unit10_json, "w") as f:
            json.dump(data, f, indent=2)
        print("✅ Fixed unit10 json!")
        
    print("\n2. Fixing data/reels_backup.json locally...")
    if os.path.exists(backup_json):
        with open(backup_json, "r") as f:
            backup = json.load(f)
        for d in backup:
            if d.get("sectionTitle") == "UNIT 10 • STRINGS":
                d["sectionTitle"] = "UNIT 10 • STRUCTURES"
        with open(backup_json, "w") as f:
            json.dump(backup, f, indent=2)
        print("✅ Fixed reels_backup.json!")

    print("\n3. Fixing Firestore Database...")
    if os.path.exists(service_account_path):
        if not firebase_admin._apps:
            cred = credentials.Certificate(service_account_path)
            firebase_admin.initialize_app(cred)
        
        db = firestore.client()
        docs = db.collection('reels').where('sectionTitle', '==', 'UNIT 10 • STRINGS').stream()
        
        count = 0
        batch = db.batch()
        for doc in docs:
            doc_ref = db.collection('reels').document(doc.id)
            batch.update(doc_ref, {'sectionTitle': 'UNIT 10 • STRUCTURES'})
            count += 1
            
        if count > 0:
            batch.commit()
            print(f"✅ Successfully updated {count} reels in Firebase to 'UNIT 10 • STRUCTURES'!")
        else:
            print("No reels found with 'UNIT 10 • STRINGS' in Firebase. They might already be fixed.")
    else:
        print("No service account key found. Skipping Firebase update.")

if __name__ == "__main__":
    fix_all_unit10_errors()
