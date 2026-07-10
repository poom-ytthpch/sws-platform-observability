# Platform Observability Stack (sws-platform-observability)

This submodule manages the **Platform Observability Stack (Layer 2)**. It provides end-to-end logging, metrics scraping, distributed tracing, and resource cost tracking.

---

## Overview

The observability layer runs in the `monitoring` namespace. It coordinates data collectors and storage backends to render dashboards inside Grafana.

### Components

1. **Prometheus Operator** (`v0.66.0` via Chart `48.2.0`): Automates Prometheus and Alertmanager setups.
2. **Grafana** (`v9.5.5` via Chart `6.57.4`): Visualizes logs, metrics, and traces.
3. **Loki** (`v2.8.2` via Chart `5.8.0`): Horizontally-scalable log aggregation store.
4. **Promtail** (`v2.8.2` via Chart `6.11.2`): DaemonSet log forwarding agent.
5. **Tempo** (`v2.1.1` via Chart `1.6.2`): Distributed tracing backend.
6. **OpenTelemetry Collector** (`v0.83.0` via Chart `0.66.0`): DaemonSet trace collector forwarding to Tempo.
7. **Blackbox Exporter** (`v0.24.0` via Chart `7.11.0`): Tests HTTP/TCP network availability endpoints.
8. **Opencost** (`v1.9.8` via Chart `1.1.0`): Kubernetes cost allocation monitor.

---

## Folders & Architecture

```
sws-platform-observability/
├── alerts/                       # Custom Alertmanager rules configs
├── charts/                       # Local helper Helm charts
├── docs/                         # TechDocs and manual references
├── environments/                 # Values overrides per environment
│   ├── default/
│   ├── development/
│   ├── staging/
│   └── production/
├── helmfiles/                    # Modular Helmfile files
│   ├── 00-crds.yaml.gotmpl
│   ├── 01-prometheus.yaml.gotmpl
│   ├── 02-grafana.yaml.gotmpl
│   ├── 03-loki.yaml.gotmpl
│   ├── 04-promtail.yaml.gotmpl
│   ├── 05-tempo.yaml.gotmpl
│   ├── 06-opentelemetry.yaml.gotmpl
│   ├── 07-blackbox.yaml.gotmpl
│   ├── 08-opencost.yaml.gotmpl
│   ├── 09-dashboards.yaml.gotmpl
│   ├── 10-alerts.yaml.gotmpl
│   └── 11-validation.yaml.gotmpl
├── validation/                   # Automated health checks
└── helmfile.yaml.gotmpl          # Primary state definition
```

---

## Commands

| Command | Purpose | Example |
| :--- | :--- | :--- |
| `make install` | Deploys the observability stack | `make install ENV=development` |
| `make upgrade` | Runs helmfile apply updates | `make upgrade ENV=development` |
| `make validate` | Runs all validation and readiness checks | `make validate` |
| `make verify` | Dry-run compiles templates check | `make verify` |
| `make lint` | Validates YAML configuration files | `make lint` |
| `make destroy` | Tears down observability stack | `make destroy ENV=development` |

---

## Environment Configuration

Configuration variables mapped from `.env.<environment>`:

| Variable | Description | Example |
| :--- | :--- | :--- |
| `GRAFANA_HOST` | Ingress route domain for Grafana console | `grafana.dev.sws.local` |
| `PROMETHEUS_HOST`| Ingress route domain for Prometheus admin | `prometheus.dev.sws.local` |
| `LOKI_HOST` | Log aggregation endpoint | `loki.dev.sws.local` |
| `TEMPO_HOST` | Trace query dashboard | `tempo.dev.sws.local` |

---

## Validation & Audit

The `./validation/run-all.sh` script triggers:
* `check-prometheus.sh`: Verifies Prometheus target scrape loops.
* `check-loki.sh`: Checks log query API response.
* `check-tempo.sh`: Assesses distributed tracing endpoint ingestion.
* `check-otel.sh`: Verifies telemetry collector DaemonSet pods status.
