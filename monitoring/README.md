# Monitoring

Monitor your cluster instantly per `Terraform`! Run the [`00_create_newrelic_resources.sh`](/monitoring/scripts/00_create_newrelic_resources.sh) script as follows:

## Setup

### Set your New Relic parameters

You need to define the following variables within the `terraform` commands

```shell
terraform -chdir=../terraform plan \
  -var NEW_RELIC_ACCOUNT_ID=$NEWRELIC_ACCOUNT_ID \
  -var NEW_RELIC_API_KEY=$NEWRELIC_API_KEY \
  -var NEW_RELIC_REGION=$NEWRELIC_REGION \
  -var cluster_name=$clusterName \
  -out "./tfplan"
```

where `NEW_RELIC_ACCOUNT_ID` corresponds to your New Relic account ID, `NEW_RELIC_API_KEY` to your [User API Key](https://docs.newrelic.com/docs/apis/intro-apis/new-relic-api-keys/#user-key) and `NEWRELIC_REGION` to the data center region of your New Relic account (`us` or `eu`).

### Set your cluster name

```shell
clusterName="my-dope-cluster"
```

**Remark:** Keep in mind that this cluster name should match the one which you have run the `helm charts` with!

## New Relic resources

The `Terraform` deployment will create the following New Relic resources for you:

- [Dashboards](#dashboards)
- [Alerts](#alerts)

### Dashboards

[**Cluster Overview - Nodes**](/monitoring/terraform/04_dashboard_cluster_overview.tf)

- Node capacities
- Node to pod mapping
- Namespaces & pods per node
- CPU, MEM & STO usage/utilization per node

![Cluster Overview - Nodes](/monitoring/docs/cluster_overview_nodes.png)

[**Cluster Overview - Namespaces**](/monitoring/terraform/04_dashboard_cluster_overview.tf)

- Deployments, statefulsets & daemonsets
- Pods with running, pending, failed & unknown statuses
- Namespaces & pods per node
- CPU & MEM usage/utilization per namespace

![Cluster Overview - Namespaces](/monitoring/docs/cluster_overview_namespaces.png)

[**Cluster Overview - Pods**](/monitoring/terraform/04_dashboard_cluster_overview.tf)

- Containers & their statuses
- Pods with running, pending, failed & unknown statuses
- CPU & MEM usage/utilization per pod/container
- Filesystem read/write per pod/container
- Network receive/transmit per pod/container

![Cluster Overview - Pods](/monitoring/docs/cluster_overview_pods.png)

[**OTel Collectors Overview**](/monitoring/terraform/04_dashboard_otel_collector.tf)

- Collector node capacities & statuses
- Pods with running, pending, failed & unknown statuses
- CPU & MEM usage/utilization per collector instance
- Ratio of queue size to capacity per collector instance
- Dropped telemetry data per collector instance
- Failed receive/enqueue/export per collector instance

![OTel Collectors Overview 1](/monitoring/docs/otel_collector_overview_1.png)
![OTel Collectors Overview 2](/monitoring/docs/otel_collector_overview_2.png)

[**Kube API Server Overview**](/monitoring/terraform/04_dashboard_kube_apiserver.tf)

- Collector node capacities & statuses
- Pods with running, pending, failed & unknown statuses
- CPU & MEM usage/utilization
- Response latency
- Throughput per status & request type
- Workqueue

![Kube API Server Overview](/monitoring/docs/kube_api_server_overview.png)

[**Core DNS Overview**](/monitoring/terraform/04_dashboard_core_dns.tf)

- Collector node capacities & statuses
- Pods with running, pending, failed & unknown statuses
- CPU & MEM usage/utilization
- Response latency
- Throughput per IP type & rcode
- Rate of panics & cache hits

![Core DNS Overview](/monitoring/docs/coredns_overview.png)

[**Data Ingest Overview**](/monitoring/terraform/04_dashboard_data_ingest.tf)

- Ingest per telemetry type
- Ingest of Prometheus scraping
  - per jobs
  - per collector types

![Data Ingest Overview 1](/monitoring/docs/data_ingest_overview_1.png)
![Data Ingest Overview 2](/monitoring/docs/data_ingest_overview_2.png)

### Alerts

The alerts have predefined threshold. If those are not applicable for your use-cases, feel free to adapt them accordingly!

[**Nodes**](/monitoring/terraform/05_alert_node.tf)

- Status per instance remains not healthy for a certain amount of time
- CPU utilization per instance exceeding a certain limit for a certain amount of time
- Memory utilization per instance exceeding a certain limit for a certain amount of time
- Storage utilization per instance exceeding a certain limit for a certain amount of time

[**Pods**](/monitoring/terraform/05_alert_pod.tf)

- Status per instance remains not healthy for a certain amount of time
- CPU utilization per instance exceeding a certain limit for a certain amount of time
- Memory utilization per instance exceeding a certain limit for a certain amount of time

[**OTel Collector**](/monitoring/terraform/05_alert_otel_collector.tf)

- CPU utilization per instance exceeding a certain limit for a certain amount of time
- Memory utilization per instance exceeding a certain limit for a certain amount of time
- Queue utilization per instance exceeding a certain limit for a certain amount of time
- Dropped metrics/spans/logs per instance at least once
- Enqueue failures metrics/spans/logs per instance at least once
- Receive failures metrics/spans/logs per instance at least once
- Export failures metrics/spans/logs per instance at least once
