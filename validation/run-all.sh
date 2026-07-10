#!/usr/bin/env bash

# run-all.sh
# Main test suite runner executing all platform observability validations.

set -uo pipefail

log_section() {
    echo "===================================================="
    echo "  $1"
    echo "===================================================="
}

EXIT_CODE=0

log_section "Starting Platform Observability Health Audit Suite"

# Run checks
./validation/check-prometheus.sh || EXIT_CODE=1

if [ -x ./validation/check-loki.sh ]; then
    ./validation/check-loki.sh || EXIT_CODE=1
fi

if [ -x ./validation/check-tempo.sh ]; then
    ./validation/check-tempo.sh || EXIT_CODE=1
fi

if [ -x ./validation/check-otel.sh ]; then
    ./validation/check-otel.sh || EXIT_CODE=1
fi

if [ $EXIT_CODE -ne 0 ]; then
    echo "Observability health audit FAILED! One or more checks failed."
    exit 1
else
    echo "Observability health audit SUCCESS! All components ready for production."
    exit 0
fi
