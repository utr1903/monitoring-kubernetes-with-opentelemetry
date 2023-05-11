##############
### Alerts ###
##############

# Policy - node resource consumption
resource "newrelic_alert_policy" "node" {
  name                = "K8s | ${var.cluster_name} | Nodes - Resource Consumption"
  incident_preference = "PER_CONDITION"
}

# Condition - node status
resource "newrelic_nrql_alert_condition" "node_status" {
  account_id                   = var.NEW_RELIC_ACCOUNT_ID
  policy_id                    = newrelic_alert_policy.node.id
  type                         = "static"
  name                         = "Node Status"
  enabled                      = true
  violation_time_limit_seconds = 86400

  nrql {
    query = "FROM Metric SELECT latest(up) WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-node-exporter' FACET k8s.node.name"
  }

  critical {
    operator              = "below"
    threshold             = 1
    threshold_duration    = 300
    threshold_occurrences = "all"
  }
  fill_option        = "none"
  aggregation_window = 60
  aggregation_method = "event_timer"
  aggregation_timer  = 5
}

# Condition - node cpu utilization
resource "newrelic_nrql_alert_condition" "node_cpu_utilization" {
  account_id                   = var.NEW_RELIC_ACCOUNT_ID
  policy_id                    = newrelic_alert_policy.node.id
  type                         = "static"
  name                         = "CPU Utilization"
  enabled                      = true
  violation_time_limit_seconds = 86400

  nrql {
    query = "FROM Metric SELECT rate(filter(sum(node_cpu_seconds), WHERE mode != 'idle'), 1 SECONDS)/uniqueCount(cpu)*100 WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-node-exporter' FACET k8s.node.name"
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

# Condition - node mem utilization
resource "newrelic_nrql_alert_condition" "node_mem_utilization" {
  account_id                   = var.NEW_RELIC_ACCOUNT_ID
  policy_id                    = newrelic_alert_policy.node.id
  type                         = "static"
  name                         = "MEM Utilization"
  enabled                      = true
  violation_time_limit_seconds = 86400

  nrql {
    query = "FROM Metric SELECT rate(filter(sum(node_cpu_seconds), WHERE mode != 'idle'), 1 SECONDS)/uniqueCount(cpu)*100 WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-node-exporter' FACET k8s.node.name"
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

# Condition - node sto utilization
resource "newrelic_nrql_alert_condition" "node_sto_utilization" {
  account_id                   = var.NEW_RELIC_ACCOUNT_ID
  policy_id                    = newrelic_alert_policy.node.id
  type                         = "static"
  name                         = "STO Utilization"
  enabled                      = true
  violation_time_limit_seconds = 86400

  nrql {
    query = "SELECT (1 - (average(node_filesystem_avail_bytes) / average(node_filesystem_size_bytes))) * 100 FROM Metric WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-node-exporter' FACET k8s.node.name"
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
