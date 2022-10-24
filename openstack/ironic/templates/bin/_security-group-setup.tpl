{{ define "ironic.security_group_setup_script" }}
eval $(
  cat /etc/ironic/ironic.conf | grep -Pzo '\[service_catalog\][^[]*' | tr -d '\000' | grep '='  |
  while read LINE; do var="${LINE% =*}"
  val="${LINE#*= }"
  echo export OS_${var^^}=${val}
  done)
export OS_IDENTITY_API_VERSION=3
region=`env|grep OS_AUTH_URL |awk '{split($1,a,".");print a[5]}'`
project_id=`openstack project show --domain default service -c id -f value`
#set quota to 4, should be sufficient, increase if not
# curl -X PUT --http1.1 -H "X-Auth-Token: $(openstack token issue -f value -c id)" https://limes-3.$region.cloud.sap/v1/domains/default/projects/$project_id -d "{\"project\": {\"id\": \"$project_id\", \"name\": \"service\", \"services\":[{\"type\": \"network\", \"resources\": [{\"category\": \"networking\", \"quota\": 4, \"name\": \"security_group_rules\"}], \"area\": \"network\"}], \"parent_id\": \"default\"}}'
security_group_id=`openstack security group list --project-domain default --project service -f csv --quote none -c ID -c Name | grep default | cut -d, -f1`

# Remove self-referential rules (ingress)
openstack security group rule list -f csv --quote none $security_group_id | grep $security_group_id | cut -d, -f1 | xargs -r openstack security group rule delete

if [ "`openstack security group rule list --ingress -f csv --quote none $security_group_id | grep -E ',,,,|,,0.0.0.0/0,,' | wc -l`" -eq 0 ]; then
    openstack security group rule create --project $project_id --ingress --ethertype IPv4 --protocol any $security_group_id || echo "Requires sufficiently recent openstack-cli"
fi
{{- end }}
