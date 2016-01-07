
 # Cookbook Name:: geoserver
 # Recipe:: default


include_recipe 'java'
include_recipe 'tomcat::default'
#include_recipe 'geoserver::install_fonts'

apt_repository 'ubuntugis-unstable' do
  uri          'ppa:ubuntugis/ubuntugis-unstable'
  distribution node['lsb']['codename']
end

package "unzip"
package "curl"
package "gdal-bin"
package "postgresql" #for psql

url = "http://sourceforge.net/projects/geoserver/files/GeoServer/#{node[:geoserver][:version]}/geoserver-#{node[:geoserver][:version]}-war.zip"
geoserver_name = ::File.basename("#{url}")
geoserver_local_path = ::File.join(Chef::Config[:file_cache_path],geoserver_name)
geoserver_tmp = ::File.join(Chef::Config[:file_cache_path],"geoserver")
tomcat_directory = node['tomcat']['webapp_dir']
#this makes sure that previous log files don't confuse the wait below
execute 'preclean' do
    command "touch #{tomcat_directory}/geoserver/data/logs/geoserver.log; cat > #{tomcat_directory}/geoserver/data/logs/geoserver.log"
    only_if {::File.exists?("/usr/share/tomcat/webapps/geoserver")}
end

directory geoserver_tmp do
    mode "0755"
end

remote_file "#{geoserver_local_path}" do
  action :create_if_missing
  source "#{url}"
  notifies :run, 'execute[install geoserver]', :immediately
end

execute 'own_data' do
  command "chown -R #{node['tomcat']['user']}:#{node['tomcat']['group']} #{node[:geoserver][:data_dir]}"
end


execute 'install geoserver' do
    
    unpack = <<-EOF
        cd #{Chef::Config[:file_cache_path]}
        unzip -p #{geoserver_name} > geoserver.war
        cp geoserver.war #{tomcat_directory}
    EOF
    command unpack
    
    only_if FileUtils.uptodate?('geoserver.war','#{tomcat_directory}/geoserver.war')
    #not_if {::File.exists?("#{tomcat_directory}/geoserver.war")}
    #notifies :create, 'ruby_block[block_until_geoserver_operational]', :immediate
end

ruby_block "block_until_geoserver_operational" do
  block do
    block do
        true until ::File.exists?("#{tomcat_directory}/geoserver/data/logs/geoserver.log") && ::File.foreach("#{tomcat_directory}/geoserver/data/logs/geoserver.log").any?{ |l| l['Mapped URL path [/wms] onto handler'] }
    end
  end
  action :nothing
end

