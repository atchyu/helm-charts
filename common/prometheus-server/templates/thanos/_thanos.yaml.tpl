{{- $name := index . 0 -}}
{{- $root := index . 1 -}}
type: SWIFT
config:
  auth_url: {{ required "$root.Values.thanos.swiftStorageConfig.authURL missing" $root.Values.thanos.swiftStorageConfig.authURL | quote }}
  username: {{ include "prometheus.fullName" (list $name $root) }}-thanos
  domain_name: {{ required "$root.Values.thanos.swiftStorageConfig.userDomainName missing" $root.Values.thanos.swiftStorageConfig.userDomainName | quote }}
  password: {{ required "$root.Values.thanos.swiftStorageConfig.password missing" $root.Values.thanos.swiftStorageConfig.password | quote }}
  project_name: {{ include "thanos.projectName" $root }}
  project_domain_name: {{ include "thanos.projectDomainName" $root }}
  region_name: {{ required "$root.Values.global.region missing" $root.Values.global.region }}
  container_name: {{ include "prometheus.fullName" (list $name $root) }}-thanos
  {{ if $root.Values.thanos.swiftStorageConfig.projectDomainName }}
  project_domain_name: {{ $root.Values.thanos.swiftStorageConfig.projectDomainName | quote }}
  {{ end }}
