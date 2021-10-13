{{/* Referenced by the Deployment and Secret manifests when using infrastructure mode. */}}
{{- define "kubeconfig-secret-name" -}}
  {{ .Name | lower }}-kubeconfig-secret
{{- end -}}

{{/* Referenced by the Deployment manifest when using infrastructure mode. */}}
{{- define "kubeconfig-volume-name" -}}
  volume-{{ .Name | lower }}-kubeconfigs
{{- end -}}
