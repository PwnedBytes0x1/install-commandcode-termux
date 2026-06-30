#!/usr/bin/env bash
# ============================================================================
# command-code installer – full-featured with version check
# Repository: https://github.com/PwnedBytes0x1/install-commandcode-termux
# Usage: ./install-commandcode-termux.sh [OPTIONS]
# ============================================================================

set -euo pipefail

# ----------------------------- Configuration --------------------------------
SCRIPT_NAME="$(basename "$0")"
VERSION="1.1.0"
SCRIPT_URL="https://raw.githubusercontent.com/PwnedBytes0x1/install-commandcode-termux/main/install-commandcode-termux.sh"
VERSION_URL="https://raw.githubusercontent.com/PwnedBytes0x1/install-commandcode-termux/main/version.txt"
DEFAULT_PREFIX="$HOME/my-npm-global"
NODE_MIN_VERSION=14
LOG_FILE="$HOME/command-code-install.log"
PKG_MGR=""

# ----------------------------- Colours & Prefixes ---------------------------
CLR_RED='\033[0;31m'
CLR_GREEN='\033[0;32m'
CLR_YELLOW='\033[1;33m'
CLR_BLUE='\033[0;34m'
CLR_CYAN='\033[0;36m'
CLR_RESET='\033[0m'

print_inf() { echo -e "${CLR_GREEN}[INF]${CLR_RESET} $*"; }
print_wrn() { echo -e "${CLR_YELLOW}[WRN]${CLR_RESET} $*" >&2; }
print_err() { echo -e "${CLR_RED}[ERR]${CLR_RESET} $*" >&2; }
print_ok()  { echo -e "${CLR_CYAN}[OK]${CLR_RESET} $*"; }

# Log function – writes to log file and stderr
log() {
    local level="$1"; shift
    local msg="$*"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$level] $msg" >> "$LOG_FILE"
    case "$level" in
        INF) print_inf "$msg" ;;
        WRN) print_wrn "$msg" ;;
        ERR) print_err "$msg" ;;
        OK)  print_ok "$msg" ;;
        *)   echo "$msg" >&2 ;;
    esac
}

# ----------------------------- Help / Usage ---------------------------------
usage() {
    cat <<EOF
Usage: $SCRIPT_NAME [OPTIONS]

Options:
  --install               Install command-code (default)
  --upgrade               Update command-code to latest version
  --uninstall             Remove command-code and clean up
  --prefix DIR            Set custom npm prefix (default: $DEFAULT_PREFIX)
  --force                 Overwrite conflicts without asking
  --check-update          Check if a newer version of this script exists
  --update-script         Download the latest version of this script
  --help                  Show this help message

Environment variables:
  CMD_CODE_PREFIX         Override default prefix (same as --prefix)

Examples:
  $SCRIPT_NAME --install --prefix ~/my-npm
  $SCRIPT_NAME --upgrade --force
  $SCRIPT_NAME --uninstall
  $SCRIPT_NAME --check-update
  $SCRIPT_NAME --update-script
EOF
}

# ----------------------------- Argument parsing -----------------------------
ACTION="install"
FORCE=false
CHECK_UPDATE=false
UPDATE_SCRIPT=false
CUSTOM_PREFIX="${CMD_CODE_PREFIX:-}"

while [[ $# -gt 0 ]]; do
    case "$1" in
        --install)   ACTION="install" ;;
        --upgrade)   ACTION="upgrade" ;;
        --uninstall) ACTION="uninstall" ;;
        --prefix)    CUSTOM_PREFIX="$2"; shift ;;
        --force)     FORCE=true ;;
        --check-update) CHECK_UPDATE=true ;;
        --update-script) UPDATE_SCRIPT=true ;;
        --help)      usage; exit 0 ;;
        *)           log ERR "Unknown option: $1"; usage; exit 1 ;;
    esac
    shift
done

PREFIX="${CUSTOM_PREFIX:-$DEFAULT_PREFIX}"
BIN_DIR="$PREFIX/bin"

