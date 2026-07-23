import os
import json
import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore

def cleanup_duplicate_reels():
    script_dir = os.path.dirname(os.path.abspath(__file__))
    bad_reels_path = os.path.join(script_dir, "..", "data", "generated_c_reels_unit10.json")
    backup_path = os.path.join(script_dir, "..", "..", "data", "reels_backup.json")
    service_account_path = os.path.join(script_dir, "..", "serviceAccountKey.json")

    # 1. Load the 35 bad reels to know exactly what to delete
    with open(bad_reels_path, 'r') as f:
        bad_reels = json.load(f)
    
    # We will use conceptTitle + orderIndex to uniquely identify the bad reels
    bad_identifiers = set((r.get('conceptTitle'), r.get('orderIndex')) for r in bad_reels)
    
    print(f"Loaded {len(bad_identifiers)} bad reels to delete.")

    # 2. Remove from local backup
    with open(backup_path, 'r') as f:
        backup = json.load(f)
        
    new_backup = []
    removed_count = 0
    for r in backup:
        identifier = (r.get('conceptTitle'), r.get('orderIndex'))
        if identifier in bad_identifiers:
            removed_count += 1
        else:
            new_backup.append(r)
            
    with open(backup_path, 'w') as f:
        json.dump(new_backup, f, indent=4)
    print(f"✅ Removed {removed_count} duplicate reels from reels_backup.json!")

    # 3. Remove from Firebase
    if not firebase_admin._apps:
        cred = credentials.Certificate(service_account_path)
        firebase_admin.initialize_app(cred)
        
    db = firestore.client()
    docs = db.collection('reels').stream()
    
    batch = db.batch()
    fb_removed = 0
    for doc in docs:
        data = doc.to_dict()
        identifier = (data.get('conceptTitle'), data.get('orderIndex'))
        if identifier in bad_identifiers:
            batch.delete(doc.reference)
            fb_removed += 1
            
    if fb_removed > 0:
        batch.commit()
        print(f"✅ Successfully deleted {fb_removed} duplicate reels from Firebase!")
    else:
        print("No duplicates found in Firebase.")

if __name__ == "__main__":
    cleanup_duplicate_reels()
