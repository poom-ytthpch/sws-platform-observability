#!/usr/bin/env bash

# check-prometheus.sh
# Audits Prometheus server pods, status conditions, and operator availability.

set -euo pipefail

log_info() { echo -e "\033[0;32m[INFO]\033[0m $1"; }
log_err()  { echo -e "\033[0;31m[ERROR]\033[0m $1"; }

log_info "Auditing Prometheus operator ready state..."
if kubectl get pod -n monitoring -l app=kube-prometheus-stack-operator --no-headers 2>/dev/null | grep -q .; then
    OPERATOR_LABEL="app=kube-prometheus-stack-operator"
elif kubectl get pod -n monitoring -l app.kubernetes.io/name=prometheus-operator --no-headers 2>/dev/null | grep -q .; then
    OPERATOR_LABEL="app.kubernetes.io/name=prometheus-operator"
else
    log_info "  - Prometheus Operator not found, skipping."
    exit 0
fi
if ! kubectl wait -n monitoring \
                  --for=condition=ready pod \
                  -l "$OPERATOR_LABEL" \
                  --timeout=30s >/dev/null 2>&1; then
    log_err "Prometheus Operator pod is not Ready!"
    exit 1
fi
log_info "  - Prometheus Operator is ready."

log_info "Auditing Prometheus Server stateful replica pods..."
if kubectl get pod -n monitoring -l app.kubernetes.io/name=prometheus --no-headers 2>/dev/null | grep -q .; then
    SERVER_LABEL="app.kubernetes.io/name=prometheus"
elif kubectl get pod -n monitoring -l app.kubernetes.io/instance=prometheus --no-headers 2>/dev/null | grep -q .; then
    SERVER_LABEL="app.kubernetes.io/instance=prometheus"
else
    log_info "  - Prometheus Server not found, skipping."
    exit 0
fi
if ! kubectl wait -n monitoring \
                  --for=condition=ready pod \
                  -l "$SERVER_LABEL" \
                  --timeout=30s >/dev/null 2>&1; then
    log_err "Prometheus Server pods are not Ready!"
    exit 1
fi
log_info "  - Prometheus Server pods are Ready."

log_info "Prometheus core health checks passed!"