# ----------------------------- Version check function -----------------------
check_update() {
    log_inf "Checking for updates..."
    local remote_version
    if command -v curl &>/dev/null; then
        remote_version=$(curl -fsSL "$VERSION_URL" 2>/dev/null || echo "")
    elif command -v wget &>/dev/null; then
        remote_version=$(wget -qO- "$VERSION_URL" 2>/dev/null || echo "")
    else
        log_err "Neither curl nor wget found. Cannot check for updates."
        return 1
    fi

    if [[ -z "$remote_version" ]]; then
        log_wrn "Could not fetch remote version. Please check your internet connection."
        return 1
    fi

    # Remove any whitespace
    remote_version=$(echo "$remote_version" | tr -d '[:space:]')
    local current_version="$VERSION"

    if [[ "$remote_version" == "$current_version" ]]; then
        log_ok "You are using the latest version ($current_version)."
        return 0
    else
        log_wrn "New version available: $remote_version (current: $current_version)"
        log_inf "Run '$SCRIPT_NAME --update-script' to upgrade."
        return 1
    fi
}

# ----------------------------- Self-update logic ----------------------------
do_update_script() {
    log_inf "Updating script from $SCRIPT_URL"
    if command -v curl &>/dev/null; then
        curl -fsSL "$SCRIPT_URL" -o "$0.tmp" || { log_err "Download failed"; exit 1; }
    elif command -v wget &>/dev/null; then
        wget -q "$SCRIPT_URL" -O "$0.tmp" || { log_err "Download failed"; exit 1; }
    else
        log_err "Neither curl nor wget found. Cannot update."
        exit 1
    fi
    chmod +x "$0.tmp"
    mv "$0.tmp" "$0"
    log_ok "Script updated successfully. Please re-run with your desired action."
    exit 0
}

# ----------------------------- Utility functions ----------------------------
log_inf() { log INF "$*"; }
log_wrn() { log WRN "$*"; }
log_err() { log ERR "$*"; }
log_ok()  { log OK "$*"; }

command_exists() { command -v "$1" &>/dev/null; }

detect_package_manager() {
    if command_exists pkg; then
        echo "pkg"
    elif command_exists apt; then
        echo "apt"
    elif command_exists brew; then
        echo "brew"
    elif command_exists yum; then
        echo "yum"
    else
        echo ""
    fi
}

install_node_with_pkg() {
    local mgr="$1"
    log_inf "Installing Node.js using $mgr"
    case "$mgr" in
        pkg) pkg update -y && pkg install nodejs -y ;;
        apt) sudo apt update && sudo apt install -y nodejs npm ;;
        brew) brew install node ;;
        yum) sudo yum install -y nodejs npm ;;
        *) return 1 ;;
    esac
}

check_node_version() {
    if ! command_exists node; then
        return 1
    fi
    local ver
    ver=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
    if [[ "$ver" -lt "$NODE_MIN_VERSION" ]]; then
        log_err "Node.js version $ver is too old (min $NODE_MIN_VERSION). Please upgrade."
        return 1
    fi
    log_ok "Node.js version $(node -v) is compatible."
    return 0
}

ensure_node() {
    if check_node_version; then
        return 0
    fi
    log_wrn "Node.js not found or too old. Attempting to install..."
    if [[ -z "$PKG_MGR" ]]; then
        PKG_MGR=$(detect_package_manager)
    fi
    if [[ -z "$PKG_MGR" ]]; then
        log_err "No supported package manager found. Please install Node.js manually."
        return 1
    fi
    install_node_with_pkg "$PKG_MGR" || { log_err "Node.js installation failed"; return 1; }
    if ! check_node_version; then
        log_err "Node.js installed but version check failed."
        return 1
    fi
    log_ok "Node.js installed successfully."
}

setup_npm_prefix() {
    mkdir -p "$PREFIX" || { log_err "Cannot create $PREFIX"; return 1; }
    npm config set prefix "$PREFIX" || { log_err "Failed to set npm prefix"; return 1; }
    log_ok "npm prefix set to $PREFIX"
}

detect_rc_file() {
    local shell_name
    shell_name=$(basename "$SHELL" 2>/dev/null || echo "")
    if [[ "$shell_name" == "zsh" ]]; then
        echo "$HOME/.zshrc"
    elif [[ "$shell_name" == "bash" ]]; then
        echo "$HOME/.bashrc"
    else
        [[ -f "$HOME/.bashrc" ]] && echo "$HOME/.bashrc" || echo "$HOME/.profile"
    fi
}

update_rc_file() {
    local rc_file
    rc_file=$(detect_rc_file)
    local path_export="export PATH=\"$BIN_DIR:\$PATH\""
    if [[ -f "$rc_file" ]]; then
        if grep -qF "$path_export" "$rc_file"; then
            log_inf "PATH entry already exists in $rc_file"
        else
            echo "$path_export" >> "$rc_file"
            log_ok "Added PATH entry to $rc_file"
        fi
    else
        echo "$path_export" > "$rc_file"
        log_ok "Created $rc_file and added PATH entry"
    fi
}

