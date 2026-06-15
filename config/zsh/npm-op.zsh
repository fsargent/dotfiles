# npm/pnpm/npx auth via 1Password.
#
# Sourced from BOTH .zshenv (so non-interactive shells — scripts, tools, agents —
# get it) and .aliases (interactive). The guard below makes a second source a
# no-op, so order doesn't matter.
#
# How it works: ~/.npmrc uses `_authToken=${NPM_TOKEN}`. Registry-touching npm
# subcommands are routed through `op run --env-file $NPM_OP_ENV_FILE`, which
# populates NPM_TOKEN from 1Password. Local-only commands (`npm run dev`, etc.)
# run bare so they never prompt 1Password.
[[ -n "${_NPM_OP_WRAPPER_LOADED:-}" ]] && return 0
_NPM_OP_WRAPPER_LOADED=1

# Override NPM_OP_ENV_FILE if the env file lives elsewhere.
export NPM_OP_ENV_FILE="${NPM_OP_ENV_FILE:-${XDG_CONFIG_HOME:-$HOME/.config}/npm/1password.env}"

_npm_op_saved_refs=()

# op run resolves every op:// reference in the shell environment, not only the
# env file. Temporarily unset unrelated references (e.g. GITHUB_PRIVATE_TOKEN)
# so npm auth is not blocked by a stale vault path elsewhere in dotfiles.
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

_npm_op_run() {
  if [[ -n "${NPM_TOKEN:-}" && "${NPM_TOKEN}" != op://* ]]; then
    command "$@"
    return
  fi

  if [[ ! -f "$NPM_OP_ENV_FILE" ]]; then
    print -u2 "Missing $NPM_OP_ENV_FILE. Create it with NPM_TOKEN=op://Vault/item/field or set NPM_TOKEN."
    return 1
  fi

  if ! command -v op >/dev/null 2>&1; then
    print -u2 "1Password CLI (op) is required to inject NPM_TOKEN for npm auth."
    return 1
  fi

  _npm_op_strip_op_refs
  op run --env-file "$NPM_OP_ENV_FILE" -- "$@"
  local ret=$?
  _npm_op_restore_op_refs
  return $ret
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
