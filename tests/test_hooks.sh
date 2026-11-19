#!/usr/bin/env bash
# Runs entirely in a throwaway repo under mktemp; never touches global git config.
set -u
root="$(cd "$(dirname "$0")/.." && pwd)"
d=$(mktemp -d); cd "$d"; git init -q .; git config user.email t@t; git config user.name t
"$root/install.sh" >/dev/null
fail=0; ok(){ echo "PASS $1"; }; bad(){ echo "FAIL $1"; fail=1; }
M='Model: claude-sonnet-5-5 harness=claude-code effort=high conf=medium'
try() { git commit -qm "$1" 2>/dev/null; }   # $1 = full message
echo a>a; git add a
try "x"                                                 && bad reject-missing     || ok reject-missing
try "x"$'\n\n'"${M/claude-sonnet-5-5/unknown}"          && bad reject-placeholder || ok reject-placeholder
try "x"$'\n\n'"${M/conf=medium/conf=sure}"              && bad reject-conf        || ok reject-conf
try "x"$'\n\n'"${M/harness=claude-code /}"              && bad reject-no-harness  || ok reject-no-harness
try "x"$'\n\n'"$M"                                      && ok accept-full         || bad accept-full
git notes --ref=model-id show HEAD | grep -q 'Review-Status: pending' && ok note-written || bad note-written
echo b>b; git add b; GIT_HUMAN_COMMIT=1 git commit -qm "human" && ok human-bypass || bad human-bypass
"$root/bin/model-review" comment HEAD~1 "looks fine" >/dev/null 2>&1
git notes --ref=model-id show HEAD~1 | grep -q 'Review-Status: reviewed' && ok review-marked || bad review-marked
echo "scratch repo: $d"; exit $fail
