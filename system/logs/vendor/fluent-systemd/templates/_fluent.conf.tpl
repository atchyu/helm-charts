# Pick up all the auto-generated input config files, one for each file
# specified in the FILES_TO_COLLECT environment variable.
@include files/*

<system>
  log_level warn
</system>

# All the auto-generated files should use the tag "file.<filename>".
<source>
  @type systemd
  path /var/log/journal
  <storage>
    @type local
    persistent true
    path /var/log/journal.pos
  </storage>
  tag systemd
  read_from_head true
</source>

<label @FLUENT_LOG>
  <match fluent.*>
    @type null
  </match>
</label>

# prometheus monitoring config

@include /fluentd/etc/prometheus.conf

<filter **>
  @type systemd_entry
#  field_map {"MESSAGE": "log", "_PID": ["process", "pid"], "_CMDLINE": "process", "_COMM": "cmd"}
#  field_map_strict false
  fields_lowercase true
  fields_strip_underscores true
</filter>

<match **>
  @type copy
  <store>
    @type elasticsearch
{{- if eq .Values.global.clusterType  "scaleout" }}
    host {{.Values.endpoint_host_internal}}
    port {{.Values.http_port}}
{{- else }}
    host {{.Values.global.elk_elasticsearch_endpoint_host_scaleout}}.{{.Values.global.elk_cluster_region}}.{{.Values.global.tld}}
    port {{.Values.global.elk_elasticsearch_ssl_port}}
    scheme https
    ssl_verify false
    ssl_version TLSv1_2
{{- end }}
    user {{.Values.global.elk_elasticsearch_data_user}}
    password {{.Values.global.elk_elasticsearch_data_password}}
    index_name systemd
    type_name _doc
    logstash_prefix systemd
    logstash_format true
    template_name systemd
    template_file /fluentd/etc/systemd.json
    template_overwrite true
    time_as_integer false
    @log_level info
    slow_flush_log_threshold 50.0
    request_timeout 60s
    include_tag_key true
    resurrect_after 120
    reconnect_on_error true
    reload_connections false
    reload_on_failure true
    <buffer>
      flush_at_shutdown true
      flush_thread_interval 5
      overflow_action block
      retry_forever true
      retry_wait 2s
      flush_thread_count 4
      flush_interval 3s
    </buffer>
  </store>
{{- if .Values.opensearch.enabled }}
  <store>
    @type opensearch
  {{- if eq .Values.global.clusterType  "scaleout" }}
    host {{.Values.opensearch.http.endpoint}}
  {{- else }}
    hosts {{.Values.opensearch.http.endpoint}}.{{.Values.global.region}}.{{.Values.global.tld}}
  {{- end }}
    port {{.Values.opensearch.http_port}}
    scheme https
    ssl_verify false
    ssl_version TLSv1_2
    user {{.Values.opensearch.user}}
    password {{.Values.opensearch.password}}
    index_name systemd
    logstash_prefix systemd
    logstash_format true
    template_name systemd
    template_file /fluentd/etc/systemd.json
    template_overwrite true
    time_as_integer false
    @log_level info
    slow_flush_log_threshold 50.0
    request_timeout 60s
    include_tag_key true
    resurrect_after 120
    reconnect_on_error true
    reload_connections false
    reload_on_failure true
    suppress_type_name true
    <buffer>
      flush_at_shutdown true
      flush_thread_interval 5
      overflow_action block
      retry_forever true
      retry_wait 2s
      flush_thread_count 4
      flush_interval 3s
    </buffer>
  </store>
{{- end }}
  <store>
    @type prometheus
    <metric>
      name fluentd_output_status_num_records_total
      type counter
      desc The total number of outgoing records
      <labels>
        nodename "#{ENV['NODENAME']}"
      </labels>
    </metric>
  </store>
</match>
