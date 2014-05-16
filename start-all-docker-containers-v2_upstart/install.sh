#!/bin/bash
set -e

SRC="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

install -o root -m 644 "${SRC}/start-all-docker-containers.conf" /etc/init/
