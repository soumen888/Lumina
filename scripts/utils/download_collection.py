import firebase_admin
from firebase_admin import credentials, firestore
import json

# 1. Initialize Firebase Admin
# Replace 'path/to/serviceAccountKey.json' with your actual file path
cred = credentials.Certificate('serviceAccountKey.json')
firebase_admin.initialize_app(cred)

db = firestore.client()

# 2. Specify your collection name
COLLECTION_NAME = 'reels'  # <--- Change this!

print(f"Downloading collection: {COLLECTION_NAME}...")

# 3. Fetch all documents
docs = db.collection(COLLECTION_NAME).stream()

# 4. Convert to a list of dictionaries
data = []
for doc in docs:
    doc_data = doc.to_dict()
    # It's helpful to keep the document ID for when you need to delete duplicates later
    doc_data['__id__'] = doc.id 
    data.append(doc_data)

# 5. Save to a JSON file
import os
os.makedirs("data", exist_ok=True)
output_file = f"data/{COLLECTION_NAME}_backup.json"
with open(output_file, 'w', encoding='utf-8') as f:
    json.dump(data, f, indent=4, ensure_ascii=False)

print(f"Successfully downloaded {len(data)} documents to {output_file}")
