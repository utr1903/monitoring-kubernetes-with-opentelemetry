##############
### Alerts ###
##############

# Policy
resource "newrelic_alert_policy" "pod" {
  name                = "K8s | ${var.cluster_name} | Pods"
  incident_preference = "PER_CONDITION"
}

# Condition - Status
resource "newrelic_nrql_alert_condition" "pod_status" {
  account_id                   = var.NEW_RELIC_ACCOUNT_ID
  policy_id                    = newrelic_alert_policy.pod.id
  type                         = "static"
  name                         = "Pod status"
  enabled                      = true
  violation_time_limit_seconds = 86400

  nrql {
    query = "FROM Metric SELECT latest(kube_pod_status_phase) AS `failed` WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-kube-state-metrics' AND phase != 'Running' FACET pod"
  }

  critical {
    operator              = "above"
    threshold             = 0
    threshold_duration    = 300
    threshold_occurrences = "all"
  }
  fill_option        = "none"
  aggregation_window = 60
  aggregation_method = "event_timer"
  aggregation_timer  = 5
}

# Condition - CPU utilization too high
resource "newrelic_nrql_alert_condition" "pod_cpu_utilization_high" {
  account_id                   = var.NEW_RELIC_ACCOUNT_ID
  policy_id                    = newrelic_alert_policy.pod.id
  type                         = "static"
  name                         = "CPU utilization too high"
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

# Condition - CPU utilization too low
resource "newrelic_nrql_alert_condition" "pod_cpu_utilization_low" {
  account_id                   = var.NEW_RELIC_ACCOUNT_ID
  policy_id                    = newrelic_alert_policy.pod.id
  type                         = "static"
  name                         = "CPU utilization too low"
  enabled                      = true
  violation_time_limit_seconds = 86400

  nrql {
    query = "FROM Metric SELECT rate(filter(sum(container_cpu_usage_seconds), WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-nodes-cadvisor'), 1 second) / filter(max(kube_pod_container_resource_requests), WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-kube-state-metrics' AND resource = 'cpu') WHERE container IS NOT NULL AND pod IS NOT NULL FACET pod, container"
  }

  critical {
    operator              = "below"
    threshold             = 0.5
    threshold_duration    = 21600
    threshold_occurrences = "all"
  }
  fill_option        = "none"
  aggregation_window = 60
  aggregation_method = "event_flow"
  aggregation_delay  = 0
}

# Condition - MEM utilization too high
resource "newrelic_nrql_alert_condition" "pod_mem_utilization_high" {
  account_id                   = var.NEW_RELIC_ACCOUNT_ID
  policy_id                    = newrelic_alert_policy.pod.id
  type                         = "static"
  name                         = "MEM utilization too high"
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

# Condition - MEM utilization too low
resource "newrelic_nrql_alert_condition" "pod_mem_utilization_low" {
  account_id                   = var.NEW_RELIC_ACCOUNT_ID
  policy_id                    = newrelic_alert_policy.pod.id
  type                         = "static"
  name                         = "MEM utilization too low"
  enabled                      = true
  violation_time_limit_seconds = 86400

  nrql {
    query = "FROM Metric SELECT filter(average(container_memory_usage_bytes), WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-nodes-cadvisor') / filter(max(kube_pod_container_resource_requests), WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-kube-state-metrics' AND resource = 'memory') WHERE container IS NOT NULL AND pod IS NOT NULL FACET pod, container"
  }

  critical {
    operator              = "below"
    threshold             = 0.5
    threshold_duration    = 21600
    threshold_occurrences = "all"
  }
  fill_option        = "none"
  aggregation_window = 60
  aggregation_method = "event_flow"
  aggregation_delay  = 0
}
