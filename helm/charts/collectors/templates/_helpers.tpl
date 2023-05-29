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
{{- printf "%s-%s.%s.%s" (include "nrotel.deploymentNameExporter" .) "-collector-headless" "{{ .Release.Namespace }}" "svc.cluster.local" | trunc 63 | trimSuffix "-" -}}
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
