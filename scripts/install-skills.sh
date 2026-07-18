#!/usr/bin/env bash
#
# Install src/<name>/ as ~/.claude/skills/<name>/.
#
# Claude Code loads ~/.claude/skills/<name>/SKILL.md. A bare
# ~/.claude/skills/<name>.md is never loaded, so a skill installed as a flat
# file is inert and nothing reports it.
#
# Usage:
#   scripts/install-skills.sh                   # install every skill
#   scripts/install-skills.sh code-quality      # install only that one
#   scripts/install-skills.sh --check           # verify only, change nothing
#
# On a real run, a flat ~/.claude/skills/<name>.md is archived and then removed,
# but only once the matching directory install has been verified. Anything this
# script did not install is left alone.
#
set -euo pipefail

repo_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
src_dir="$repo_root/src"
dest_dir="${CLAUDE_SKILLS_DIR:-$HOME/.claude/skills}"
archive_dir="${CLAUDE_SKILLS_ARCHIVE:-$HOME/.claude/skills-backup-$(date +%Y-%m-%d)}"

check_only=false
names=()
for arg in "$@"; do
  case "$arg" in
    --check) check_only=true ;;
    -*) echo "error: unknown option: $arg" >&2; exit 1 ;;
    *) names+=("$arg") ;;
  esac
done

if [ "${#names[@]}" -eq 0 ]; then
  for d in "$src_dir"/*/; do
    names+=("$(basename "$d")")
  done
fi

for name in "${names[@]}"; do
  if [ ! -f "$src_dir/$name/SKILL.md" ]; then
    echo "error: src/$name/SKILL.md does not exist" >&2
    exit 1
  fi
done

# --check: report which selected skills have no loadable install, change nothing.
if [ "$check_only" = true ]; then
  missing=0
  for name in "${names[@]}"; do
    if [ ! -f "$dest_dir/$name/SKILL.md" ]; then
      echo "NOT LOADABLE: $dest_dir/$name/SKILL.md is absent"
      missing=$((missing + 1))
    fi
  done
  total=$(find "$dest_dir" -name SKILL.md 2>/dev/null | wc -l)
  echo "---"
  echo "checked ${#names[@]} skill(s); $missing not loadable"
  echo "SKILL.md files currently under $dest_dir: $total"
  [ "$missing" -eq 0 ] || exit 1
  exit 0
fi

mkdir -p "$dest_dir"

installed=0
for name in "${names[@]}"; do
  rm -rf "${dest_dir:?}/$name"
  cp -R "$src_dir/$name" "$dest_dir/$name"
  installed=$((installed + 1))
done

# Verify every install landed before anything is removed.
failed=0
for name in "${names[@]}"; do
  if [ ! -f "$dest_dir/$name/SKILL.md" ]; then
    echo "error: install failed for $name" >&2
    failed=$((failed + 1))
  fi
done
if [ "$failed" -gt 0 ]; then
  echo "error: $failed install(s) failed; nothing removed" >&2
  exit 1
fi

total=$(find "$dest_dir" -name SKILL.md | wc -l)
if [ "$total" -lt "$installed" ]; then
  echo "error: found $total SKILL.md under $dest_dir, expected at least $installed" >&2
  exit 1
fi

# Retire the inert flat file, but only for a skill whose directory just verified.
removed=0
for name in "${names[@]}"; do
  flat="$dest_dir/$name.md"
  [ -e "$flat" ] || continue
  [ -f "$dest_dir/$name/SKILL.md" ] || continue

  mkdir -p "$archive_dir"
  # Never overwrite an existing archive entry: a second run on the same day
  # would otherwise destroy the copy the first run made. Suffix instead.
  dest="$archive_dir/$name.md"
  n=1
  while [ -e "$dest" ]; do
    dest="$archive_dir/$name.$n.md"
    n=$((n + 1))
  done
  # -L resolves symlinks so the archive holds content, not a dangling pointer.
  cp -L "$flat" "$dest"
  if [ ! -s "$dest" ]; then
    echo "error: archive of $name.md is empty ($dest); not removing" >&2
    exit 1
  fi
  rm -f "$flat"
  removed=$((removed + 1))
done

echo "installed $installed skill(s) into $dest_dir"
[ "$removed" -eq 0 ] || echo "archived and removed $removed inert flat .md file(s) to $archive_dir"
echo "SKILL.md files under $dest_dir: $total"
