# Contributing to Lumina ⚡️

> **TL;DR** — Fork the repo, make your change, open a PR. We'll take it from there.

---

## 💡 Why I'm Making This Open Source

The idea behind Lumina is simple:

1. **Upload** a textbook, syllabus, notes, or any study material.
2. **AI breaks it down** into reel-sized learning cards.
3. Instead of doomscrolling, you **scroll through concepts, formulas, stories, examples, and quick revisions**.

The goal is to make learning as engaging as social media — while actually helping you remember what you study.

This isn't just another AI wrapper. I want to build a genuinely useful learning platform, and I know it can become much better with community contributions.

---

## 🧭 What We're Building & Exploring Together

Lumina is an open community project. Whether you have ideas for new learning features, code improvements, or UI refinements, all contributions and discussions are welcome.

Here are the key areas on our collaborative roadmap:

| Area | Ideas & Focus |
| :--- | :--- |
| 📱 **Android / Flutter (UI/UX)** | Smooth reel scrolling physics, Obsidian Scholar dark theme enhancements, active recall UI |
| 🔥 **Firebase & Data Flow** | Firestore rules, caching strategies, client-side data streaming |
| 🤖 **AI Prompting & Pipeline** | Improving chunking & LLM prompt accuracy for generating reel cards |
| 🐍 **Backend & Automation** | Stateless script pipeline, CLI tools, automated ingestion workflows |
| 🧠 **Learning Science** | Spaced repetition algorithms (SM-2), adaptive revision schedules |
| 🧪 **Quality & Accessibility** | Widget tests, accessibility (a11y) improvements, voice narration polish |
| 📖 **Guides & Docs** | Setup tutorials, developer guides, documentation improvements |

---

## 🔥 Current Challenges — Where Help Is Needed Most

These are the open problems we're actively trying to solve:

- **Effortless onboarding** for non-technical students — the setup should be near-zero friction.
- **Stateless backend architecture** — moving from stateful scripts to idempotent, resumable pipelines.
- **One-click Google AI Studio + Firestore setup** — a single setup script that handles everything.
- **Content quality & retention** — making AI-generated reels more accurate, concise, and pedagogically sound.
- **Spaced Repetition Engine (SM-2)** — implementing adaptive review scheduling in the flashcard module.
- **Offline mode** — caching reels and quizzes locally with Hive/Isar so the app works without internet.

Check [open issues](https://github.com/soumen888/Lumina/issues) to see what's actively being worked on.

---

## 🚀 How to Contribute

### 1. Fork & Clone

```bash
# Fork the repository via the GitHub UI, then:
git clone https://github.com/YOUR_USERNAME/Lumina.git
cd Lumina
```

### 2. Set Up Your Environment

**Flutter App:**
```bash
cd lumina
flutter pub get
```
Configure Firebase by running `flutterfire configure` and binding your own Firebase project, or copy the example credentials:
```bash
cp serviceAccountKey.example.json serviceAccountKey.json
```

**Python Pipeline:**
```bash
cd scripts
python3 -m venv venv
source venv/bin/activate   # Windows: venv\Scripts\activate
pip install google-generativeai firebase-admin PyPDF2 python-dotenv
cp ../.env.example ../.env
# Add your GEMINI_API_KEY to .env
```

### 3. Create a Branch

Use a descriptive branch name:
```bash
git checkout -b feature/spaced-repetition-engine
git checkout -b fix/reel-scroll-performance
git checkout -b docs/improve-setup-guide
```

### 4. Make Your Changes

- Keep changes focused. One PR = one concern.
- For Flutter code, run `flutter analyze` before committing.
- For Python, follow PEP 8 style.
- Add comments for non-obvious logic.

### 5. Commit

Write clear commit messages:
```
feat: add SM-2 spaced repetition scheduling to flashcard engine
fix: resolve PageView scroll jitter on low-end Android devices
docs: add one-click setup instructions to CONTRIBUTING.md
```

Use prefixes: `feat:`, `fix:`, `docs:`, `refactor:`, `test:`, `chore:`

### 6. Open a Pull Request

Push your branch and open a PR against `main`:
```bash
git push origin your-branch-name
```

- Fill in the PR template.
- Link any related issues with `Closes #issue_number`.
- Add screenshots or screen recordings for UI changes.

---

## 🗂 Codebase Map — Where to Start

| If you want to... | Look here |
| :--- | :--- |
| Change the reel feed UI | `lumina/lib/learn_screen.dart` |
| Modify the quiz engine | `lumina/lib/ai_quiz_screen.dart` |
| Update the 3D flashcard | `lumina/lib/flashcard_screen.dart` |
| Change app theme / colors | `lumina/lib/theme.dart` |
| Improve Firestore data fetching | `lumina/lib/data/firestore_service.dart` |
| Improve AI reel extraction | `scripts/generate_reels.py` |
| Improve MCQ generation | `scripts/generate_mcqs.py` |
| Fix database utilities | `scripts/utils/` |
| View UI design prototypes | `UI/` (HTML + Tailwind) |
| Review data schemas | `data/sample_reels.json` |

---

## ❓ Questions?

Open a [GitHub Issue](https://github.com/soumen888/Lumina/issues/new/choose) — whether it's a bug, a feature idea, a question about the codebase, or just a thought. All questions are welcome.

---

## 📜 License

By contributing, you agree that your contributions will be licensed under the same [Custom Non-Commercial License](LICENSE) as this project. This means your work can be studied, forked, and built upon for personal and educational use — but not commercialized without explicit written permission.
