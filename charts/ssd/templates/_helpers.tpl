{{/*
{{- define "imagePullSecret" }}
{{- with .Values.imageCredentials }}
{{- printf "{\"auths\":{\"%s\":{\"username\":\"%s\",\"password\":\"%s\",\"email\":\"%s\",\"auth\":\"%s\"}}}" .repoUrl .username .password .email (printf "%s:%s" .username .password | b64enc) | b64enc }}
{{- end }}
{{- end }}
*/}}

{{/*
Common labels for metadata.
*/}}
{{- define "ssd.standard-labels" -}}
heritage: {{ .Release.Service | quote }}
release: {{ .Release.Name | quote }}
chart: "{{ .Chart.Name }}-{{ .Chart.Version }}"
{{- if .Values.customLabels }}
{{ toYaml .Values.customLabels }}
{{- end }}
{{- end -}}

{{/*
Return the proper UI image name
*/}}
{{- define "ui.image" -}}
{{- $registryName := .Values.imageCredentials.registry -}}
{{- $repositoryName := .Values.ui.image.repository -}}
{{- $tag := .Values.ui.image.tag | toString -}}
{{- printf "%s/%s:%s" $registryName $repositoryName $tag -}}
{{- end -}}

{{/*
Return the proper sapor-db image name
*/}}
{{- define "db.image" -}}
{{- $registryName := .Values.imageCredentials.registry -}}
{{- $repositoryName := .Values.db.image.repository -}}
{{- $tag := .Values.db.image.tag | toString -}}
{{- printf "%s/%s:%s" $registryName $repositoryName $tag -}}
{{- end -}}

{{/*
Return the proper Tool Chain Image
*/}}
{{- define "toolchain.image" -}}
{{- $registryName := .Values.imageCredentials.registry -}}
{{- $repositoryName := .Values.toolchain.image.repository -}}
{{- $tag := .Values.toolchain.image.tag | toString -}}
{{- printf "%s/%s:%s" $registryName $repositoryName $tag -}}
{{- end -}}

{{/*
Return the proper Supplychain-api Image
*/}}
{{- define "supplychainapi.image" -}}
{{- $registryName := .Values.imageCredentials.registry -}}
{{- $repositoryName := .Values.supplychainapi.image.repository -}}
{{- $tag := .Values.supplychainapi.image.tag | toString -}}
{{- printf "%s/%s:%s" $registryName $repositoryName $tag -}}
{{- end -}}

{{/*
 Return the proper Supplychain-preprocessor Image
*/}}
 {{- define "supplychainpreprocessor.image" -}}
 {{- $registryName := .Values.imageCredentials.registry -}}
 {{- $repositoryName := .Values.supplychainpreprocessor.image.repository -}}
 {{- $tag := .Values.supplychainpreprocessor.image.tag | toString -}}
 {{- printf "%s/%s:%s" $registryName $repositoryName $tag -}}
 {{- end -}}

{{/*
 Return the proper ssd-opa Image
*/}}
 {{- define "ssdopa.image" -}}
 {{- $registryName := .Values.imageCredentials.registry -}}
 {{- $repositoryName := .Values.ssdopa.image.repository -}}
 {{- $tag := .Values.ssdopa.image.tag | toString -}}
 {{- printf "%s/%s:%s" $registryName $repositoryName $tag -}}
 {{- end -}}

{{/*
 Return the proper ssd-gate Image
*/}}
 {{- define "ssdgate.image" -}}
 {{- $registryName := .Values.imageCredentials.registry -}}
 {{- $repositoryName := .Values.ssdgate.image.repository -}}
 {{- $tag := .Values.ssdgate.image.tag | toString -}}
 {{- printf "%s/%s:%s" $registryName $repositoryName $tag -}}
 {{- end -}}

{{/*
 Return the proper dgraph Image
*/}}
 {{- define "dgraph.image" -}}
 {{- $registryName := .Values.imageCredentials.registry -}}
 {{- $repositoryName := .Values.dgraph.image.repository -}}
 {{- $tag := .Values.dgraph.image.tag | toString -}}
 {{- printf "%s/%s:%s" $registryName $repositoryName $tag -}}
 {{- end -}}

{{/*
 Return the proper ratel Image
*/}}
 {{- define "ratel.image" -}}
 {{- $registryName := .Values.imageCredentials.registry -}}
 {{- $repositoryName := .Values.ratel.image.repository -}}
 {{- $tag := .Values.ratel.image.tag | toString -}}
 {{- printf "%s/%s:%s" $registryName $repositoryName $tag -}}
 {{- end -}}


{{/*
 Return the proper Token-Machine Image
*/}}
 {{- define "tokenmachine.image" -}}
 {{- $registryName := .Values.imageCredentials.registry -}}
 {{- $repositoryName := .Values.tokenmachine.image.repository -}}
 {{- $tag := .Values.tokenmachine.image.tag | toString -}}
 {{- printf "%s/%s:%s" $registryName $repositoryName $tag -}}
 {{- end -}}

{{/*
 Return the proper Curl Image
*/}}
 {{- define "curl.image" -}}
 {{- $registryName := .Values.imageCredentials.registry -}}
 {{- $repositoryName := .Values.curl.image.repository -}}
 {{- $tag := .Values.curl.image.tag | toString -}}
 {{- printf "%s/%s:%s" $registryName $repositoryName $tag -}}
 {{- end -}}

{{/*
Return the proper kube-detector image name
*/}}
{{- define "kubedetector.image" -}}
{{- $registryName := .Values.imageCredentials.registry -}}
{{- $repositoryName := .Values.kubedetector.image.repository -}}
{{- $tag := .Values.kubedetector.image.tag | toString -}}
{{- printf "%s/%s:%s" $registryName $repositoryName $tag -}}
{{- end -}}


{{/* vim: set filetype=mustache: */}}
{{/*
Renders a value that contains template.
Usage:
{{ include "tplvalues.render" ( dict "value" .Values.path.to.the.Value "context" $) }}
*/}}
{{- define "tplvalues.render" -}}
    {{- if typeIs "string" .value }}
        {{- tpl .value .context }}
    {{- else }}
        {{- tpl (.value | toYaml) .context }}
    {{- end }}
{{- end -}}


{{/*
Redis base URL for Spinnaker
*/}}
{{- define "ssd.redisBaseURL" -}}
{{- if .Values.installRedis }}
{{- printf "redis://:%s@%s-redis-master:6379" .Values.redis.password .Release.Name -}}
{{- else if .Values.redis.external.password }}
{{- printf "redis://:%s@%s:%s" .Values.redis.external.password .Values.redis.external.host (.Values.redis.external.port | toString) -}}
{{- else }}
{{- printf "redis://%s:%s" .Values.redis.external.host (.Values.redis.external.port | toString) -}}
{{- end }}
{{- end }}


{{/*
Looks if there's an existing secret and reuses its password. If not, it generates
a new password and uses it.
*/}}
{{- define "getRabbitMQPassword" -}}
{{- $secret := (lookup "v1" "Secret" .Release.Namespace "rabbitmq-secret") -}}
{{- if and $secret (index $secret.data "rabbitmqPassword") }}
  {{- $existingPassword := index $secret.data "rabbitmqPassword" | b64dec }}
  {{- $existingPassword }}
{{- else -}}
{{- $newPassword := randAlphaNum 20 | b64enc }}
{{- $newPassword }}
{{- end -}}
{{- end -}}

