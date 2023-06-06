{{/*
Expand the name of the chart.
*/}}
{{- define "nrotel.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Set name for deployment collectors.
*/}}
{{- define "nrotel.deploymentName" -}}
{{- printf "%s-%s" (include "nrotel.name" .) "dep" | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- define "nrotel.deploymentNameReceiver" -}}
{{- printf "%s-%s" (include "nrotel.deploymentName" .) "rec" | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- define "nrotel.deploymentNameExporter" -}}
{{- printf "%s-%s" (include "nrotel.deploymentName" .) "exp" | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- define "nrotel.headlessServiceNameExporter" -}}
{{- printf "%s-%s.%s.%s" (include "nrotel.deploymentNameExporter" .) "collector-headless" .Release.Namespace "svc.cluster.local" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Set name for daemonset collectors.
*/}}
{{- define "nrotel.daemonsetName" -}}
{{- printf "%s-%s" (include "nrotel.name" .) "ds" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Set name for statefulset collectors.
*/}}
{{- define "nrotel.statefulsetName" -}}
{{- printf "%s-%s" (include "nrotel.name" .) "sts" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Set name for node-exporter service discovery.
*/}}
{{- define "nrotel.nodeExporterServiceName" -}}
{{- if .Values.statefulset.prometheus.nodeExporter.serviceNameRef -}}
{{- printf "%s" .Values.statefulset.prometheus.nodeExporter.serviceNameRef | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" (include "nrotel.name" .) "prometheus-node-exporter" | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/*
Set name for kube-state-metrics service discovery.
*/}}
{{- define "nrotel.kubeStateMetricsServiceName" -}}
{{- if .Values.statefulset.prometheus.kubeStateMetrics.serviceNameRef -}}
{{- printf "%s" .Values.statefulset.prometheus.kubeStateMetrics.serviceNameRef | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" (include "nrotel.name" .) "kube-state-metrics" | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
