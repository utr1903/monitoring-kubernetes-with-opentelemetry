#!/bin/bash

### Set parameters
newrelicOtlpEndpoint="otlp.eu01.nr-data.net:4317"

### Set variables

# otelcollector
declare -A otelcollector
otelcollector["name"]="otelcollectormetrics"
otelcollector["namespace"]="monitoring"
otelcollector["mode"]="statefulset"
otelcollector["prometheusPort"]=9464

###################
### Deploy Helm ###
###################

# # Add helm repos
# helm repo add open-telemetry https://open-telemetry.github.io/opentelemetry-helm-charts
# helm repo update

# otelcollector
helm upgrade ${otelcollector[name]} \
  --install \
  --wait \
  --debug \
  --create-namespace \
  --namespace ${otelcollector[namespace]} \
  --set name=${otelcollector[name]} \
  --set mode=${otelcollector[mode]} \
  --set prometheus.port=${otelcollector[prometheusPort]} \
  --set newrelicOtlpEndpoint=$newrelicOtlpEndpoint \
  --set newrelicLicenseKey=$NEWRELIC_LICENSE_KEY \
  "../charts/metrics"

# # prometheus
# clusterName="mytestcluster"
# helm upgrade "prometheus" \
#   --install \
#   --wait \
#   --debug \
#   --create-namespace \
#   --namespace "monitoring" \
#   --set alertmanager.enabled=false \
#   --set prometheus-pushgateway.enabled=false \
#   --set kubeStateMetrics.enabled=true \
#   --set nodeExporter.enabled=true \
#   --set nodeExporter.tolerations[0].effect="NoSchedule" \
#   --set nodeExporter.tolerations[0].operator="Exists" \
#   --set server.remoteWrite[0].url="https://metric-api.eu.newrelic.com/prometheus/v1/write?prometheus_server=${clusterName}" \
#   --set server.remoteWrite[0].bearer_token=$NEWRELIC_LICENSE_KEY \
#   "prometheus-community/prometheus"

# # Flags for agent mode
# --set server.defaultFlagsOverride[0]="--enable-feature=agent" \
# --set server.defaultFlagsOverride[1]="--storage.agent.retention.max-time=30m" \
