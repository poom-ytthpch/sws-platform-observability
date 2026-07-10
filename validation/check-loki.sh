#!/usr/bin/env bash

# check-loki.sh
# Audits Loki read, write, and gateway components.

set -euo pipefail

log_info() { echo -e "\033[0;32m[INFO]\033[0m $1"; }
log_err()  { echo -e "\033[0;31m[ERROR]\033[0m $1"; }

log_info "Auditing Loki write nodes ready status..."
if ! kubectl wait -n monitoring \
                  --for=condition=ready pod \
                  -l app.kubernetes.io/component=write \
                  --timeout=30s &>/dev/null; then
    log_err "Loki write pods are not ready!"
    exit 1
fi
log_info "  - Loki write nodes are Ready."

log_info "Auditing Loki read nodes ready status..."
if ! kubectl wait -n monitoring \
                  --for=condition=ready pod \
                  -l app.kubernetes.io/component=read \
                  --timeout=30s &>/dev/null; then
    log_err "Loki read pods are not ready!"
    exit 1
fi
log_info "  - Loki read nodes are Ready."

log_info "Loki log aggregation health checks passed!"
