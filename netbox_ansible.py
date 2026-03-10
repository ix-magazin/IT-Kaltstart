plugin: netbox.netbox.nb_inventory
api_endpoint: https://cmdb.case.org/
token: <YOUR_TOKEN>
validate_certs: true

# cache: yes
# cache_plugin: jsonfile
# cache_connection: ".inventorycache"
config_context: true

flatten_config_context: true

query_filters:
  - tag: "conductor-server"

fetch_all: false
interfaces: true
site_data: true

groups:
  netbox: true
compose:
  ansible_host: "'{}.infra.case.org'.format(name)"
group_by:
  - tags
  - platforms
  - tenants
