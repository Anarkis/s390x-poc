#!/bin/bash

set -x

echo "Executing $0"
echo "SUCCESS!!!"

cat secrets.txt | docker login --username luistt --password-stdin
docker pull ubuntu
docker tag ubuntu luistt/s390x-poc:latest
docker push luistt/s390x-poc:latest

dockery system prune --all -f

echo "Finish pushing"
