##############
### Alerts ###
##############

# Policy - pod resource consumption
resource "newrelic_alert_policy" "pod_resource_consumption" {
  name                = "K8s | ${var.cluster_name} | Pods - Resource Consumption"
  incident_preference = "PER_CONDITION"
}

# Condition - pod cpu utilization
resource "newrelic_nrql_alert_condition" "pod_cpu_utilization" {
  account_id                   = var.NEW_RELIC_ACCOUNT_ID
  policy_id                    = newrelic_alert_policy.pod_resource_consumption.id
  type                         = "static"
  name                         = "CPU Utilization"
  enabled                      = true
  violation_time_limit_seconds = 86400

  nrql {
    query = "FROM Metric SELECT rate(filter(sum(container_cpu_usage_seconds), WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-nodes-cadvisor'), 1 second) / filter(max(kube_pod_container_resource_limits), WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-kube-state-metrics' AND resource = 'cpu') * 100 WHERE container IS NOT NULL AND pod IS NOT NULL FACET pod, container"
  }

  critical {
    operator              = "above"
    threshold             = 90
    threshold_duration    = 300
    threshold_occurrences = "all"
  }

  warning {
    operator              = "above"
    threshold             = 75
    threshold_duration    = 300
    threshold_occurrences = "all"
  }
  fill_option        = "none"
  aggregation_window = 60
  aggregation_method = "event_flow"
  aggregation_delay  = 0
}

# Condition - pod mem utilization
resource "newrelic_nrql_alert_condition" "pod_mem_utilization" {
  account_id                   = var.NEW_RELIC_ACCOUNT_ID
  policy_id                    = newrelic_alert_policy.pod_resource_consumption.id
  type                         = "static"
  name                         = "MEM Utilization"
  enabled                      = true
  violation_time_limit_seconds = 86400

  nrql {
    query = "FROM Metric SELECT filter(average(container_memory_usage_bytes), WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-nodes-cadvisor') / filter(max(kube_pod_container_resource_limits), WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-kube-state-metrics' AND resource = 'memory') * 100 WHERE container IS NOT NULL AND pod IS NOT NULL FACET pod, container"
  }

  critical {
    operator              = "above"
    threshold             = 90
    threshold_duration    = 300
    threshold_occurrences = "all"
  }

  warning {
    operator              = "above"
    threshold             = 75
    threshold_duration    = 300
    threshold_occurrences = "all"
  }
  fill_option        = "none"
  aggregation_window = 60
  aggregation_method = "event_flow"
  aggregation_delay  = 0
}
