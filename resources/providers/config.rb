# Cookbook:: drill
# Provider:: config

include Drill::Helper

action :add do
  begin
    user = new_resource.user
    s3_malware_secrets = new_resource.s3_malware_secrets
    ipaddress = new_resource.ipaddress


    # Crear usuario y grupo primero
    group 'drill' do
      system true
      action :create
    end

    unless s3_malware_secrets.empty?
      s3_malware_bucket = s3_malware_secrets['s3_malware_bucket']
      s3_malware_host = s3_malware_secrets['s3_malware_host']
      s3_malware_access_key = s3_malware_secrets['s3_malware_access_key_id']
      s3_malware_secret_key = s3_malware_secrets['s3_malware_secret_key_id']
    end

    user 'drill' do
      system true
      group 'drill'
      home '/opt/drill'
      shell '/sbin/nologin'
      comment 'Apache Drill'
      action :create
    end

    dnf_package "apache-drill" do
      action :upgrade
    end

    ['/var/log/drill', '/run/drill', '/etc/drill/conf'].each do |dir|
      directory dir do
        owner 'drill'
        group 'drill'
        mode '0755'
        recursive true
      end
    end

    execute 'set_drill_permissions' do
      command 'chown -R drill:drill /opt/drill && chmod 755 /opt/drill/bin/*'
      not_if 'stat -c %U /opt/drill | grep -q drill'
    end

    template "/etc/drill/conf/drill-env.sh" do
      cookbook 'drill'
      source 'drill_drill-env.sh.erb'
      owner 'drill'
      group 'drill'
      mode "0644"
      variables(
        java_home: node['drill']['java_home'] || '/usr/lib/jvm/java-1.8.0',
        drill_pid_dir: '/run/drill',
        drill_log_dir: '/var/log/drill'
      )
      notifies :restart, 'service[drill]', :delayed
    end

    template "/etc/drill/conf/drill-override.conf" do
      cookbook 'drill'
      source 'drill_drill-override.conf.erb'
      owner 'drill'
      group 'drill'
      mode "0644"
      variables(
        ipaddress: ipaddress,
      )
      notifies :restart, 'service[drill]', :delayed
    end

    template "/etc/drill/conf/logback.xml" do
      cookbook 'drill'
      source 'drill_logback.xml.erb'
      owner 'drill'
      group 'drill'
      mode "0644"
      notifies :restart, 'service[drill]', :delayed
    end

    template "/etc/drill/conf/core-site.xml" do
      cookbook 'drill'
      source 'drill_core-site.xml.erb'
      owner 'drill'
      group 'drill'
      mode "0644"
      variables(
        access_key_id: s3_malware_access_key,
        secret_access_key: s3_malware_secret_key,
        s3_host: s3_malware_host
      )
      notifies :restart, 'service[drill]', :delayed
    end

    template "/etc/drill/conf/storage-plugins-override.conf" do
      cookbook 'drill'
      source 'drill_storage-plugins-override.conf.erb'
      owner 'drill'
      group 'drill'
      mode "0644"
      notifies :restart, 'service[drill]', :delayed
      variables(
        s3_host: s3_malware_host,
        s3_access_key: s3_malware_access_key,
        s3_secret_key: s3_malware_secret_key,
      )
    end



    service "drill" do
      service_name "drill"
      supports :status => true, :reload => true, :restart => true, :enable => true
      action [:enable, :start]
    end

    Chef::Log.info('Drill cookbook has been processed successfully')
  rescue => e
    Chef::Log.error(e.message)
    raise
  end
end

action :remove do
  begin
    service "drill" do
      service_name "drill"
      supports :status => true, :enable => true
      action [:stop, :disable]
    end

    dnf_package "apache-drill" do
      action :remove
    end

    Chef::Log.info('Drill cookbook has been processed successfully')
  rescue => e
    Chef::Log.error(e.message)
    raise
  end
end

action :register do
  begin
    ipaddress = new_resource.ipaddress

    unless node['drill']['registered']
      query = {}
      query['ID'] = "drill-#{node['hostname']}"
      query['Name'] = 'drill'
      query['Address'] = ipaddress
      query['Port'] = 3000
      json_query = Chef::JSONCompat.to_json(query)

      execute 'Register service in consul' do
        command "curl -X PUT http://localhost:8500/v1/agent/service/register -d '#{json_query}' &>/dev/null"
        action :nothing
      end.run_action(:run)

      node.override['drill']['registered'] = true
      Chef::Log.info('drill service has been registered to consul')
    end
  rescue => e
    Chef::Log.error(e.message)
  end
end

action :deregister do
  begin
    if node['drill']['registered']
      execute 'Deregister service in Consul' do
        command "curl -X PUT http://localhost:8500/v1/agent/service/deregister/drill-#{node['hostname']} &> /dev/null"
        action :nothing
      end.run_action(:run)
    end

    node.override['drill']['registered'] = false
    Chef::Log.info('Drill service has been deregistered from Consul')
  rescue => e
    Chef::Log.error(e.message)
  end
end