unified_mode true

# Cookbook:: drill
# Resource:: config

actions :add, :remove, :register, :deregister
default_action :add

attribute :user, kind_of: String, default: 'root'
attribute :s3_malware_secrets, kind_of: Hash, default: {}
attribute :s3_host, kind_of: String, default: 's3.service'
attribute :cdomain, kind_of: String, default: 'redborder.cluster'
attribute :truststore_password, kind_of: String, default: nil
attribute :drill_ips, kind_of: Array, default: ['127.0.0.1']
attribute :drill_port, kind_of: String, default: '8047'
attribute :ipaddress_sync, kind_of: String, default: '127.0.0.1'
