#!/bin/bash
cd "$(dirname "$0")"
./bin/flutter build apk "$@"
