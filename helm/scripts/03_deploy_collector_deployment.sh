#!/bin/bash

### Set parameters
newrelicOtlpEndpoint="otlp.eu01.nr-data.net:4317"

### Set variables

# otelcollector
declare -A otelcollector
otelcollector["name"]="otelcollectordeploy"
otelcollector["namespace"]="monitoring"
otelcollector["prometheusPort"]=8888

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
  --set ports.prometheus.port=${otelcollector[prometheusPort]} \
  --set newrelic.opsteam.endpoint=$newrelicOtlpEndpoint \
  --set newrelic.opsteam.licenseKey=$NEWRELIC_LICENSE_KEY \
  "../charts/deployment"
