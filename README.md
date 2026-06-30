# 📦 install-commandcode-termux

<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="https://capsule-render.vercel.app/api?type=waving&color=0:6a11cb,100:2575fc&height=200&section=header&text=install-commandcode-termux&fontSize=36&fontColor=fff&animation=fadeIn&fontAlignY=38&desc=One%E2%80%91click%20installer%20for%20command-code%20on%20Termux&descAlignY=55">
    <img alt="banner" src="https://capsule-render.vercel.app/api?type=waving&color=0:6a11cb,100:2575fc&height=200&section=header&text=install-commandcode-termux&fontSize=36&fontColor=fff&animation=fadeIn&fontAlignY=38&desc=One%E2%80%91click%20installer%20for%20command-code%20on%20Termux&descAlignY=55">
  </picture>
</p>

<p align="center">
  <a href="https://www.npmjs.com/package/command-code"><img src="https://img.shields.io/badge/npm-command--code-CB3837?style=flat-square&logo=npm&logoColor=white" alt="npm"></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-blue.svg?style=flat-square" alt="MIT License"></a>
  <img src="https://img.shields.io/badge/bash-≥4.0-4EAA25?style=flat-square&logo=gnubash&logoColor=white" alt="bash">
  <img src="https://img.shields.io/badge/Node.js-≥14-339933?style=flat-square&logo=nodedotjs&logoColor=white" alt="Node.js">
  <img src="https://img.shields.io/badge/Android-Termux-3DDC84?style=flat-square&logo=android&logoColor=white" alt="Termux">
  <img src="https://img.shields.io/github/last-commit/PwnedBytes0x1/install-commandcode-termux?style=flat-square&color=blueviolet" alt="last commit">
</p>

---

## ✨ Features

| Icon | Feature | Description |
|:----:|---------|-------------|
| 🤖 | **Full automation** | Installs Node.js if missing (`pkg`, `apt`, `brew`, or `yum`) |
| 📁 | **Custom npm prefix** | Never overwrites system `/usr/bin/cmd` — uses `~/my-npm-global` |
| 🧠 | **Shell detection** | Auto‑updates `.bashrc` or `.zshrc` with the correct `PATH` |
| 🔄 | **Version check** | Compares your installer version with the latest release |
| ⬆️ | **Self‑update** | Downloads the newest version of the installer itself |
| 🗑️ | **Upgrade / Uninstall** | Keep your `command-code` installation tidy |
| 🎨 | **Colour output & logging** | Clear feedback with log file (`~/command-code-install.log`) |
| 🐧 | **Works beyond Termux** | Supports `apt`, `brew`, `yum` as fallback package managers |

---

## 📋 Prerequisites

- 🌐 A working internet connection
- 🐚 `bash` (or `zsh`)
- 📡 `curl` **or** `wget` (for self‑update and version check)
- 📱 On Termux: **storage permission** is not required, but you may want to run `termux-setup-storage` if you need external storage access

---

## 🚀 Quick Installation

Run this one‑liner to download and execute the installer:

<details open>
<summary><b>⬇️ Using curl</b></summary>

```bash
curl -fsSL https://raw.githubusercontent.com/PwnedBytes0x1/install-commandcode-termux/main/install-commandcode-termux.sh -o install.sh && chmod +x install.sh && ./install.sh --install
```

</details>

<details>
<summary><b>⬇️ Using wget</b></summary>

```bash
wget -q https://raw.githubusercontent.com/PwnedBytes0x1/install-commandcode-termux/main/install-commandcode-termux.sh -O install.sh && chmod +x install.sh && ./install.sh --install
```

</details>

After installation, you can run `cmd` immediately. 🎉

---

## 🛠️ Usage

```
Usage: ./install-commandcode-termux.sh [OPTIONS]
```

### Available Options

| Option | Description |
|--------|-------------|
| `--install` | Install command-code globally **(default)** |
| `--upgrade` | Update command-code to the latest version |
| `--uninstall` | Remove command-code and clean up PATH entries |
| `--prefix DIR` | Use a custom npm prefix (default: `~/my-npm-global`) |
| `--force` | Overwrite conflicts without asking |
| `--check-update` | Check if a newer version of the installer exists |
| `--update-script` | Download the latest installer script from GitHub |
| `--help` | Show this help message |

### Environment Variables

| Variable | Effect |
|----------|--------|
| `CMD_CODE_PREFIX` | Override default npm prefix (same as `--prefix`) |

