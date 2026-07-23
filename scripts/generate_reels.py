"""
generate_reels.py — Step 2 of the Lumina Pipeline
---------------------------------------------------
Reads raw_text.txt and sends it to the Gemini API in chunks.
The AI converts each chunk into structured Reel JSON objects.
All configuration is read from config.yaml — no hardcoded values here.
"""
import os
import re
import json
import time
import yaml
from dotenv import load_dotenv
import google.generativeai as genai

script_dir = os.path.dirname(os.path.abspath(__file__))

# Load secrets
load_dotenv(dotenv_path=os.path.join(script_dir, "..", ".env"))
API_KEY = os.getenv("GEMINI_API_KEY") or os.getenv("API_KEY")
if not API_KEY:
    print("Warning: No API key found. Set GEMINI_API_KEY in your .env file.")

genai.configure(api_key=API_KEY)

# Load config
with open(os.path.join(script_dir, "config.yaml"), "r") as f:
    cfg = yaml.safe_load(f)

# ── JSON Schema (universal — works for any subject) ─────────────────────────
JSON_SCHEMA = """
[
  {
    "moduleId": "string (unique id, e.g. 'subj_unit1_01')",
    "sectionTitle": "string (chapter/unit label, e.g. 'UNIT 1 • INTRODUCTION')",
    "conceptTitle": "string (name of this specific concept)",
    "coreConcept": "string (concise explanation of the concept)",
    "examples": [
      {
        "code": "string (code snippet, formula, or example — use empty string if not applicable)",
        "explanation": "string (what the example demonstrates)"
      }
    ],
    "masteryCheck": {
      "question": "string (a single MCQ question to test understanding)",
      "options": ["string", "string", "string", "string"],
      "correctIndex": 0,
      "explanation": "string (why the correct answer is correct)"
    },
    "flashcard": {
      "front": "string (question or prompt for the flashcard)",
      "back": "string (answer or key detail)"
    }
  }
]
"""

# ── System prompt (reads subject from config) ────────────────────────────────
SYSTEM_INSTRUCTION = f"""
You are an expert cognitive learning engine.
Your job is to read {cfg['subject']} content from the provided text and convert it into a highly dense, reel-based micro-learning format.

You must output ONLY valid JSON that perfectly matches this exact schema:
{JSON_SCHEMA}

RULES:
1. Output raw JSON array ONLY. No markdown fences, no intro/outro text.
2. Keep 'coreConcept' extremely concise but complete — a student should understand the idea in 30 seconds.
3. Each reel covers exactly ONE concept. Extract EVERY concept, rule, keyword, and formula — do not skip anything.
4. If the subject has no code examples, use the 'examples.code' field for formulas, key terms, or leave it as an empty string.
"""


def generate_reels():
    input_path  = os.path.join(script_dir, "..", "data", "raw_text.txt")
    output_path = os.path.join(script_dir, "..", "data", "generated_reels.json")

    chunk_size      = cfg["chunk_size"]
    overlap         = cfg["chunk_overlap"]
    start_chunk     = cfg["start_chunk"]
    start_order_idx = cfg["start_order_index"]
    unit_title      = cfg["unit_title"]
    segment         = cfg["segment"]
    subject         = cfg["subject"]
    max_retries     = 3

    if not os.path.exists(input_path):
        print(f"❌ raw_text.txt not found. Run Extract.py first.")
        return

    print(f"🚀 Initializing {cfg['model_name']}...")
    model = genai.GenerativeModel(
        model_name=cfg["model_name"],
        system_instruction=SYSTEM_INSTRUCTION,
    )

    all_reels = []

    # Resume support — load existing output to append to it
    if start_chunk > 1 and os.path.exists(output_path):
        print(f"▶️  Resuming from chunk {start_chunk}. Loading existing reels...")
        with open(output_path, "r", encoding="utf-8") as f:
            all_reels = json.load(f)

    with open(input_path, "r", encoding="utf-8") as f:
        input_text = f.read()

    if len(input_text.strip()) < 50:
        print("❌ raw_text.txt is empty or too short.")
        return

    pages = re.split(r"--- PAGE \d+ ---", input_text)
    pages = [p.strip() for p in pages if p.strip()]

    i, chunk_count = 0, 1

    while i < len(pages):
        chunk_text = "\n".join(pages[i : i + chunk_size])

        if len(chunk_text.strip()) < 50:
            i += (chunk_size - overlap)
            continue

        if chunk_count < start_chunk:
            i += (chunk_size - overlap)
            chunk_count += 1
            continue

        print(f"\n📦 Processing chunk {chunk_count} (pages {i+1}–{min(i+chunk_size, len(pages))})...")

        for attempt in range(max_retries):
            try:
                response = model.generate_content(chunk_text)
                raw      = response.text.strip()

                # Extract the JSON array from the response robustly
                match = re.search(r"\[\s*\{.*\}\s*\]", raw, re.DOTALL)
                clean = match.group(0) if match else raw

                # Fix common escape issues in code blocks
                clean = clean.replace("\\'", "'")
                clean = re.sub(r"(?<!\\)\\(?![nrt\"\\\/bf])", r"\\\\", clean)

                data = json.loads(clean)

                # Inject structural metadata from config
                for reel in data:
                    reel["segment"]     = segment
                    reel["subject"]     = subject
                    reel["sectionTitle"] = unit_title
                    reel["orderIndex"]  = len(all_reels) + start_order_idx
                    all_reels.append(reel)

                print(f"✅ Extracted {len(data)} reels. Total so far: {len(all_reels)}")

                # Save incrementally after every chunk
                os.makedirs(os.path.dirname(output_path), exist_ok=True)
                with open(output_path, "w", encoding="utf-8") as f:
                    json.dump(all_reels, f, indent=2, ensure_ascii=False)

                time.sleep(15)  # Respect API rate limits
                break

            except Exception as e:
                print(f"⚠️  Attempt {attempt + 1} failed: {e}")
                if attempt < max_retries - 1:
                    time.sleep(5)
                else:
                    print(f"❌ Skipping chunk {chunk_count} after {max_retries} failed attempts.")

        i += (chunk_size - overlap)
        chunk_count += 1

    print(f"\n🎉 Done! {len(all_reels)} total reels saved to: {output_path}")


if __name__ == "__main__":
    generate_reels()
