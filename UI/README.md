# UI Prototypes — Obsidian Scholar Design System

This folder contains the **HTML5 + Tailwind CSS prototypes** that the Lumina Flutter app was designed from.

These are **not production code**. They are design references — open any `code.html` file directly in your browser to preview the UI without installing Flutter or any dependencies.

---

## 📂 Folder Structure

```
UI/
├── Learn/
│   ├── code.html     # Vertical snap-scroll Reel feed prototype
│   ├── DESIGN.md     # Design token documentation (colors, typography, glassmorphism)
│   └── screen.png    # Screenshot preview
├── Quiz/
│   ├── code.html     # MCQ Quiz & Assessment Hub prototype
│   ├── AI/           # AI Quiz variant prototype
│   ├── MCQ/          # MCQ variant prototype
│   ├── DESIGN.md
│   └── screen.png
├── Progress/
│   ├── code.html     # User mastery analytics dashboard prototype
│   ├── DESIGN.md
│   └── screen.png
└── Saved/
    ├── code.html     # Bookmarked reels & revision hub prototype
    ├── DESIGN.md
    └── screen.png
```

---

## 🎨 Design System — Obsidian Scholar

The entire Flutter app follows these design tokens, defined in [`lumina/lib/theme.dart`](../lumina/lib/theme.dart):

| Token | Value | Usage |
| :--- | :--- | :--- |
| Background | `#0D0E15` | Deep Obsidian — app background |
| Primary | `#6366F1` | Electric Indigo — CTAs, active states |
| Secondary | `#06B6D4` | Neon Cyan — highlights, badges |
| Surface | `rgba(255,255,255,0.05)` | Glassmorphic card backgrounds |
| Headline Font | Sora | Titles, concept headers |
| Body Font | Inter | Content, labels, interactive elements |
| Backdrop Blur | `sigmaX: 10, sigmaY: 10` | Glassmorphic blur effect |

---

## 💡 How to Use These Prototypes

1. Open any `code.html` file in your web browser (Chrome recommended for backdrop-filter support).
2. Use the `DESIGN.md` in each folder for detailed component specs.
3. Compare with the Flutter implementation in `lumina/lib/` to understand how the design translated to Dart.

---

> These prototypes are part of the open-source Lumina repository. Feel free to suggest UI improvements by opening a [GitHub Issue](https://github.com/soumen888/Lumina/issues/new/choose).
