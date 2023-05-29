#!/bin/bash

# Get commandline arguments
while (( "$#" )); do
  case "$1" in
    --case)
      case="$2"
      shift
      ;;
    *)
      shift
      ;;
  esac
done

### Set variables

# cluster name
clusterName="my-dope-cluster"

# otelcollectors
declare -A otelcollectors
otelcollectors["name"]="nr-otel"
otelcollectors["namespace"]="monitoring"

### Case 01 - Cluster name should be defined
if [[ $case == "01" ]]; then
  result=$(helm template ${otelcollectors[name]} \
    --create-namespace \
    --namespace ${otelcollectors[namespace]} \
    "../../helm/charts/collectors" \
    2> /dev/null)
fi

### Case 02 - At least 1 telemetry type should be enabled
if [[ $case == "02" ]]; then
  result=$(helm template ${otelcollectors[name]} \
    --create-namespace \
    --namespace ${otelcollectors[namespace]} \
    --set clusterName=$clusterName \
    --set traces.enabled=false \
    --set logs.enabled=false \
    --set metrics.enabled=false \
    "../../helm/charts/collectors" \
    2> /dev/null)
fi

### Case 03, 04, 05 - New Relic account should be defined

# Deployment
if [[ $case == "03" ]]; then
  result=$(helm template ${otelcollectors[name]} \
    --create-namespace \
    --namespace ${otelcollectors[namespace]} \
    --set clusterName=$clusterName \
    --set traces.enabled=true \
    --set deployment.newrelic=null \
    --set logs.enabled=false \
    --set metrics.enabled=false \
    "../../helm/charts/collectors" \
    2> /dev/null)
fi

# Daemonset
if [[ $case == "04" ]]; then
  result=$(helm template ${otelcollectors[name]} \
    --create-namespace \
    --namespace ${otelcollectors[namespace]} \
    --set clusterName=$clusterName \
    --set traces.enabled=false \
    --set logs.enabled=true \
    --set daemonset.newrelic=null \
    --set metrics.enabled=false \
    "../../helm/charts/collectors" \
    2> /dev/null)
fi

# Statefulset
if [[ $case == "05" ]]; then
  result=$(helm template ${otelcollectors[name]} \
    --create-namespace \
    --namespace ${otelcollectors[namespace]} \
    --set clusterName=$clusterName \
    --set traces.enabled=true \
    --set logs.enabled=false \
    --set metrics.enabled=true \
    --set statefulset.newrelic=null \
    "../../helm/charts/collectors" \
    2> /dev/null)
fi

### Case 06, 07, 08 - OTLP endpoint should be valid

# Deployment
if [[ $case == "06" ]]; then
  result=$(helm template ${otelcollectors[name]} \
    --create-namespace \
    --namespace ${otelcollectors[namespace]} \
    --set clusterName=$clusterName \
    --set traces.enabled=true \
    --set deployment.newrelic.opsteam.endpoint="INVALID_ENDPOINT" \
    --set logs.enabled=false \
    --set metrics.enabled=false \
    "../../helm/charts/collectors" \
    2> /dev/null)
fi

# Daemonset
if [[ $case == "07" ]]; then
  result=$(helm template ${otelcollectors[name]} \
    --create-namespace \
    --namespace ${otelcollectors[namespace]} \
    --set clusterName=$clusterName \
    --set traces.enabled=false \
    --set logs.enabled=true \
    --set daemonset.newrelic.opsteam.endpoint="INVALID_ENDPOINT" \
    --set metrics.enabled=false \
    "../../helm/charts/collectors" \
    2> /dev/null)
fi

# Statefulset
if [[ $case == "08" ]]; then
  result=$(helm template ${otelcollectors[name]} \
    --create-namespace \
    --namespace ${otelcollectors[namespace]} \
    --set clusterName=$clusterName \
    --set traces.enabled=true \
    --set logs.enabled=false \
    --set metrics.enabled=true \
    --set daemonsetstatefulset.newrelic.opsteam.endpoint="INVALID_ENDPOINT" \
    "../../helm/charts/collectors" \
    2> /dev/null)
fi

### Case 09, 10, 11 - Invalid license key

# Deployment
if [[ $case == "09" ]]; then
  result=$(helm template ${otelcollectors[name]} \
    --create-namespace \
    --namespace ${otelcollectors[namespace]} \
    --set clusterName=$clusterName \
    --set traces.enabled=true \
    --set deployment.newrelic.opsteam.endpoint="otlp.nr-data.net:4317" \
    --set logs.enabled=false \
    --set metrics.enabled=false \
    "../../helm/charts/collectors" \
    2> /dev/null)
fi

# Daemonset
if [[ $case == "10" ]]; then
  result=$(helm template ${otelcollectors[name]} \
    --create-namespace \
    --namespace ${otelcollectors[namespace]} \
    --set clusterName=$clusterName \
    --set traces.enabled=false \
    --set logs.enabled=true \
    --set daemonset.newrelic.opsteam.endpoint="otlp.nr-data.net:4317" \
    --set metrics.enabled=false \
    "../../helm/charts/collectors" \
    2> /dev/null)
fi

# Statefulset
if [[ $case == "11" ]]; then
  result=$(helm template ${otelcollectors[name]} \
    --create-namespace \
    --namespace ${otelcollectors[namespace]} \
    --set clusterName=$clusterName \
    --set traces.enabled=false \
    --set logs.enabled=false \
    --set metrics.enabled=true \
    --set statefulset.newrelic.opsteam.endpoint="otlp.nr-data.net:4317" \
    "../../helm/charts/collectors" \
    2> /dev/null)
fi

if [[ $result != "" ]]; then
  echo "Validation failed!"
  exit 1
fi
