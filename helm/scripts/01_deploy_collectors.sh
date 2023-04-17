#!/bin/bash

### Set parameters
newrelicOtlpEndpoint="otlp.eu01.nr-data.net:4317"

### Set variables
declare -A nodeexporter
nodeexporter["name"]="nodeexporter"
nodeexporter["namespace"]="monitoring"

# otelcollectors
declare -A otelcollectors
otelcollectors["name"]="nr-otel"
otelcollectors["namespace"]="monitoring"
otelcollectors["deploymentPrometheusPort"]=8888
otelcollectors["daemonsetPrometheusPort"]=8888
otelcollectors["statefulsetPrometheusPort"]=8888

###################
### Deploy Helm ###
###################

# nodeexporter
# helm repo add bitnami https://charts.bitnami.com/bitnami
helm upgrade ${nodeexporter[name]} \
  --install \
  --wait \
  --debug \
  --create-namespace \
  --namespace ${nodeexporter[namespace]} \
  --set tolerations[0].key="node-role.kubernetes.io/master" \
  --set tolerations[0].operator="Exists" \
  --set tolerations[0].effect="NoSchedule" \
  --set tolerations[1].key="node-role.kubernetes.io/control-plane" \
  --set tolerations[1].operator="Exists" \
  --set tolerations[1].effect="NoSchedule" \
  bitnami/node-exporter

# otelcollector
helm upgrade ${otelcollectors[name]} \
  --install \
  --wait \
  --debug \
  --create-namespace \
  --namespace ${otelcollectors[namespace]} \
  --set name=${otelcollectors[name]} \
  --set traces.enabled=true \
  --set deployment.ports.prometheus.port=${otelcollectors[deploymentPrometheusPort]} \
  --set deployment.newrelic.opsteam.endpoint=$newrelicOtlpEndpoint \
  --set deployment.newrelic.opsteam.licenseKey=$NEWRELIC_LICENSE_KEY \
  --set logs.enabled=true \
  --set daemonset.ports.prometheus.port=${otelcollectors[daemonsetPrometheusPort]} \
  --set daemonset.newrelic.opsteam.endpoint=$newrelicOtlpEndpoint \
  --set daemonset.newrelic.opsteam.licenseKey=$NEWRELIC_LICENSE_KEY \
  --set metrics.enabled=true \
  --set statefulset.ports.prometheus.port=${otelcollectors[statefulsetPrometheusPort]} \
  --set statefulset.newrelic.opsteam.endpoint=$newrelicOtlpEndpoint \
  --set statefulset.newrelic.opsteam.licenseKey=$NEWRELIC_LICENSE_KEY \
  "../charts/collectors"
