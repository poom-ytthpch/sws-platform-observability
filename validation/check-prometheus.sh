#!/usr/bin/env bash

# check-prometheus.sh
# Audits Prometheus server pods, status conditions, and operator availability.

set -euo pipefail

log_info() { echo -e "\033[0;32m[INFO]\033[0m $1"; }
log_err()  { echo -e "\033[0;31m[ERROR]\033[0m $1"; }

log_info "Auditing Prometheus operator ready state..."
if ! kubectl wait -n monitoring \
                  --for=condition=ready pod \
                  -l app.kubernetes.io/name=prometheus-operator \
                  --timeout=30s &>/dev/null; then
    log_err "Prometheus Operator pod is not Ready!"
    exit 1
fi
log_info "  - Prometheus Operator is ready."

log_info "Auditing Prometheus Server stateful replica pods..."
if ! kubectl wait -n monitoring \
                  --for=condition=ready pod \
                  -l app.kubernetes.io/name=prometheus \
                  --timeout=30s &>/dev/null; then
    log_err "Prometheus Server pods are not Ready!"
    exit 1
fi
log_info "  - Prometheus Server pods are Ready."

log_info "Prometheus core health checks passed!"
