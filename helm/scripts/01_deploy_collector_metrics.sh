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
