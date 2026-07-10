#!/usr/bin/env bash

# check-tempo.sh
# Audits Tempo tracing components and search gateways.

set -euo pipefail

log_info() { echo -e "\033[0;32m[INFO]\033[0m $1"; }
log_err()  { echo -e "\033[0;31m[ERROR]\033[0m $1"; }

log_info "Auditing Tempo ingester nodes ready status..."
if ! kubectl wait -n monitoring \
                  --for=condition=ready pod \
                  -l app.kubernetes.io/component=ingester \
                  --timeout=30s &>/dev/null; then
    log_err "Tempo ingester pods are not ready!"
    exit 1
fi
log_info "  - Tempo ingesters are Ready."

log_info "Auditing Tempo distributor nodes ready status..."
if ! kubectl wait -n monitoring \
                  --for=condition=ready pod \
                  -l app.kubernetes.io/component=distributor \
                  --timeout=30s &>/dev/null; then
    log_err "Tempo distributor pods are not ready!"
    exit 1
fi
log_info "  - Tempo distributors are Ready."

log_info "Tempo tracing database health checks passed!"
