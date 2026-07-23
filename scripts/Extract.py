"""
Extract.py — Step 1 of the Lumina Pipeline
-------------------------------------------
Reads a PDF defined in config.yaml and dumps raw text into data/raw_text.txt.
Edit config.yaml to set your PDF filename and page range.
"""
import os
import yaml
import PyPDF2

script_dir = os.path.dirname(os.path.abspath(__file__))

# Load config
with open(os.path.join(script_dir, "config.yaml"), "r") as f:
    cfg = yaml.safe_load(f)

def extract_raw_text():
    pdf_path    = os.path.join(script_dir, "..", "data", cfg["pdf_filename"])
    output_path = os.path.join(script_dir, "..", "data", "raw_text.txt")
    start_page  = cfg["start_page"]
    end_page    = cfg["end_page"]

    if not os.path.exists(pdf_path):
        print(f"❌ Error: PDF not found at: {pdf_path}")
        print(f"   ➡ Place your PDF in the /data folder and set 'pdf_filename' in config.yaml")
        return

    print(f"📖 Reading '{cfg['pdf_filename']}' — pages {start_page} to {end_page}...")

    all_text = ""
    with open(pdf_path, "rb") as file:
        reader   = PyPDF2.PdfReader(file)
        end_page = min(end_page, len(reader.pages))

        for page_num in range(start_page, end_page):
            print(f"   Extracting page {page_num}...")
            text = reader.pages[page_num].extract_text()
            all_text += f"\n\n--- PAGE {page_num} ---\n\n"
            all_text += text

    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    with open(output_path, "w", encoding="utf-8") as f:
        f.write(all_text)

    print(f"\n🎉 Done! Raw text saved to: {output_path}")

if __name__ == "__main__":
    extract_raw_text()