### Example Commands

```bash
# Install with default settings
./install-commandcode-termux.sh

# Install with a custom prefix
./install-commandcode-termux.sh --prefix ~/my-tools

# Upgrade command-code to the latest version
./install-commandcode-termux.sh --upgrade

# Force reinstall even if already present
./install-commandcode-termux.sh --install --force

# Uninstall everything (package + PATH entries)
./install-commandcode-termux.sh --uninstall

# Check if your installer is up‑to‑date
./install-commandcode-termux.sh --check-update

# Update the installer script itself
./install-commandcode-termux.sh --update-script
```

---

## ⚙️ Installation Walkthrough

| Step | Description |
|:----:|-------------|
| **1** | 🔍 **Node.js check** — verifies Node.js ≥14; installs it if missing via your system's package manager |
| **2** | 📂 **npm prefix** — sets a custom global directory (`~/my-npm-global` or your chosen path) |
| **3** | 🐚 **Shell configuration** — detects your shell and adds the bin directory to `PATH` in the appropriate rc file |
| **4** | 📦 **Global installation** — runs `npm install -g command-code` |
| **5** | ✅ **Verification** — checks that `cmd` is available and prints its version |

---

## 🗑️ Uninstall

```bash
./install-commandcode-termux.sh --uninstall
```

This will:

| Action | Description |
|--------|-------------|
| 🗑️ | Uninstall the global npm package |
| 🧹 | Remove the PATH entry from your shell's rc file |
| 📁 | Delete the custom npm prefix directory if empty |

> **💡 Tip:** Use `--force` to remove the prefix directory even if it's not empty.

---

## 🔄 Version Checking & Self‑Update

The installer has its own version number (the `VERSION` variable) and compares it with a remote `version.txt` file in the repository.

| Command | What It Does |
|---------|--------------|
| `--check-update` | Checks if a newer installer script exists |
| `--update-script` | Downloads the latest version from GitHub and replaces the current script |

> **💡 Tip:** Always keep your installer up‑to‑date to benefit from bug fixes and new features.

---

## 📝 Logging

All output is logged to `~/command-code-install.log` with timestamps. The terminal output uses colour‑coded prefixes:

| Prefix | Meaning |
|:------:|---------|
| `[ INF ]` | ℹ️ Information |
| `[ WRN ]` | ⚠️ Warning |
| `[ ERR ]` | ❌ Error |
| `[ OK ]` | ✅ Success |

---

## 🐛 Troubleshooting

| Issue | Solution |
|-------|----------|
| `npm` not found after installation | Run `source ~/.bashrc` or restart Termux |
| `cmd` still points to system binary | The custom prefix takes priority; check `echo $PATH` — `~/my-npm-global/bin` should come first |
| Self‑update fails | Ensure `curl` or `wget` is installed and you have internet access |
| Node.js installation fails on Termux | Try `pkg upgrade` first, then re‑run the installer |
| Permission errors | On non‑Termux systems, you may need `sudo`; the script already uses `sudo` for `apt`/`yum` |
| `command-code` not found after install | Verify: `ls ~/my-npm-global/bin/cmd` should exist. If not, run with `--force` |
| Uninstall doesn't remove prefix dir | Directory is only removed if empty. Use `--force` to delete even if non‑empty |
| Version check says "Could not fetch remote version" | Check your internet connection and that `version.txt` exists in the repo |
| Script updates but version stays the same | Make sure the `VERSION` variable in the script is incremented when you push a new release |
| `pkg` not found (not in Termux) | The script falls back to `apt`, `brew`, or `yum`. If none available, install Node.js manually |

---

## 🤝 Contributing

Found a bug or want to improve the script? Feel free to:

- 🐛 [Open an issue](https://github.com/PwnedBytes0x1/install-commandcode-termux/issues)
- 🔀 Submit a pull request

All contributions are welcome! ✨

---

## 📄 License

This project is licensed under the **MIT License**. See the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgements

- 🧰 [command-code](https://www.npmjs.com/package/command-code) — the amazing tool you're installing
- 📱 [Termux](https://termux.com/) community — for turning Android into a development platform

---

<p align="center">
  <sub>Made with ❤️ for the Termux community</sub>
  <br>
  <a href="https://github.com/PwnedBytes0x1/install-commandcode-termux">
    <img src="https://img.shields.io/github/stars/PwnedBytes0x1/install-commandcode-termux?style=social" alt="stars">
  </a>
</p>
