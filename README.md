# Kubernetes Monitoring with Open Telemetry

This repository is dedicated to provide a quick start to monitor you Kubernetes cluster. It is designed to be as scalable as possible with the further functionality of exporting necessary telemetry data to multiple New Relic accounts.

The collection telemetry data (`logs`, `traces` and `metrics`) is achieved per Open Telemetry collectors configured and deployed as following Kubernetes resources:

- Daemonset
- Deployment
- Statefulset

## Prerequisites

The Helm chart uses Open Telemetry collector Custom Resource Definition (CRD) which requires the [Open Telemetry operator](https://github.com/open-telemetry/opentelemetry-operator) to be deployed. In order to deploy the operator refer to this [Helm chart](https://github.com/open-telemetry/opentelemetry-helm-charts/tree/main/charts/opentelemetry-operator) or simply use the [`00_deploy_operator.sh`](./helm/scripts/00_deploy_operator.sh).

## Purpose of various collectors

### Daemonset

The daemonset is primarily used to gather the logs of the applications. It uses the `filelogreceiver` to _tail_ the logs from the nodes (`var/log/pods/...`). Each collector instance is responsible for the collection and forwarding of the logs on its own node where it's running to corresponding New Relic accounts. [`Daemonset collector config`](./helm/charts/collectors/templates/daemonset-otelcollector.yaml) can be adapted in order to filter or enrich the logs.

### Deployment

The deployment is primarily used to gather the traces and therefore consists of 2 separate deployments as `recevier` and `exporter`. The reason for this is that the traces are mostly to be sampled and sampling works properly only when all the spans of a trace are processed by one collector instance.

The `receiver` collector is responsible for gathering all of the spans from different applications. It will forward these spans per the `loadbalancingexporter` to the `exporter` collector where they will be sampled according to their trace IDs. The `exporter` collector will then flush the sampled spans to necessary New Relic accounts. Please see official Open Telemetry [docs](https://opentelemetry.io/docs/collector/scaling/#scaling-stateful-collectors) for more!

### Statefulset

The statefulset is primarily used to scrape the metrics throughout the cluster. It uses the `prometheusreceiver` to fetch metrics per various Kubernetes service discovery possibilities (`services`, `nodes`, `cadvisor`...).

In order to be able able to scale it out, the [Target Allocator](https://github.com/open-telemetry/opentelemetry-operator#target-allocator) is used which distributes the to be scraped endpoints which are discovered by the Kubernetes service discovary as evenly as possible across the instances of the statefulsets so that each endpoint is scraped only once by one collector instance at a time. Thereby, the requirement to maintain a central Prometheus server with huge memory needs can be replaced by multiple smaller instances of collector scrapers. Please refer to the official Open Telemetry [docs](https://opentelemetry.io/docs/collector/scaling/#scaling-the-scrapers) for more!

## Multi-account export

A highly demanded use-case is to be able to:

- gather data from all possible objects
- filter them according to various requirements
- send them to multiple New Relic accounts

A typical example can be given as an organization with an ops team and multiple dev teams where

- the ops team is responsible for the health of the cluster and the commonly running applications on it (Nginx, Kafka, service mesh...)
- the dev team is responsible for their own applications which are mostly running in a dedicated namespace

Since the monitoring tools are mostly deployed by the ops team, the collected telemetry data tends to end up being forwarded only to their New Relic account and the dev teams are supposed to deploy the same tools to their namespaces in order to have the necessary data forwarded to their New Relic accounts.

**An example** complication with this methodology would be to distribute the container metrics that are exposed by the `cadvisor` which is not running per namespace but per node and requires cluster-wide RBAC rights to be accessed. Mostly, these rights are not preferred to be given to individual dev teams which makes the situation even more complicated for the dev teams to obtain the container metrics of their own applications.

### Solution

Every collector is configured to accept multiple filtering & exporting possibilities see ([`values.yaml`](./helm/charts/collectors/values.yaml)):

- `1` ops team
- `x` dev teams

If you were to have 1 ops team & 2 dev teams and would like to send the telemetry data

- from the entire cluster to ops team
- from the individual namespaces to corresponding dev teams

you can use the following configuration for daemonset, deployment and statefulset:

```
opsteam:
  endpoint: "OTLP_ENDPOINT_OPS_TEAM"
  licenseKey: "LICENSE_KEY_OPS_TEAM"
  namespaces: []
devteam1:
  endpoint: "OTLP_ENDPOINT_DEV_TEAM_1"
  licenseKey: "LICENSE_KEY_DEV_TEAM_1"
  namespaces:
    - namespace_of_dev_team_1
devteam2:
  endpoint: "OTLP_ENDPOINT_DEV_TEAM_2"
  licenseKey: "LICENSE_KEY_DEV_TEAM_2"
  namespaces:
    - namespace_of_dev_team_2
```

Since all of the telemetry data is centrally collected by 3 variations of collectors, each variation can filter the data according to the namespaces where the data is coming from. So centrally gathered data will be

- filtered by multiple processors depending on the config above
- routed to corresponding exporters and thereby to corresponding New Relic accounts

## Deploy!

Feel free to customize the [Kubernetes manifest files](./helm/charts/collectors/templates/)! You can simply add your OTLP endpoints and license keys according to your New Relic accounts and run the [`01_deploy_collectors.sh`](./helm/scripts/01_deploy_collectors.sh).
