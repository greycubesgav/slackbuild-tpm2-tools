#!/usr/bin/env bash

docker build -t grecycubesgav/slackbuild-tpm2-tools:latest .
docker create --name temp_container grecycubesgav/slackbuild-tpm2-tools:latest
mkdir -p packages
docker cp temp_container:/tmp/tpm2-tools-5.6-x86_64-GG_GG.tgz ./packages/
md5sum ./packages/*.*