update_path_now() {
    export PATH="$BIN_DIR:$PATH"
}

npm_install_global() {
    local pkg="$1"
    log_inf "Installing $pkg globally..."
    npm install -g "$pkg" || { log_err "npm install failed"; return 1; }
    log_ok "$pkg installed."
}

npm_update_global() {
    local pkg="$1"
    log_inf "Updating $pkg globally..."
    npm update -g "$pkg" || { log_err "npm update failed"; return 1; }
    log_ok "$pkg updated."
}

uninstall_package() {
    local pkg="command-code"
    if command_exists npm; then
        log_inf "Removing $pkg globally..."
        npm uninstall -g "$pkg" || log_wrn "npm uninstall returned error (maybe already removed?)"
    else
        log_wrn "npm not found, skipping uninstall."
    fi

    # Remove PATH entry from rc file
    local rc_file
    rc_file=$(detect_rc_file)
    if [[ -f "$rc_file" ]]; then
        local temp_file
        temp_file=$(mktemp)
        grep -v "export PATH=\"$BIN_DIR:\$PATH\"" "$rc_file" > "$temp_file" || true
        mv "$temp_file" "$rc_file"
        log_ok "Removed PATH entry from $rc_file"
    fi

    # Optionally remove the prefix directory if empty and user confirms
    if [[ -d "$PREFIX" ]]; then
        if [[ "$FORCE" == true ]] || [[ -z "$(ls -A "$PREFIX" 2>/dev/null)" ]]; then
            rm -rf "$PREFIX"
            log_ok "Removed $PREFIX"
        else
            log_wrn "$PREFIX is not empty; skipping removal."
        fi
    fi
    log_ok "Uninstall completed."
}

check_command_code_installed() {
    if command_exists cmd; then
        return 0
    elif [[ -x "$BIN_DIR/cmd" ]]; then
        export PATH="$BIN_DIR:$PATH"
        if command_exists cmd; then
            return 0
        fi
    fi
    return 1
}

get_installed_version() {
    if command_exists cmd; then
        cmd --version 2>/dev/null || echo "unknown"
    else
        echo "not installed"
    fi
}

# ----------------------------- Main actions --------------------------------
do_install() {
    log_inf "Starting installation..."
    ensure_node || exit 1
    setup_npm_prefix || exit 1
    update_rc_file
    update_path_now
    npm_install_global "command-code" || exit 1
    if check_command_code_installed; then
        local ver
        ver=$(get_installed_version)
        log_ok "Installation successful! Version: $ver"
        log_inf "You can now run 'cmd' in this terminal."
        log_inf "For new terminals, restart or source your rc file."
    else
        log_err "Installation completed but 'cmd' not found. Check PATH manually."
        exit 1
    fi
}

do_upgrade() {
    log_inf "Upgrading command-code..."
    ensure_node || exit 1
    setup_npm_prefix || exit 1
    update_rc_file
    update_path_now
    npm_update_global "command-code" || exit 1
    local ver
    ver=$(get_installed_version)
    log_ok "Upgrade completed. Version: $ver"
}

do_uninstall() {
    log_inf "Uninstalling command-code..."
    uninstall_package
}

# ----------------------------- Script entry point ---------------------------
main() {
    log_inf "Starting $SCRIPT_NAME (PID $$) at $(date)"
    log_inf "Logging to $LOG_FILE"

    # If --check-update was given, do that and exit
    if [[ "$CHECK_UPDATE" == true ]]; then
        check_update || exit $?
    fi

    # If --update-script was given, update and exit
    if [[ "$UPDATE_SCRIPT" == true ]]; then
        do_update_script
        # (exits inside the function)
    fi

    case "$ACTION" in
        install)
            if check_command_code_installed && [[ "$FORCE" != true ]]; then
                local ver
                ver=$(get_installed_version)
                log_wrn "command-code is already installed (version $ver). Use --force to reinstall."
                exit 0
            fi
            do_install
            ;;
        upgrade)
            do_upgrade
            ;;
        uninstall)
            do_uninstall
            ;;
        *)
            log_err "Invalid action: $ACTION"
            usage
            exit 1
            ;;
    esac

    log_ok "Operation completed."
}

# Run main, with error trap
trap 'log_err "An unexpected error occurred. Check $LOG_FILE for details."' ERR
main "$@"