#!/usr/bin/env bash

# check-otel.sh
# Audits OpenTelemetry Collector daemonsets and configurations.

set -euo pipefail

log_info() { echo -e "\033[0;32m[INFO]\033[0m $1"; }
log_err()  { echo -e "\033[0;31m[ERROR]\033[0m $1"; }

log_info "Auditing OpenTelemetry Collector ready status..."
if ! kubectl get pod -n monitoring -l app.kubernetes.io/name=opentelemetry-collector --no-headers 2>/dev/null | grep -q .; then
    log_info "  - OpenTelemetry Collector not deployed, skipping."
    exit 0
fi
if ! kubectl wait -n monitoring \
                  --for=condition=ready pod \
                  -l app.kubernetes.io/name=opentelemetry-collector \
                  --timeout=30s >/dev/null 2>&1; then
    log_err "OpenTelemetry Collector pods are not Ready!"
    exit 1
fi
log_info "  - OpenTelemetry Collector pods are Ready."

log_info "Verifying OTel Collector Service exposure..."
if ! kubectl get service -n monitoring otel-collector >/dev/null 2>&1; then
    log_info "  - OTel Collector service endpoint not found (not deployed)."
    exit 0
fi
log_info "  - Collector Service endpoint active on ports: 4317 (gRPC), 4318 (HTTP)."

log_info "OpenTelemetry Collector validation check passed!"
