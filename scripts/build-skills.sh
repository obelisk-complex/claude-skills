#!/usr/bin/env bash
#
# Build skills/<name>.skill from src/<name>/.
#
# src/ is the source of truth; skills/*.skill is a build artefact. Editing a
# .skill directly loses the change on the next build.
#
# Usage:
#   scripts/build-skills.sh                     # rebuild every skill
#   scripts/build-skills.sh code-quality flaky-tests   # rebuild only those
#
set -euo pipefail

repo_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
src_dir="$repo_root/src"
out_dir="$repo_root/skills"

if ! command -v zip >/dev/null 2>&1; then
  echo "error: zip is not installed" >&2
  exit 1
fi

if [ "$#" -gt 0 ]; then
  names=("$@")
else
  names=()
  for d in "$src_dir"/*/; do
    names+=("$(basename "$d")")
  done
fi

# Validate every name before writing any archive, so a bad name in the list
# cannot leave a half-built set behind.
for name in "${names[@]}"; do
  if [ ! -d "$src_dir/$name" ]; then
    echo "error: no such skill source: src/$name" >&2
    exit 1
  fi
  if [ ! -f "$src_dir/$name/SKILL.md" ]; then
    echo "error: src/$name has no SKILL.md; it would not load" >&2
    exit 1
  fi
done

mkdir -p "$out_dir"

built=0
for name in "${names[@]}"; do
  # Anything git ignores is local-only and must never ship inside a .skill;
  # src/songwriting/his-signature.md is a personal file kept out of the package.
  # Without this the file would be republished inside the zip on the next build.
  excludes=()
  if git -C "$repo_root" rev-parse --git-dir >/dev/null 2>&1; then
    while IFS= read -r ignored; do
      [ -n "$ignored" ] || continue
      excludes+=("${ignored#src/}")
    done < <(git -C "$repo_root" ls-files --others --ignored --exclude-standard -- "src/$name")
  fi

  rm -f "$out_dir/$name.skill"
  # -X drops platform extras; the archive holds <name>/SKILL.md plus any
  # supporting files, which is the layout Claude Code loads.
  (cd "$src_dir" && zip -q -r -X "$out_dir/$name.skill" "$name" \
    ${excludes[0]+-x "${excludes[@]}"})
  echo "built skills/$name.skill"
  built=$((built + 1))
done

echo "$built skill(s) built"
