#!/bin/bash

if ! gitleaks protect --verbose --redact --staged --no-banner --log-level=warn; then
  exit 1
fi
