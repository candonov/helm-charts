{{/* Define a template to generate the name of the application */}}
{{- define "demo-app.name" -}}
{{- default "demo-app" }}
{{- end }}

{{/* Define a template to generate the name and version of the chart */}}
{{- define "demo-app.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version }}
{{- end }}
