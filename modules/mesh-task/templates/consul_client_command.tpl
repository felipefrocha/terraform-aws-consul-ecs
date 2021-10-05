ECS_IPV4=$(curl -s $ECS_CONTAINER_METADATA_URI_V4 | jq -r '.Networks[0].IPv4Addresses[0]')

%{ if tls ~}
echo "$CONSUL_CACERT" > /tmp/consul-ca-cert.pem
%{ endif ~}

exec consul agent \
%{ for key, val in consul_agent_options ~}
%{ if val != null ~}
  -${key} "${replace(val, "\"", "\\\"")}" \
%{ endif ~}
%{ endfor ~}
%{ if user_hcl != "" ~}
  -hcl "${replace(user_hcl, "\"", "\\\"")}" \
%{ endif ~}