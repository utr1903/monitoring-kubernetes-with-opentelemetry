#!/bin/bash

### Set parameters
newrelicOtlpEndpoint="otlp.eu01.nr-data.net:4317"

### Set variables

# cluster name
clusterName="my-dope-cluster"

# kubestatemetrics
declare -A kubestatemetrics
kubestatemetrics["name"]="kubestatemetrics"
kubestatemetrics["namespace"]="monitoring"

# nodeexporter
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

# Repositories
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# nodeexporter
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
  "bitnami/node-exporter"

# kubestatemetrics
helm upgrade ${kubestatemetrics[name]} \
  --install \
  --wait \
  --debug \
  --create-namespace \
  --namespace ${kubestatemetrics[namespace]} \
  --set autosharding.enabled=true \
  "prometheus-community/kube-state-metrics"

# otelcollector
helm upgrade ${otelcollectors[name]} \
  --install \
  --wait \
  --debug \
  --create-namespace \
  --namespace ${otelcollectors[namespace]} \
  --set name=${otelcollectors[name]} \
  --set clusterName=$clusterName \
  --set traces.enabled=true \
  --set deployment.ports.prometheus.port=${otelcollectors[deploymentPrometheusPort]} \
  --set deployment.newrelic.opsteam.endpoint=$newrelicOtlpEndpoint \
  --set deployment.newrelic.opsteam.licenseKey.value=$NEWRELIC_LICENSE_KEY \
  --set logs.enabled=true \
  --set daemonset.ports.prometheus.port=${otelcollectors[daemonsetPrometheusPort]} \
  --set daemonset.newrelic.opsteam.endpoint=$newrelicOtlpEndpoint \
  --set deployment.newrelic.opsteam.licenseKey.value=$NEWRELIC_LICENSE_KEY \
  --set metrics.enabled=true \
  --set statefulset.ports.prometheus.port=${otelcollectors[statefulsetPrometheusPort]} \
  --set statefulset.newrelic.opsteam.endpoint=$newrelicOtlpEndpoint \
  --set statefulset.newrelic.opsteam.licenseKey.value=$NEWRELIC_LICENSE_KEY \
  "../charts/collectors"
