# Security Policy

## Supported Versions

Lumina is currently in active development. Security patches are applied to the latest version on `main`.

| Version | Supported |
| :--- | :--- |
| Latest (`main`) | ✅ Yes |
| Older branches | ❌ No |

---

## 🔑 Credential Leak Protocol

This project uses **Google Gemini API keys** and **Firebase Service Account keys**. If you accidentally commit credentials to a public fork or branch:

### Step 1 — Revoke immediately (don't wait)

| Credential | Where to revoke |
| :--- | :--- |
| **Firebase Service Account key** | [Firebase Console](https://console.firebase.google.com) → Project Settings → Service Accounts → Revoke |
| **Gemini API key** | [Google AI Studio](https://aistudio.google.com/app/apikey) → Delete the key |

### Step 2 — Remove from Git history

```bash
# Remove the file from Git history (replace with your filename)
git filter-branch --force --index-filter \
  "git rm --cached --ignore-unmatch serviceAccountKey.json" \
  --prune-empty --tag-name-filter cat -- --all

git push origin --force --all
```

Or use [BFG Repo Cleaner](https://rtyley.github.io/bfg-repo-cleaner/) for a faster alternative.

### Step 3 — Generate new credentials

Always generate a fresh key after revoking the compromised one. Never reuse a rotated key.

---

## 🚨 Reporting a Vulnerability

If you discover a security vulnerability in Lumina (e.g., exposed credentials, insecure Firestore rules, injection risks in the Python pipeline):

1. **Do NOT open a public GitHub Issue** — that would expose the vulnerability to everyone.
2. Open a **[private vulnerability report](https://github.com/soumen888/Lumina/security/advisories/new)** via GitHub's Security Advisories feature.
3. Or email the maintainer directly via the [GitHub profile](https://github.com/soumen888).

Please include:
- A description of the vulnerability
- Steps to reproduce it
- The potential impact
- Any suggested fix (optional but appreciated)

You will receive an acknowledgment within 48 hours. All responsibly disclosed vulnerabilities will be credited in the release notes.

---

## ✅ Security Best Practices for Contributors

- **Never** commit `.env`, `serviceAccountKey.json`, `google-services.json`, or any file containing real API keys.
- Use `.env.example` and `serviceAccountKey.example.json` as templates — fill in your own credentials locally.
- Run `git status` before every commit and double-check which files are staged.
- If in doubt, add the file to `.gitignore` before touching it.
