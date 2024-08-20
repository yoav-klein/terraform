#!/bin/bash

curl -L get.docker.com | bash
docker run --network host yoavklein3/health:0.1



