#!/usr/bin/env bash

# check-tempo.sh
# Audits Tempo tracing components and search gateways.

set -euo pipefail

log_info() { echo -e "\033[0;32m[INFO]\033[0m $1"; }
log_err()  { echo -e "\033[0;31m[ERROR]\033[0m $1"; }

TEMPO_LABEL=""
for label in "app.kubernetes.io/component=ingester" "app.kubernetes.io/name=tempo" "app.kubernetes.io/instance=tempo"; do
    if kubectl get pod -n monitoring -l "$label" --no-headers 2>/dev/null | grep -q .; then
        TEMPO_LABEL="$label"
        break
    fi
done

if [ -z "$TEMPO_LABEL" ]; then
    log_info "  - Tempo not deployed, skipping."
    exit 0
fi

log_info "Auditing Tempo ingester nodes ready status..."
if ! kubectl wait -n monitoring \
                  --for=condition=ready pod \
                  -l "$TEMPO_LABEL" \
                  --timeout=30s >/dev/null 2>&1; then
    log_err "Tempo ingester pods are not ready!"
    exit 1
fi
log_info "  - Tempo ingesters are Ready."

log_info "Auditing Tempo distributor nodes ready status..."
if kubectl get pod -n monitoring -l app.kubernetes.io/component=distributor --no-headers 2>/dev/null | grep -q .; then
    if ! kubectl wait -n monitoring \
                      --for=condition=ready pod \
                      -l app.kubernetes.io/component=distributor \
                      --timeout=30s >/dev/null 2>&1; then
        log_err "Tempo distributor pods are not ready!"
        exit 1
    fi
    log_info "  - Tempo distributors are Ready."
else
    log_info "  - Single-binary Tempo (no separate distributors)."
fi

log_info "Tempo tracing database health checks passed!"
