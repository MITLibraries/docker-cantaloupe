#! /bin/bash

# Color hints for alerts and messages
GREEN='\033[1;32m'
RED='\033[0;31m'
NC='\033[0m'

# An informational message in case a test fails
die () {
  echo ""
  printf "${RED}Tests failed!${NC}\n"
  echo ""

  if [ "$TRAVIS" != 'true' ]; then
    printf "  ${GREEN}To clean up the testing container, run:${NC}\n"
    echo "    docker rm -f \"$(cat $1)\""
    echo ""
    printf "  ${GREEN}To clean up all system containers, run:${NC}\n"
    echo "    docker rm -f \$(docker ps -a -q)"
    echo ""
  fi

  exit $2
}

# These are the actual tests we run
docker exec --tty "$(cat ${1})" env TERM=xterm ls /etc/cantaloupe.properties >> /dev/null 2>&1 || die "$1" "$?"

printf "${GREEN}Tests ran successfully!${NC}\n"
