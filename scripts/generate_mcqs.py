"""
generate_mcqs.py — Step 2b of the Lumina Pipeline (MCQ variant)
----------------------------------------------------------------
Reads raw_text.txt and generates objective MCQ questions via Gemini API.
All configuration is read from config.yaml — no hardcoded values here.
"""
import os
import json
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

# ── JSON Schema ──────────────────────────────────────────────────────────────
JSON_SCHEMA = """
[
  {
    "subject": "string (the subject name)",
    "question": "string (the full MCQ question text)",
    "context": "string (short context or 'Select the correct option')",
    "options": ["string", "string", "string", "string"],
    "correctIndex": 0
  }
]
"""

# ── System prompt (reads subject from config) ────────────────────────────────
SYSTEM_INSTRUCTION = f"""
You are an expert cognitive learning engine parsing a {cfg['subject']} exam preparation text.
Your job is to extract every multiple-choice question from the text and convert them into a structured JSON array.

If there is an Answer Key at the bottom of the text, use it to set the correct 'correctIndex'.
Note: Answer Key '1' = index 0, '2' = index 1, etc.

You must output ONLY valid JSON matching this exact schema:
{JSON_SCHEMA}

RULES:
1. Output raw JSON array ONLY. No markdown fences, no intro/outro text.
2. Exactly 4 options per question.
3. Extract EVERY single question — do not skip or truncate.
4. Set 'subject' to '{cfg['subject']}' for every object.
"""


def generate_mcqs():
    input_path  = os.path.join(script_dir, "..", "data", "raw_text.txt")
    output_path = os.path.join(script_dir, "..", "data", "MCQ.json")

    if not os.path.exists(input_path):
        print("❌ raw_text.txt not found. Run Extract.py first.")
        return

    print(f"📖 Reading raw text...")
    with open(input_path, "r", encoding="utf-8") as f:
        input_text = f.read()

    print(f"🚀 Initializing {cfg['model_name']}...")
    model = genai.GenerativeModel(
        model_name=cfg["model_name"],
        system_instruction=SYSTEM_INSTRUCTION,
    )

    print("🤖 Sending text to model...")
    try:
        response = model.generate_content(
            f"TEXT TO PROCESS:\n{input_text}",
            generation_config=genai.GenerationConfig(response_mime_type="application/json"),
        )

        data = json.loads(response.text)

        # Force subject tag from config
        for q in data:
            q["subject"] = cfg["subject"]

        print(f"✅ Extracted {len(data)} MCQs.")

        # Merge with existing — deduplicate on question text
        existing = []
        if os.path.exists(output_path):
            try:
                with open(output_path, "r", encoding="utf-8") as f:
                    existing = json.load(f)
            except json.JSONDecodeError:
                print("⚠️  Existing MCQ.json was corrupted. Starting fresh.")

        seen = {q["question"].strip().lower() for q in existing if "question" in q}
        added = 0
        for q in data:
            key = q.get("question", "").strip().lower()
            if key and key not in seen:
                existing.append(q)
                seen.add(key)
                added += 1

        os.makedirs(os.path.dirname(output_path), exist_ok=True)
        with open(output_path, "w", encoding="utf-8") as f:
            json.dump(existing, f, indent=2, ensure_ascii=False)

        print(f"🎉 Added {added} new MCQs. Total: {len(existing)} saved to: {output_path}")

    except Exception as e:
        print(f"❌ Failed: {e}")
        if "response" in dir():
            print(f"Raw response preview: {response.text[:500]}")


if __name__ == "__main__":
    generate_mcqs()
