# npm/pnpm/npx auth via 1Password.
#
# Sourced from BOTH .zshenv (so non-interactive shells — scripts, tools, agents —
# get it) and .aliases (interactive). The guard below makes a second source a
# no-op, so order doesn't matter.
#
# How it works: ~/.npmrc uses `_authToken=${NPM_TOKEN}`. Registry-touching npm
# subcommands resolve NPM_TOKEN once via `op read`, cache it for the shell session
# (and optionally on disk), then run bare npm/pnpm/npx. Local-only commands
# (`npm run dev`, etc.) never touch 1Password.
#
# Enable 1Password app integration (Settings → Developer) so the first `op read`
# uses your unlocked app session instead of prompting every command.
[[ -n "${_NPM_OP_WRAPPER_LOADED:-}" ]] && return 0
_NPM_OP_WRAPPER_LOADED=1

# Override these if your paths or cache policy differ.
export NPM_OP_ENV_FILE="${NPM_OP_ENV_FILE:-${XDG_CONFIG_HOME:-$HOME/.config}/npm/1password.env}"
export NPM_OP_CACHE_FILE="${NPM_OP_CACHE_FILE:-${XDG_CACHE_HOME:-$HOME/.cache}/npm/op-token}"
# Seconds to reuse the on-disk token cache (default 8h). Set to 0 to disable.
export NPM_OP_CACHE_TTL="${NPM_OP_CACHE_TTL:-28800}"

_npm_op_saved_refs=()

# op read/run resolve every op:// reference in the shell environment. Temporarily
# unset unrelated references so npm auth is not blocked by stale vault paths.
_npm_op_strip_op_refs() {
  _npm_op_saved_refs=()
  local var val
  for var in ${(k)parameters}; do
    [[ ${parameters[$var]} == *export* ]] || continue
    val="${(P)var}"
    if [[ -n "$val" && "$val" == op://* ]]; then
      _npm_op_saved_refs+=("$var=$val")
      unset "$var"
    fi
  done
}

_npm_op_restore_op_refs() {
  local entry
  for entry in "${_npm_op_saved_refs[@]}"; do
    export "$entry"
  done
  _npm_op_saved_refs=()
}

_npm_op_token_ref() {
  local line
  line="$(grep '^NPM_TOKEN=op://' "$NPM_OP_ENV_FILE" 2>/dev/null | head -1)" || return 1
  print -r -- "${line#NPM_TOKEN=}"
}

_npm_op_cache_fresh() {
  [[ -n "$NPM_OP_CACHE_TTL" && "$NPM_OP_CACHE_TTL" -gt 0 ]] || return 1
  [[ -f "$NPM_OP_CACHE_FILE" ]] || return 1
  local age=$(( $(date +%s) - $(stat -f %m "$NPM_OP_CACHE_FILE" 2>/dev/null || echo 0) ))
  (( age >= 0 && age < NPM_OP_CACHE_TTL ))
}

_npm_op_load_cached_token() {
  _npm_op_cache_fresh || return 1
  NPM_TOKEN="$(<"$NPM_OP_CACHE_FILE")"
  [[ -n "$NPM_TOKEN" && "$NPM_TOKEN" != op://* ]] || return 1
  export NPM_TOKEN
}

_npm_op_save_cached_token() {
  [[ -n "$NPM_OP_CACHE_TTL" && "$NPM_OP_CACHE_TTL" -gt 0 ]] || return 0
  local cache_dir="${NPM_OP_CACHE_FILE:h}"
  [[ -d "$cache_dir" ]] || mkdir -p "$cache_dir"
  print -r -- "$NPM_TOKEN" >"$NPM_OP_CACHE_FILE"
  chmod 600 "$NPM_OP_CACHE_FILE"
}

# Resolve NPM_TOKEN once per session (or from disk cache). Subsequent npm calls
# are plain subprocesses — no repeated op prompts.
_npm_op_ensure_token() {
  if [[ -n "${NPM_TOKEN:-}" && "${NPM_TOKEN}" != op://* ]]; then
    return 0
  fi

  if _npm_op_load_cached_token; then
    return 0
  fi

  if [[ ! -f "$NPM_OP_ENV_FILE" ]]; then
    print -u2 "Missing $NPM_OP_ENV_FILE. Create it with NPM_TOKEN=op://Vault/item/field or set NPM_TOKEN."
    return 1
  fi

  if ! command -v op >/dev/null 2>&1; then
    print -u2 "1Password CLI (op) is required to inject NPM_TOKEN for npm auth."
    return 1
  fi

  local ref
  ref="$(_npm_op_token_ref)" || {
    print -u2 "Expected NPM_TOKEN=op://... in $NPM_OP_ENV_FILE."
    return 1
  }

  _npm_op_strip_op_refs
  NPM_TOKEN="$(op read "$ref")" || {
    local ret=$?
    _npm_op_restore_op_refs
    return $ret
  }
  _npm_op_restore_op_refs

  export NPM_TOKEN
  _npm_op_save_cached_token
}

_npm_op_run() {
  _npm_op_ensure_token || return 1
  command "$@"
}

# Drop cached token (memory + disk). Next registry npm call re-reads from 1Password.
npm-op-clear() {
  unset NPM_TOKEN
  [[ -f "$NPM_OP_CACHE_FILE" ]] && command rm -f "$NPM_OP_CACHE_FILE"
}

_npm_needs_auth() {
  case "$1" in
    add|access|audit|ci|dist-tag|deprecate|i|info|install|org|outdated|owner|ping|publish|search|team|token|unpublish|update|view|whoami)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

_pnpm_needs_auth() {
  case "$1" in
    add|audit|ci|dlx|i|import|info|install|link|login|outdated|publish|remove|search|setup|store|unlink|update|up|view|whoami)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

npm() {
  if _npm_needs_auth "${1:-}"; then
    _npm_op_run npm "$@"
    return
  fi

  command npm "$@"
}

npx() {
  # npx commonly resolves packages from the registry, so keep token injection on.
  _npm_op_run npx "$@"
}

pnpm() {
  if _pnpm_needs_auth "${1:-}"; then
    _npm_op_run pnpm "$@"
    return
  fi

  command pnpm "$@"
}
