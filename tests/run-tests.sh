#! /bin/bash

# Color hints for alerts and messages
GREEN='\033[1;32m'
RED='\033[0;31m'
NC='\033[0m'

# Our tests need Docker installed
hash docker 2>/dev/null || { echo >&2 "I require Docker to be installed to run tests. Aborting."; exit 1; }

# Tell what we're testing
printf "${GREEN}Testing ${CANTALOUPE_VERSION} Cantaloupe build${NC}\n"

# Place to store container ID so tests can use it
CONTAINER_ID=$(mktemp)

# Clean up any stale test artifacts
docker rm -f melon

if [[ "$DIRTY" != "true" ]]; then
  docker rmi -f cantaloupe
fi

# Build the project
if [[ "$CANTALOUPE_VERSION" == "latest" ]]; then
  # If we're using specific commit, tag, or branch, supply that value
  if [[ ! -z "$COMMIT_REF" ]]; then
    printf "${GREEN}Building specific reference point: ${COMMIT_REF}${NC}"
    REF_BUILD_ARG="--build-arg COMMIT_REF=$COMMIT_REF"
  else
    printf "${GREEN}Building the latest development snapshot${NC}\n"
    REF_BUILD_ARG=""
  fi

  docker build --build-arg CANTALOUPE_VERSION="latest" --build-arg COMMIT_REF="$COMMIT_REF" -t cantaloupe .
else
  printf "${GREEN}Building the latest stable release${NC}\n"
  docker build -t cantaloupe .
fi

printf "${GREEN}Running the newly built container${NC}\n"

# Run the project so it can be tested
docker run -p 8182:8182 -d \
  -e "ENDPOINT_ADMIN_SECRET=secret" -e "ENDPOINT_ADMIN_ENABLED=true" \
  --name melon -v testimages:/imageroot cantaloupe > "$CONTAINER_ID"

CONTAINER_ID=$(cat $CONTAINER_ID)
printf "${GREEN}Container ID: $CONTAINER_ID${NC}\n"

# Run the tests
source tests/validate-results.sh

# Some hints about what to do with the test resources
echo ""
echo "For further in-container testing, run:"
echo "  docker exec -it \"${CONTAINER_ID}\" bash"
echo ""
echo "To clean up the testing container, run:"
echo "  docker rm -f \"${CONTAINER_ID}\""
echo ""
echo "To clean up all system containers, run:"
echo "  docker rm -f \$(docker ps -a -q)"
echo ""
