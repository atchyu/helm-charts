---
_meta:
  type: "config"
  config_version: 2

config:
  dynamic:
    http:
      anonymous_auth_enabled: false
      xff:
        enabled: false
    authc:
      basic_internal_auth_domain:
        description: "Authenticate via HTTP Basic against internal users database"
        http_enabled: true
        transport_enabled: true
        order: 1
        http_authenticator:
          type: basic
          challenge: true
        authentication_backend:
          type: intern
      saml_auth:
        order: 2
        description: "SAML provider"
        http_enabled: true
        transport_enabled: false
        http_authenticator:
          type: saml
          challenge: false
          config:
            idp:
              entity_id: "https://{{.Values.auth.provider }}"
              metadata_file: certs/metadata.xml
            sp:
              entity_id: "https://{{.Values.clusterName }}.{{.Values.global.clusterType }}.{{.Values.global.region }}.{{.Values.global.domain }}"
            kibana_url: "{{.Values.clusterName }}.{{.Values.global.clusterType }}.{{.Values.global.region }}.{{.Values.global.domain }}"
            subject_key: name
            roles_key: Roles
        authentication_backend:
          type: noop
      ldap_auth:
        order: 3
        description: "Authenticate using LDAP"
        http_enabled: true
        transport_enabled: true
        http_authenticator:
          type: basic
          challenge: false
        authentication_backend:
          type: ldap
          config:
            enable_ssl: true
            enable_start_tls: false
            enable_ssl_client_auth: false
            verify_hostnames: false
            hosts:
            - {{ .Values.global.ldap.host }}:{{ .Values.global.ldap.port }}
            bind_dn: {{ .Values.global.ldap.bind_dn }},{{ .Values.global.ldap.suffix }}
            password: {{ .Values.global.ldap.password }}
            userbase: '{{ .Values.global.ldap.user_search_base_dns }}'
            usersearch: '(sAMAccountName={0})'
            username_attribute: null
    authz:
      roles_ldap:
        description: "Authorize via LDAP or Active Directory"
        http_enabled: true
        transport_enabled: true
        authorization_backend:
          type: ldap
          config:
            enable_ssl: true
            enable_start_tls: false
            enable_ssl_client_auth: false
            verify_hostnames: false
            hosts:
            - {{ .Values.global.ldap.host }}:{{ .Values.global.ldap.port }}
            bind_dn: {{.Values.global.ldap.bind_dn}},{{ .Values.global.ldap.suffix }}
            password: {{ .Values.global.ldap.password }}
            rolebase: '{{ .Values.global.ldap.group_search_base_dns }},{{ .Values.global.ldap.suffix }}'
            rolesearch: '(member={0})'
            userroleattribute: null
            userrolename: disabled
            rolename: cn
            resolve_nested_roles: false
            userbase: '{{ .Values.global.ldap.user_search_base_dns }}'
            usersearch: '(uid={0})'
            skip_users:
            {{- range .Values.nonldap.users }}
            - {{ . | title | lower }}
            {{- end }}    
