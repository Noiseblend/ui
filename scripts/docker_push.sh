#!/bin/bash
echo "$DOCKER_PASSWORD" | docker login -u alinpanaitiu --password-stdin

docker push noiseblend/ui:$TRAVIS_COMMIT
docker push noiseblend/ui:staging

if [[ $TRAVIS_PULL_REQUEST == "false" && $TRAVIS_BRANCH != $TRAVIS_TAG ]]; then
    export DOCKER_TAG=${TRAVIS_BRANCH//\//-}
    export DOCKER_TAG=${DOCKER_TAG//[^-.a-zA-Z0-9]/_}
    docker tag noiseblend/ui:$TRAVIS_COMMIT noiseblend/ui:$DOCKER_TAG
    docker push noiseblend/ui:$DOCKER_TAG
fi

if [[ $TRAVIS_TAG ]]; then
    docker tag noiseblend/ui:$TRAVIS_COMMIT noiseblend/ui:$TRAVIS_TAG
    docker tag noiseblend/ui:$TRAVIS_COMMIT noiseblend/ui:latest
    docker push noiseblend/ui:$TRAVIS_TAG
    docker push noiseblend/ui:latest
fi
