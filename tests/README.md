# Tests

## Helm chart inputs

The following tests are implemented to be triggered by the Github workflow on [`validate_helm_input.yaml`](/.github/workflows/validate_helm_input.yml) every pull request in order to check that new commits do not break the expected outcome of the Helm chart.

### Case 01 - Cluster name should be defined

The variable cluster name is mandatory. Every telemetry data is enriched with to be provided cluster name so that one can differentiate from which cluster the corresponding telemetry data is coming.

### Case 02 - At least 1 telemetry type should be enabled

There are 3 different telemetry types for the chart which are primarily having different responsibilities:

| Telemetry | K8s object   |
| --------- | ------------ |
| `traces`  | `deployment` |
| `logs`    | `daemonset`  |
| `metrics` | `statefulet` |

At least one of these telemetry types must be enabled.

### Case 03, 04, 05 - New Relic account should be defined

If any telemetry type is enabled, it also has to have a New Relic block defined so that the gathered telemetry data could be sent to a New Relic account.

| K8s object   | Case |
| ------------ | ---- |
| `deployment` | `03` |
| `daemonset`  | `04` |
| `statefulet` | `05` |

### Case 06, 07, 08 - OTLP endpoint should be valid

If any telemetry type is enabled, the OTLP endpoint of the corresponding New Relic account should be valid where

- US -> `otlp.nr-data.net:4317`
- EU -> `otlp.eu01.nr-data.net:4317`

| K8s object   | Case |
| ------------ | ---- |
| `deployment` | `06` |
| `daemonset`  | `07` |
| `statefulet` | `08` |

### Case 09, 10, 11 - License key should be defined

If any telemetry type is enabled, the license key of the corresponding New Relic account should either be defined directly by providing the value to the helm chart or by referencing an existing secret which holds the license key.

| K8s object   | Case |
| ------------ | ---- |
| `deployment` | `09` |
| `daemonset`  | `10` |
| `statefulet` | `11` |

### Case 12, 13, 14 - License key reference should have a name

If the license key of the corresponding New Relic account is defined by referencing an existing secret which holds the license key, the name of the secret should be given.

| K8s object   | Case |
| ------------ | ---- |
| `deployment` | `12` |
| `daemonset`  | `13` |
| `statefulet` | `14` |

### Case 15, 16, 17 - License key reference should have a key

If the license key of the corresponding New Relic account is defined by referencing an existing secret which holds the license key, the key in itself that points to the license key should be given.

| K8s object   | Case |
| ------------ | ---- |
| `deployment` | `15` |
| `daemonset`  | `16` |
| `statefulet` | `17` |
