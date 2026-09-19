#!/usr/bin/env bash

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_ROOT="$SCRIPT_DIR/.backup/snapshots"
DRY_RUN=0
ASSUME_YES=0
FORCE=0
PULL_REPO=1
LAST_SNAPSHOT_ID=""

COMPONENTS=(vim conda zsh tmux nvim ranger)

declare -A COMPONENT_FILES
COMPONENT_FILES[vim]="$SCRIPT_DIR/vim/.vimrc|$HOME/.vimrc"
COMPONENT_FILES[conda]="$SCRIPT_DIR/.condarc|$HOME/.condarc"
COMPONENT_FILES[zsh]="$SCRIPT_DIR/zsh/.zshrc|$HOME/.zshrc
$SCRIPT_DIR/zsh/starship.toml|$HOME/.config/starship.toml"
COMPONENT_FILES[tmux]="$SCRIPT_DIR/tmux/tmux.conf|$HOME/.tmux.conf"
COMPONENT_FILES[nvim]="$SCRIPT_DIR/nvim|$HOME/.config/nvim"
COMPONENT_FILES[ranger]="$SCRIPT_DIR/ranger|$HOME/.config/ranger"

usage() {
  cat <<'USAGE'
Usage:
  ./install.sh <command> [components...] [options]
  ./install.sh <component|all> [options]    # backward-compatible install

Commands:
  install    Install or re-link selected components
  update     Pull latest repository changes and apply install logic
  rollback   Restore from backups (latest by default)
  status     Show mapping and current link/file status
  list       Show supported components and available rollback versions
  help       Show this help

Components:
  all vim conda zsh tmux nvim ranger

Options:
  -n, --dry-run             Preview actions only
  -y, --yes                 Non-interactive; auto confirm
  -f, --force               Force replacement of non-managed targets
      --version <id>        Rollback snapshot id (for rollback)
      --no-pull             Skip git pull in update
  -h, --help                Show help

Examples:
  ./install.sh install all
  ./install.sh install zsh nvim --dry-run
  ./install.sh update all --yes
  ./install.sh rollback --version 20260919-120000-install
  ./install.sh status all
USAGE
}

info() { printf '[INFO] %s\n' "$*"; }
warn() { printf '[WARN] %s\n' "$*" >&2; }
error() { printf '[ERROR] %s\n' "$*" >&2; }

run() {
  if [ "$DRY_RUN" -eq 1 ]; then
    printf '[dry-run]'
    for arg in "$@"; do
      printf ' %q' "$arg"
    done
    printf '\n'
    return 0
  fi
  "$@"
}

confirm() {
  local prompt="$1"
  if [ "$ASSUME_YES" -eq 1 ]; then
    return 0
  fi
  if [ ! -t 0 ]; then
    warn "$prompt (non-interactive mode detected, use --yes to auto-confirm)"
    return 1
  fi
  read -r -p "$prompt [y/N]: " answer
  [[ "$answer" =~ ^[Yy]$ ]]
}

is_component() {
  local component="$1"
  local item
  for item in "${COMPONENTS[@]}"; do
    if [ "$item" = "$component" ]; then
      return 0
    fi
  done
  return 1
}

add_component_once() {
  local component="$1"
  local -n ref="$2"
  local item
  for item in "${ref[@]}"; do
    if [ "$item" = "$component" ]; then
      return
    fi
  done
  ref+=("$component")
}

resolve_components() {
  local -n out_ref="$1"
  shift

  local input=()
  if [ "$#" -eq 0 ]; then
    input=(all)
  else
    input=("$@")
  fi

  local token piece
  for token in "${input[@]}"; do
    IFS=',' read -r -a split_tokens <<< "$token"
    for piece in "${split_tokens[@]}"; do
      if [ -z "$piece" ]; then
        continue
      fi
      if [ "$piece" = "all" ]; then
        for token in "${COMPONENTS[@]}"; do
          add_component_once "$token" out_ref
        done
      elif is_component "$piece"; then
        add_component_once "$piece" out_ref
      else
        error "Unsupported component: $piece"
        return 1
      fi
    done
  done

  if [ "${#out_ref[@]}" -eq 0 ]; then
    error "No valid components found"
    return 1
  fi

  return 0
}

component_entries() {
  local component="$1"
  printf '%s\n' "${COMPONENT_FILES[$component]}"
}

target_status() {
  local source="$1"
  local target="$2"

  if [ -L "$target" ]; then
    local link_target
    link_target="$(readlink "$target")"
    if [ "$link_target" = "$source" ]; then
      printf 'managed-link'
    else
      printf 'symlink->%s' "$link_target"
    fi
    return
  fi

  if [ -d "$target" ]; then
    printf 'directory'
    return
  fi

  if [ -f "$target" ]; then
    printf 'file'
    return
  fi

  printf 'missing'
}

