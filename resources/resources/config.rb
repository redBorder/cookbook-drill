unified_mode true

# Cookbook:: drill
# Resource:: config

actions :add, :remove, :register, :deregister
default_action :add

attribute :user, kind_of: String, default: 'root'
attribute :s3_malware_secrets, kind_of: Hash, default: {}
attribute :drill_ips, kind_of: Array, default: ['127.0.0.1']
attribute :drill_port, kind_of: String, default: '8047'
