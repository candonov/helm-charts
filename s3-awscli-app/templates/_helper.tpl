{{/* Define a template to generate the name of the application */}}
{{- define "s3-awscli-app.name" -}}
{{- default "s3-awscli-app" }}
{{- end }}

{{/* Define a template to generate the name and version of the chart */}}
{{- define "s3-awscli-app.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version }}
{{- end }}
