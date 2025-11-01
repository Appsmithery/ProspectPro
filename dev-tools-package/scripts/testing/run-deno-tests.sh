#!/bin/bash
# Run all Deno tests in app/tests/deno
set -e
cd "$(dirname "$0")/../../../app/tests/deno"
denotest() {
  if command -v deno >/dev/null 2>&1; then
    deno test --allow-all .
  else
    echo "Deno is not installed. Please install Deno to run these tests."
    exit 1
  fi
}
denotest
