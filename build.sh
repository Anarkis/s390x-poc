#!/bin/bash

set -x

echo "Executing $0"
echo "SUCCESS!!!"

cat secrets.txt | docker login --username luistt --password-stdin
echo $DOCKER_PASS | docker login --username luistt --password-stdin
docker build -t luistt/s390x-poc:latest -f Dockerfile --no-cache .
docker push luistt/s390x-poc:latest

#docker system prune --all -f

echo "Finish pushing"
