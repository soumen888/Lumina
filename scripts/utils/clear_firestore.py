import os
import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore

def clear_collection():
    script_dir = os.path.dirname(os.path.abspath(__file__))
    service_account_path = os.path.join(script_dir, "..", "serviceAccountKey.json")
    
    cred = credentials.Certificate(service_account_path)
    if not firebase_admin._apps:
        firebase_admin.initialize_app(cred)
        
    db = firestore.client()
    collection_name = "reels"
    
    print(f"Deleting all documents in collection: {collection_name}...")
    docs = db.collection(collection_name).stream()
    count = 0
    for doc in docs:
        doc.reference.delete()
        count += 1
        
    print(f"✅ Successfully deleted {count} documents.")

if __name__ == "__main__":
    clear_collection()
