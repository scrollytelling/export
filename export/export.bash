#!/bin/bash

set -eu -o pipefail

for f in ../entries/*/*/*.json; do
  # tr bla
  grep \
    --ignore-case --only-matching --null \
    --regexp="media.scrollytelling.com/main/\w*/\w*/[[:digit:]]*/[[:digit:]]*/[[:digit:]]*" \
    "$f" | xargs --null -I '{}' aws s3 sync "s3://{}" "$path/{}"
done
