#!/usr/bin/env bash
#
# Assert the mechanical items in SKILL_CHECKLIST.md.
#
# This gates packaging only: whether each skill loads at all, and whether the
# built archive still matches its source. Everything else in the checklist needs
# a reader, and this script does not pretend otherwise.
#
# Usage:
#   scripts/check-skills.sh                    # check every skill
#   scripts/check-skills.sh code-quality       # check only those named
#
# Exit status: 0 if every check passed, 1 if any failed.
set -uo pipefail

repo_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
src_dir="$repo_root/src"
skills_dir="$repo_root/skills"

for tool in unzip diff; do
  if ! command -v "$tool" >/dev/null 2>&1; then
    echo "error: $tool is not installed" >&2
    exit 1
  fi
done

if [ ! -d "$src_dir" ]; then
  echo "error: no src/ directory; nothing to check" >&2
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

failures=0
checked=0

fail() {
  echo "  FAIL: $1"
  failures=$((failures + 1))
}

# Extract the YAML frontmatter block: everything between the leading '---' and
# the next '---'. Empty output means there was no frontmatter to read.
frontmatter() {
  awk 'NR==1 && $0!="---" {exit} NR==1 {next} /^---[[:space:]]*$/ {exit} {print}' "$1"
}

tmp_root=$(mktemp -d)
trap 'rm -rf "$tmp_root"' EXIT

for name in "${names[@]}"; do
  echo "$name"
  checked=$((checked + 1))
  src="$src_dir/$name"
  skill_md="$src/SKILL.md"
  archive="$skills_dir/$name.skill"

  if [ ! -d "$src" ]; then
    fail "no such skill source: src/$name"
    continue
  fi

  # 1. The skill body exists. Without it the skill does not load and no other
  #    property is worth checking.
  if [ ! -f "$skill_md" ]; then
    fail "src/$name/SKILL.md is missing; the skill would not load"
    continue
  fi

  # 2. Frontmatter carries name and description, and name matches the directory.
  fm=$(frontmatter "$skill_md")
  if [ -z "$fm" ]; then
    fail "src/$name/SKILL.md has no YAML frontmatter block"
  else
    fm_name=$(printf '%s\n' "$fm" | sed -n 's/^name:[[:space:]]*//p' | head -1)
    fm_name=${fm_name%"${fm_name##*[![:space:]]}"}
    if [ -z "$fm_name" ]; then
      fail "src/$name/SKILL.md frontmatter has no 'name' field"
    elif [ "$fm_name" != "$name" ]; then
      fail "frontmatter name '$fm_name' does not match directory 'src/$name'"
    fi
    if ! printf '%s\n' "$fm" | grep -q '^description:'; then
      fail "src/$name/SKILL.md frontmatter has no 'description' field"
    else
      # A description that is blank on its own line and has no continuation is
      # an empty matching surface, which is the same as having none.
      desc_body=$(printf '%s\n' "$fm" | sed -n '/^description:/,$p' \
        | sed '1s/^description:[[:space:]]*//' | tr -d '>|[:space:]')
      if [ -z "$desc_body" ]; then
        fail "src/$name/SKILL.md frontmatter 'description' is empty"
      fi
    fi
  fi

  # 3. The root documentation file exists. Each skill lives in three places that
  #    must move together; this is the one of them that git tracks separately.
  if [ ! -f "$repo_root/$name.md" ]; then
    fail "$name.md is missing from the repo root"
  fi

  # 4. A built archive exists and holds <name>/SKILL.md at the path Claude Code
  #    loads from.
  if [ ! -f "$archive" ]; then
    fail "skills/$name.skill has not been built"
    continue
  fi
  if ! unzip -l "$archive" 2>/dev/null | grep -q "[[:space:]]$name/SKILL.md$"; then
    fail "skills/$name.skill does not contain $name/SKILL.md"
    continue
  fi

  # 5. The archive still matches src/. build-skills.sh does not install and
  #    install-skills.sh does not rebuild, so nothing else closes this loop: an
  #    edit to src/ without a rebuild ships the old body to every caller.
  #
  #    Files git ignores are deliberately absent from the archive (see
  #    build-skills.sh), so compare against a copy of src/<name> with those
  #    removed rather than against src/<name> itself.
  work="$tmp_root/$name"
  mkdir -p "$work/expected" "$work/actual"
  cp -R "$src" "$work/expected/$name"
  if git -C "$repo_root" rev-parse --git-dir >/dev/null 2>&1; then
    while IFS= read -r ignored; do
      [ -n "$ignored" ] || continue
      rm -rf "$work/expected/${ignored#src/}"
    done < <(git -C "$repo_root" ls-files --others --ignored --exclude-standard -- "src/$name")
  fi
  if ! unzip -q -o "$archive" -d "$work/actual" 2>/dev/null; then
    fail "skills/$name.skill could not be extracted"
    continue
  fi
  if ! diff_out=$(diff -r "$work/expected/$name" "$work/actual/$name" 2>&1); then
    fail "skills/$name.skill is out of date with src/$name; run scripts/build-skills.sh $name"
    printf '%s\n' "$diff_out" | sed 's/^/        /' | head -10
  fi
done

echo
if [ "$failures" -eq 0 ]; then
  echo "$checked skill(s) checked, all mechanical checks passed"
  exit 0
fi
echo "$checked skill(s) checked, $failures check(s) failed"
exit 1
