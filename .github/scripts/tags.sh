#!/bin/sh
# Docker tag helpers. Reads every published version (one git tag per line) from stdin.
#   tags.sh aliases <version>  tags for <version>: itself, plus <minor>, <major> and latest
#                              when it is the newest version of that series
#   tags.sh series             newest version of each supported minor series, newest first
#   tags.sh readme             markdown list with the newest version of each supported series and its tags
#   tags.sh base <version>     alpine-php-webserver tag to build <version> on
set -eu

OLDEST_SERIES=6.7 # older series are no longer built

# True when version $1 >= version $2
at_least() { [ "$(printf '%s\n%s\n' "$1" "$2" | sort -V | head -n1)" = "$2" ]; }

# Newest version in series $1 (e.g. 7.1 matches 7.1, 7.1.3 and 7.1.3-2); all versions when $1 is empty
newest() {
    if [ -n "$1" ]; then grep -E "^$(echo "$1" | sed 's/\./\\./g')([.-]|\$)"; else cat; fi | sort -V | tail -n1
}

aliases() {
    all=$(cat; echo "$1")
    minor=$(echo "$1" | cut -d- -f1 | cut -d. -f1,2)
    tags=$1
    for series in "$minor" "${minor%%.*}" ""; do
        [ "$(echo "$all" | newest "$series")" = "$1" ] || break
        [ "$series" = "$1" ] || tags="$tags ${series:-latest}"
    done
    echo "$tags"
}

series() {
    all=$(cat)
    for minor in $(echo "$all" | cut -d- -f1 | cut -d. -f1,2 | sort -uVr); do
        at_least "$minor" "$OLDEST_SERIES" && echo "$all" | newest "$minor"
    done
}

readme() {
    all=$(cat)
    for v in $(echo "$all" | series); do
        echo "$all" | aliases "$v" | sed 's/[^ ]*/`&`/g; s/ /, /g; s/^/- /'
    done
}

# WordPress supports PHP 8.5 from 6.9 on; older series stay on PHP 8.3
base() {
    if [ "$1" = latest ] || at_least "$1" 6.9; then echo latest; else echo 3.24-php83; fi
}

"$@"