create_snapshot() {
  local operation="$1"
  local timestamp snapshot_id snapshot_dir

  timestamp="$(date '+%Y%m%d-%H%M%S')"
  snapshot_id="$timestamp-$operation"
  snapshot_dir="$BACKUP_ROOT/$snapshot_id"

  run mkdir -p "$snapshot_dir"
  if [ "$DRY_RUN" -eq 0 ]; then
    {
      echo "id=$snapshot_id"
      echo "operation=$operation"
      echo "created_at=$(date '+%Y-%m-%d %H:%M:%S')"
    } > "$snapshot_dir/metadata"
    : > "$snapshot_dir/manifest.tsv"
  fi

  LAST_SNAPSHOT_ID="$snapshot_id"
  printf '%s\n' "$snapshot_id"
}

record_manifest() {
  local snapshot_id="$1"
  local component="$2"
  local target="$3"
  local state="$4"
  local backup_rel="$5"
  local source="$6"

  if [ "$DRY_RUN" -eq 1 ]; then
    return 0
  fi

  printf '%s\t%s\t%s\t%s\t%s\n' "$component" "$target" "$state" "$backup_rel" "$source" >> "$BACKUP_ROOT/$snapshot_id/manifest.tsv"
}

replace_target_with_link() {
  local snapshot_id="$1"
  local component="$2"
  local source="$3"
  local target="$4"

  local status backup_rel backup_path

  if [ ! -e "$source" ] && [ ! -L "$source" ]; then
    error "Source does not exist: $source"
    return 1
  fi

  status="$(target_status "$source" "$target")"

  if [ "$status" = "managed-link" ]; then
    record_manifest "$snapshot_id" "$component" "$target" "managed-link" "" "$source" || return 1
    info "Already managed: $target"
    return 0
  fi

  if [ "$status" != "missing" ]; then
    warn "Conflict detected at $target ($status)"
    if [ "$FORCE" -ne 1 ] && ! confirm "Replace $target ?"; then
      warn "Skipped: $target"
      return 0
    fi

    backup_rel="$component/${target#/}"
    backup_path="$BACKUP_ROOT/$snapshot_id/$backup_rel"
    run mkdir -p "$(dirname "$backup_path")" || return 1
    run mv "$target" "$backup_path" || return 1
    record_manifest "$snapshot_id" "$component" "$target" "$status" "$backup_rel" "$source" || return 1
  else
    record_manifest "$snapshot_id" "$component" "$target" "missing" "" "$source" || return 1
  fi

  run mkdir -p "$(dirname "$target")" || return 1
  run ln -s "$source" "$target" || return 1
  info "Linked $target -> $source"

  return 0
}

apply_install() {
  local operation="$1"
  shift
  local components=("$@")

  local snapshot_id entry source target component rc
  snapshot_id="$(create_snapshot "$operation")" || return 1

  for component in "${components[@]}"; do
    while IFS='|' read -r source target; do
      [ -z "$source" ] && continue
      replace_target_with_link "$snapshot_id" "$component" "$source" "$target"
      rc=$?
      if [ "$rc" -ne 0 ]; then
        error "Failed to apply $component ($target)"
        return "$rc"
      fi
    done < <(component_entries "$component")
  done

  info "Snapshot created: $snapshot_id"
  return 0
}

list_snapshots() {
  if [ ! -d "$BACKUP_ROOT" ]; then
    return 0
  fi

  find "$BACKUP_ROOT" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | sort -r
}

snapshot_exists() {
  local snapshot_id="$1"
  [ -d "$BACKUP_ROOT/$snapshot_id" ]
}

resolve_snapshot_for_rollback() {
  local requested="$1"
  if [ -n "$requested" ]; then
    printf '%s\n' "$requested"
    return 0
  fi

  local latest
  latest="$(list_snapshots | head -n 1)"
  if [ -z "$latest" ]; then
    error "No snapshots available for rollback"
    return 1
  fi

  printf '%s\n' "$latest"
  return 0
}

contains_component() {
  local needle="$1"
  shift
  local item
  for item in "$@"; do
    [ "$item" = "$needle" ] && return 0
  done
  return 1
}

rollback_snapshot() {
  local snapshot_id="$1"
  shift
  local components=("$@")
  local snapshot_dir="$BACKUP_ROOT/$snapshot_id"
  local manifest="$snapshot_dir/manifest.tsv"

  if [ ! -f "$manifest" ]; then
    error "Snapshot manifest missing: $snapshot_id"
    return 1
  fi

  if ! confirm "Rollback from snapshot $snapshot_id ?"; then
    warn "Rollback cancelled"
    return 1
  fi

  local line_component target state backup_rel source backup_path
  local did_work=0

  while IFS=$'\t' read -r line_component target state backup_rel source; do
    [ -z "$line_component" ] && continue
    if ! contains_component "$line_component" "${components[@]}"; then
      continue
    fi

    did_work=1

    if [ -e "$target" ] || [ -L "$target" ]; then
      run rm -rf "$target" || return 1
    fi

    if [ "$state" = "missing" ]; then
      info "Restored missing state: $target"
      continue
    fi

    if [ "$state" = "managed-link" ]; then
      run mkdir -p "$(dirname "$target")" || return 1
      run ln -s "$source" "$target" || return 1
      info "Restored managed link: $target -> $source"
      continue
    fi

    backup_path="$snapshot_dir/$backup_rel"
    if [ ! -e "$backup_path" ] && [ ! -L "$backup_path" ]; then
      error "Backup payload missing: $backup_path"
      return 1
    fi

    run mkdir -p "$(dirname "$target")" || return 1
    run cp -a "$backup_path" "$target" || return 1
    info "Restored $target"

    if [ "$DRY_RUN" -eq 0 ] && [ ! -e "$target" ] && [ ! -L "$target" ]; then
      error "Verification failed for restored target: $target"
      return 1
    fi
  done < "$manifest"

  if [ "$did_work" -eq 0 ]; then
    warn "No matching component entries in snapshot $snapshot_id"
  fi

  return 0
}

