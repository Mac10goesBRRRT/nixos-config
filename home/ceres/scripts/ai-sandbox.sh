# OpenCode inside an outer bwrap filesystem sandbox and an inner SRT policy.
# The real home is never mounted. The selected repository is the only host
# directory that is mounted read/write (besides a separate sandbox home).
set -euo pipefail

usage() {
  cat <<'HELP'
Usage: ocbox [--shell] [--] [opencode arguments...]

Start from inside a Git repository. Only that repository is writable.
--shell  Launch an interactive Bash WITH the same SRT policy for testing.

IMPORTANT: OpenCode can modify/delete anything inside the repository.
         Do not put real secrets there; use Git diffs and backups.
HELP
}

shell_mode=0
while (( $# )); do
  case "$1" in
    --shell) shell_mode=1; shift ;;
    -h|--help) usage; exit 0 ;;
    --) shift; break ;;
    *) break ;;
  esac
done

host_home=$(realpath -e "$HOME")
current_dir=$(realpath -e "$PWD")
if ! root=$(git -C "$current_dir" rev-parse --show-toplevel 2>/dev/null); then
  echo 'ocbox: start inside a Git repository (refusing to mount arbitrary directories)' >&2
  exit 1
fi
root=$(realpath -e "$root")

# Avoid accidentally exposing the whole home, the filesystem, or an ancestor.
case "$root" in
  /|"$host_home"|"${host_home%/*}"|/home|/mnt|/run|/nix|/etc|/var)
    echo "ocbox: unsafe repository root: $root" >&2; exit 1 ;;
esac
case "$host_home/" in
  "$root/"*) echo "ocbox: repository contains your real home: $root" >&2; exit 1 ;;
esac

sandbox_home_host="${XDG_DATA_HOME:-$host_home/.local/share}/ai-sandbox/opencode/home"
mkdir -p "$sandbox_home_host/.config" "$sandbox_home_host/.local/share" \
         "$sandbox_home_host/.local/state" "$sandbox_home_host/.cache"
sandbox_home_host=$(realpath -e "$sandbox_home_host")
case "$root/" in
  "$sandbox_home_host/"*) echo 'ocbox: refusing to mount sandbox home as project' >&2; exit 1 ;;
esac
case "$sandbox_home_host/" in
  "$root/"*) echo 'ocbox: sandbox home is inside the project; move the repository' >&2; exit 1 ;;
esac

settings=${AI_SANDBOX_SRT_SETTINGS:?missing compiled SRT settings path}
[[ -r "$settings" ]] || { echo "ocbox: missing SRT settings: $settings" >&2; exit 1; }
# /nix/store to /bin/sh
shell_path=$(realpath -e "$(command -v bash)")
# Everything outside the repo is absent or mounted read-only.
args=(
  --die-with-parent --new-session
  --unshare-all --share-net
  --hostname ocbox
  --ro-bind /nix/store /nix/store
  --ro-bind-try /run/current-system /run/current-system
  --ro-bind-try /etc/profiles /etc/profiles
  --ro-bind-try /etc/static /etc/static
  --ro-bind-try /etc/ssl /etc/ssl
  --ro-bind-try /etc/resolv.conf /etc/resolv.conf
  --ro-bind-try /etc/hosts /etc/hosts
  --ro-bind-try /etc/nsswitch.conf /etc/nsswitch.conf
  --ro-bind-try /etc/passwd /etc/passwd
  --ro-bind-try /etc/group /etc/group
  --ro-bind-try /etc/localtime /etc/localtime
  --proc /proc --dev /dev --tmpfs /tmp
  --dir /home --dir /run
  --dir /bin
  --symlink "$shell_path" /bin/sh
  --bind "$sandbox_home_host" /home/ocbox
  --bind "$root" "$root"
  --chdir "$current_dir"
)

# Git metadata stays readable for diffs, but cannot be changed by the agent.
if [[ -e "$root/.git" ]]; then
  args+=(--ro-bind "$root/.git" "$root/.git")
fi
if [[ -e "$root/.envrc" ]]; then
  args+=(--ro-bind /dev/null "$root/.envrc")
fi

# Hide common secrets found within the workspace. SRT independently denies
# reading matching paths, and the outer bwrap mask also covers shell tools.
# Existing regular files only: newly created files and atypical names are NOT
# covered. Never treat project secret scanning as a complete DLP solution.
secret_count=0
while IFS= read -r -d '' secret_file; do
  args+=(--ro-bind /dev/null "$secret_file")
  secret_count=$((secret_count + 1))
done < <(find "$root" \( -name .git -o -name node_modules -o -name .direnv \) -prune -o \
  -type f \( -name '.env' -o -name '.env.*' -o -name '.envrc' \
  -o -name 'secrets.json' -o -name 'credentials.json' \
  -o -name 'credentials.toml' \) -print0)

# The SRT policy is provided read-only inside the isolated home.
mkdir -p "$sandbox_home_host/.config/ai-sandbox"
args+=(--ro-bind "$settings" /home/ocbox/.config/ai-sandbox/srt-settings.json)

# Drop the host's credentials, auth helpers, GUI sockets and host-specific XDG
# settings. Keep only a deliberately small environment; no host API keys.
# Do not pass global git config, home configuration or the Nix daemon socket.
args+=(
  --clearenv
  --setenv HOME /home/ocbox
  --setenv XDG_CONFIG_HOME /home/ocbox/.config
  --setenv XDG_DATA_HOME /home/ocbox/.local/share
  --setenv XDG_STATE_HOME /home/ocbox/.local/state
  --setenv XDG_CACHE_HOME /home/ocbox/.cache
  --setenv TMPDIR /tmp
  --setenv SSL_CERT_FILE /etc/ssl/certs/ca-certificates.crt
  --setenv USER "${USER:-ocbox}"
  --setenv LOGNAME "${LOGNAME:-ocbox}"
  --setenv LANG "${LANG:-C.UTF-8}"
  --setenv TERM "${TERM:-xterm-256color}"
  --setenv PATH "$PATH"
  --setenv OCBOX 1
)

# Important: --shell is not an escape hatch; the inner SRT still runs.
if (( shell_mode )); then
  target=$(command -v bash)
else
  target=$(command -v opencode)
fi
srt_bin=$(command -v srt)

printf 'ocbox: repo=%s (RW); git metadata=RO; secrets masked=%s; home=isolated; network=SRT allowlist\n' \
  "$root" "$secret_count" >&2

exec bwrap "${args[@]}" -- "$srt_bin" \
  --settings /home/ocbox/.config/ai-sandbox/srt-settings.json \
  -- "$target" "$@"
