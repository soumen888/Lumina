# Changelog

All notable changes to Lumina are documented here.
Format follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

---

## [Unreleased]

### Planned
- Spaced Repetition Engine (SM-2 Algorithm) for flashcard scheduling
- Offline mode with Hive/Isar local cache
- Cloud Function migration for the Python pipeline
- Multi-model LLM fallback (Gemini Flash → Gemma → Claude)
- One-click Google AI Studio + Firestore setup script

---

## [1.0.0] — 2026-07-24 — Public Open Source Release

### Added
- **Open Source Release** — Repository made public under Custom Non-Commercial License
- `CONTRIBUTING.md` — Full contributor guide with setup instructions and codebase map
- `CODE_OF_CONDUCT.md` — Contributor Covenant code of conduct
- `SECURITY.md` — Credential leak protocol and vulnerability reporting process
- `CHANGELOG.md` — This file
- `.github/ISSUE_TEMPLATE/bug_report.md` — Structured bug report template
- `.github/ISSUE_TEMPLATE/feature_request.md` — Feature request template
- `.github/pull_request_template.md` — PR review checklist
- `.github/CODEOWNERS` — Automated PR review assignment to maintainer
- `.github/workflows/flutter_ci.yml` — Automated Flutter analyze + test on every PR
- Root `.gitignore` — Excludes Python venvs, raw PDFs, generated data, and secrets
- `UI/README.md` — Explanation of the HTML/Tailwind UI prototype suite
- Community badges (`PRs Welcome`, `Issues`) added to `readme.md`

### Changed
- `readme.md` — Added simple project pitch, Contributing section, updated directory hierarchy to match actual files
- `scripts/` — Refactored from book-specific scripts to generalized pipeline: `generate_reels.py`, `generate_mcqs.py`, `upload_reels.py`, `upload_mcqs.py`, `Extract.py`
- `scripts/config.yaml` — Centralized configuration for the entire pipeline (subject, PDF path, model, Firestore collections, chunking)
- `data/sample_reels.json` — Expanded to 3 reels across different concepts for offline Flutter testing

### Fixed
- `lumina/.gitignore` — Added `google-services.json` and `google-services.json` exclusions

---

## [0.1.0] — Initial Private Development Build

### Added
- Flutter Android app with vertical snap-scrolling Reel feed (`learn_screen.dart`)
- Interactive MCQ assessment engine (`ai_quiz_screen.dart`, `quiz_hub_screen.dart`)
- 3D flip-card active recall module (`flashcard_screen.dart`)
- Bookmarks and saved concepts manager (`saved_screen.dart`)
- Progress and analytics dashboard (`progress_screen.dart`)
- "Obsidian Scholar" dark glassmorphic design system (`theme.dart`)
- On-device TTS narration via `flutter_tts` — zero cloud bandwidth
- Python AI extraction pipeline using Google Gemini API
- Firebase Firestore real-time data streaming
- HTML/Tailwind CSS UI prototypes (`UI/` directory)
- Database maintenance utilities (`scripts/utils/`)
