import os
import json
import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore

def fix_unit10_in_place():
    script_dir = os.path.dirname(os.path.abspath(__file__))
    unit10_path = os.path.join(script_dir, "..", "data", "generated_c_reels_unit10.json")
    backup_path = os.path.join(script_dir, "..", "..", "data", "reels_backup.json")
    service_account_path = os.path.join(script_dir, "..", "serviceAccountKey.json")

    # 1. Read unit10 json
    with open(unit10_path, 'r') as f:
        unit10_reels = json.load(f)
        
    print(f"Loaded {len(unit10_reels)} reels from generated_c_reels_unit10.json")
    
    # Track exactly which reels we are fixing (using conceptTitle as a unique key for this batch)
    concepts_to_fix = [r['conceptTitle'] for r in unit10_reels]
    
    # 2. Fix the unit10 json itself
    START_INDEX = 278
    for i, reel in enumerate(unit10_reels):
        reel['sectionTitle'] = "UNIT 10 • STRUCTURES"
        reel['orderIndex'] = START_INDEX + i
        
    with open(unit10_path, 'w') as f:
        json.dump(unit10_reels, f, indent=2)
    print("✅ Fixed generated_c_reels_unit10.json locally!")

    # 3. Fix the local backup
    with open(backup_path, 'r') as f:
        backup = json.load(f)
        
    backup_fixed = 0
    for r in backup:
        if r.get('conceptTitle') in concepts_to_fix and r.get('sectionTitle') == "UNIT 10 • STRINGS":
            r['sectionTitle'] = "UNIT 10 • STRUCTURES"
            # We need to find its new orderIndex from the updated unit10_reels
            for new_r in unit10_reels:
                if new_r['conceptTitle'] == r['conceptTitle']:
                    r['orderIndex'] = new_r['orderIndex']
                    break
            backup_fixed += 1
            
    with open(backup_path, 'w') as f:
        json.dump(backup, f, indent=4)
    print(f"✅ Fixed {backup_fixed} reels in reels_backup.json!")

    # 4. Fix Firebase
    if not firebase_admin._apps:
        cred = credentials.Certificate(service_account_path)
        firebase_admin.initialize_app(cred)
        
    db = firestore.client()
    docs = db.collection('reels').where('sectionTitle', '==', 'UNIT 10 • STRINGS').stream()
    
    batch = db.batch()
    fb_fixed = 0
    for doc in docs:
        data = doc.to_dict()
        if data.get('conceptTitle') in concepts_to_fix:
            # Find the new index
            new_idx = None
            for new_r in unit10_reels:
                if new_r['conceptTitle'] == data['conceptTitle']:
                    new_idx = new_r['orderIndex']
                    break
            
            if new_idx is not None:
                doc_ref = db.collection('reels').document(doc.id)
                batch.update(doc_ref, {
                    'sectionTitle': 'UNIT 10 • STRUCTURES',
                    'orderIndex': new_idx
                })
                fb_fixed += 1
                
    if fb_fixed > 0:
        batch.commit()
        print(f"✅ Successfully updated {fb_fixed} reels in Firebase without re-generating!")
    else:
        print("No matching reels found in Firebase to update.")

if __name__ == "__main__":
    fix_unit10_in_place()
