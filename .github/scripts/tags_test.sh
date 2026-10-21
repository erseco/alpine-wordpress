#!/bin/sh
# Checks for tags.sh. Run: sh .github/scripts/tags_test.sh
set -eu
cd "$(dirname "$0")"
VERSIONS='6.5.5
6.5.5-1
6.5.5-2
6.7.10
6.8
6.9
6.9.4
7.0
7.0.4
7.1
7.1.3'

check() { [ "$2" = "$3" ] || { echo "FAIL $1: expected '$3', got '$2'"; exit 1; }; }

check newest     "$(echo "$VERSIONS" | sh tags.sh aliases 7.1.3)"   "7.1.3 7.1 7 latest"
check minor      "$(echo "$VERSIONS" | sh tags.sh aliases 7.0.4)"   "7.0.4 7.0"
check old-series "$(echo "$VERSIONS" | sh tags.sh aliases 6.9.4)"   "6.9.4 6.9 6"
check superseded "$(echo "$VERSIONS" | sh tags.sh aliases 7.0)"     "7.0"
check suffix     "$(echo "$VERSIONS" | sh tags.sh aliases 6.5.5-2)" "6.5.5-2 6.5"
check suffix-old "$(echo "$VERSIONS" | sh tags.sh aliases 6.5.5-1)" "6.5.5-1"
check untagged   "$(echo "$VERSIONS" | sh tags.sh aliases 7.1.4)"   "7.1.4 7.1 7 latest"
check readme     "$(echo "$VERSIONS" | sh tags.sh readme)" '- `7.1.3`, `7.1`, `7`, `latest`
- `7.0.4`, `7.0`
- `6.9.4`, `6.9`, `6`
- `6.8`
- `6.7.10`, `6.7`'
check series     "$(echo "$VERSIONS" | sh tags.sh series | tr '\n' ' ')" "7.1.3 7.0.4 6.9.4 6.8 6.7.10 "
check base-new   "$(sh tags.sh base 6.9.4)"  "latest"
check base-old   "$(sh tags.sh base 6.8.11)" "3.24-php83"
check base-main  "$(sh tags.sh base latest)" "latest"
echo "tags.sh OK"
