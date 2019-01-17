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
  printf "  ${GREEN}To clean up the testing container, run:${NC}\n"
  echo "    docker rm -f \"$(cat $1)\""
  echo ""
  printf "  ${GREEN}To clean up all system containers, run:${NC}\n"
  echo "    docker rm -f \$(docker ps -a -q)"
  echo ""

  exit 1
}

# Our tests need Docker installed
hash docker 2>/dev/null || { echo >&2 "I require Docker to be installed to run tests. Aborting."; exit 1; }

# Place to store container ID so tests can use it
CONTAINER_ID=$(mktemp)

# Clean up any stale test artifacts
docker rm -f melon

# Build the project
docker build -t cantaloupe .

# Run the project so it can be tested (will fail if docker-cantaloupe is already running)
docker run -d -p 8182:8182 -e "ENDPOINT_ADMIN_SECRET=secret" -e "ENDPOINT_ADMIN_ENABLED=true" --name melon -v testimages:/imageroot cantaloupe > "${CONTAINER_ID}"

# Run the tests
source tests/validate-results.sh "$CONTAINER_ID"

# Some hints about what to do with the test resources
echo ""
echo "For further in-container testing, run:"
echo "  docker exec -it \"$(cat ${CONTAINER_ID})\" bash"
echo ""
echo "To clean up the testing container, run:"
echo "  docker rm -f \"$(cat ${CONTAINER_ID})\""
echo ""
echo "To clean up all system containers, run:"
echo "  docker rm -f \$(docker ps -a -q)"
echo ""
