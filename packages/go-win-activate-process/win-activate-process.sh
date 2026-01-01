#!/bin/sh

: ${USERPROFILE?"USERPROFILE environment variable must be set"}

exec "$USERPROFILE/bin/win-activate-process.exe" "$@"
