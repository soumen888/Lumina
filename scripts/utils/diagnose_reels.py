import os
import json

def diagnose():
    script_dir = os.path.dirname(os.path.abspath(__file__))
    backup_path = os.path.join(script_dir, "..", "..", "data", "reels_backup.json")
    
    with open(backup_path, 'r') as f:
        reels = json.load(f)
        
    print(f"Total reels in backup: {len(reels)}")
    
    # Group by orderIndex to find where the titles change
    ranges = {}
    for reel in reels:
        title = reel.get('sectionTitle', 'UNKNOWN')
        idx = reel.get('orderIndex', -1)
        
        if title not in ranges:
            ranges[title] = {'min': idx, 'max': idx, 'count': 0}
            
        ranges[title]['min'] = min(ranges[title]['min'], idx)
        ranges[title]['max'] = max(ranges[title]['max'], idx)
        ranges[title]['count'] += 1
        
    for title, stats in ranges.items():
        print(f"Title: '{title}' -> Indexes {stats['min']} to {stats['max']} (Count: {stats['count']})")

if __name__ == "__main__":
    diagnose()