cmd_install() {
  local components=()
  resolve_components components "$@" || return 1
  apply_install "install" "${components[@]}"
}

cmd_update() {
  local components=()
  resolve_components components "$@" || return 1

  if command -v git >/dev/null 2>&1; then
    local git_status
    git_status="$(git -C "$SCRIPT_DIR" status --porcelain 2>/dev/null)"
    if [ -n "$git_status" ]; then
      warn "Repository has local changes; git pull may fail"
    fi
  else
    warn "git not found, skipping repository sync"
  fi

  if [ "$PULL_REPO" -eq 1 ] && command -v git >/dev/null 2>&1; then
    info "Syncing repository"
    run git -C "$SCRIPT_DIR" pull --ff-only || {
      error "git pull failed"
      return 1
    }
  else
    info "Skipped repository sync"
  fi

  apply_install "update" "${components[@]}"
  local rc=$?
  if [ "$rc" -ne 0 ]; then
    error "Update failed; trying rollback snapshot $LAST_SNAPSHOT_ID"
    rollback_snapshot "$LAST_SNAPSHOT_ID" "${components[@]}" || true
    return "$rc"
  fi

  return 0
}

cmd_rollback() {
  local version="$1"
  shift

  local components=()
  resolve_components components "$@" || return 1

  local snapshot_id
  snapshot_id="$(resolve_snapshot_for_rollback "$version")" || return 1

  if ! snapshot_exists "$snapshot_id"; then
    error "Snapshot not found: $snapshot_id"
    return 1
  fi

  rollback_snapshot "$snapshot_id" "${components[@]}"
}

cmd_status() {
  local components=()
  resolve_components components "$@" || return 1

  local component source target status
  for component in "${components[@]}"; do
    while IFS='|' read -r source target; do
      [ -z "$source" ] && continue
      status="$(target_status "$source" "$target")"
      printf '%-8s %-40s %-55s %s\n' "$component" "$source" "$target" "$status"
    done < <(component_entries "$component")
  done
}

cmd_list() {
  local item
  echo "Components:"
  for item in "${COMPONENTS[@]}"; do
    echo "  - $item"
  done
  echo "  - all"

  echo
  echo "Snapshots:"
  if [ -d "$BACKUP_ROOT" ]; then
    local has_snapshot=0
    while IFS= read -r item; do
      [ -z "$item" ] && continue
      has_snapshot=1
      echo "  - $item"
    done < <(list_snapshots)
    if [ "$has_snapshot" -eq 0 ]; then
      echo "  (none)"
    fi
  else
    echo "  (none)"
  fi
}

parse_global_options() {
  local -n remaining_ref="$1"
  shift

  local argv=("$@")
  local i=0
  local arg
  while [ "$i" -lt "${#argv[@]}" ]; do
    arg="${argv[$i]}"
    case "$arg" in
      -n|--dry-run)
        DRY_RUN=1
        ;;
      -y|--yes)
        ASSUME_YES=1
        ;;
      -f|--force)
        FORCE=1
        ;;
      --no-pull)
        PULL_REPO=0
        ;;
      -h|--help)
        usage
        exit 0
        ;;
      --version)
        i=$((i + 1))
        if [ "$i" -ge "${#argv[@]}" ]; then
          error "--version requires a value"
          return 1
        fi
        ROLLBACK_VERSION="${argv[$i]}"
        ;;
      *)
        remaining_ref+=("$arg")
        ;;
    esac
    i=$((i + 1))
  done

  return 0
}

main() {
  local raw_args=("$@")

  if [ "${#raw_args[@]}" -eq 0 ]; then
    usage
    return 0
  fi

  local first="${raw_args[0]}"
  if [ "$first" = "all" ] || is_component "$first"; then
    raw_args=(install "${raw_args[@]}")
  fi

  local command="${raw_args[0]}"
  local rest=("${raw_args[@]:1}")

  ROLLBACK_VERSION=""

  local positional=()
  parse_global_options positional "${rest[@]}" || return 1

  case "$command" in
    install)
      cmd_install "${positional[@]}"
      ;;
    update)
      cmd_update "${positional[@]}"
      ;;
    rollback)
      cmd_rollback "$ROLLBACK_VERSION" "${positional[@]}"
      ;;
    status)
      cmd_status "${positional[@]}"
      ;;
    list)
      cmd_list
      ;;
    help)
      usage
      ;;
    *)
      error "Unknown command: $command"
      usage
      return 1
      ;;
  esac
}

main "$@"
