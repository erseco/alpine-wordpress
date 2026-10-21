#!/bin/sh
# Docker tag helpers. Reads every published version (one git tag per line) from stdin.
#   tags.sh aliases <version>  tags for <version>: itself, plus <minor>, <major> and latest
#                              when it is the newest version of that series
#   tags.sh readme             markdown list with the newest version of each minor series and its tags
set -eu

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

readme() {
    all=$(cat)
    for minor in $(echo "$all" | cut -d- -f1 | cut -d. -f1,2 | sort -uVr); do
        echo "$all" | aliases "$(echo "$all" | newest "$minor")" | sed 's/[^ ]*/`&`/g; s/ /, /g; s/^/- /'
    done
}

"$@"
