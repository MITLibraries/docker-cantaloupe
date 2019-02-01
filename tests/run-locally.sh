#! /bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# List of different types we want to run
CANTALOUPE_VERSION="stable" COMMIT_REF="437a72d7" "$DIR/run-tests.sh"
CANTALOUPE_VERSION="latest" COMMIT_REF="437a72d7" "$DIR/run-tests.sh"
