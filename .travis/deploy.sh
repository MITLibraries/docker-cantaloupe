#! /bin/bash

#
# A simple little Bash script to deploy our Docker image to DockerHub.
#

# To check for existing tags easily, we'll enable experimental features
mkdir ~/.docker
echo '{"experimental": "enabled"}' > ~/.docker/config.json

# First, login to the Docker registry
echo $DOCKER_PASSWORD | docker login --username $DOCKER_USERNAME --password-stdin

# A little debugging so we can see what the build produced (even if we ignore it)
docker images | grep "${REG_PROJECT}"

# What tag are we building, latest stable or the latest dev branch?
if [[ "$TRAVIS_BRANCH" == "$MASTER_BRANCH" && "$CANTALOUPE_VERSION" != "dev" ]]; then
  TAG=$(curl -S -H "Authorization: token $AUTH_TOKEN" \
    "https://api.github.com/repos/medusa-project/cantaloupe/releases/latest" \
    | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/' | cut -c2-)
elif [[ "$TRAVIS_BRANCH" == "$MASTER_BRANCH" ]]; then
  TAG="latest"
fi

echo "Travis branch: $TRAVIS_BRANCH"
echo "Hard push: $HARD_REGISTRY_PUSH"
echo "Tag: $TAG"

# Make sure we found the latest stable if that's what we are building
if [[ -z "$TAG" ]]; then
  exit 1
else
  # Does this tag already exist in our Docker image registry?
  TAG_EXISTS=$(docker manifest inspect "$REG_USERNAME"/"$REG_PROJECT":"$TAG" > /dev/null 2>&1 ; \
    echo $?)

  # Right now, we're not deploying a tag that already exists in the registry
  if [[ "$TAG_EXISTS" == "0" && "$TAG" != "dev" \
      && "$TRAVIS_BRANCH" == "$MASTER_BRANCH" && "$HARD_REGISTRY_PUSH" != "true" ]]; then
    echo "Release tag already exists; we don't need to push again"
  elif [[ "$TRAVIS_BRANCH" == "$MASTER_BRANCH" || "$HARD_REGISTRY_PUSH" == "true" ]]; then
    # If our build is a new stable version or a SNAPSHOT, we want to push to the registry
    docker tag "${REG_USERNAME}/${REG_PROJECT}_${CANTALOUPE_VERSION}" "${REG_USERNAME}/${REG_PROJECT}:${TAG}"
    docker push "${REG_USERNAME}/${REG_PROJECT}:${TAG}"
  fi
fi
