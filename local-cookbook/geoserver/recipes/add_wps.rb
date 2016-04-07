# fetch the wps extension and addit to the running geoserver and restart
#
# Ian Turton
#

include_recipe 'java'
include_recipe 'geoserver'

package "unzip"
package "curl"

if "#{node[:geoserver][:version]}" == "latest" 
  url = "http://ares.boundlessgeo.com/geoserver/master/ext-latest/geoserver-2.9-SNAPSHOT-wps-plugin.zip"
elsif node[:geoserver][:version].include? "x" 
  #http://ares.boundlessgeo.com/geoserver/2.8.x/ext-latest/geoserver-2.8-SNAPSHOT-wps-plugin.zip
  basename = node[:geoserver][:version]
  url = "http://ares.boundlessgeo.com/geoserver/#{node[:geoserver][:version]}/ext-latest/geoserver-#{basename[0..-3]}-SNAPSHOT-wps-plugin.zip"
else
url = "http://sourceforge.net/projects/geoserver/files/GeoServer/#{node['geoserver']['version']}/extensions/geoserver-#{node['geoserver']['version']}-wps-plugin.zip"
end

plugin_name = ::File.basename(url)
plugin_local_path = ::File.join(Chef::Config[:file_cache_path],plugin_name)
tomcat_directory = "/opt/tomcat_geoserver/webapps/geoserver/WEB-INF/lib"

remote_file "#{plugin_local_path}" do
    source url
    notifies :run, "execute[install plugin #{plugin_local_path}]", :immediately
    action :create_if_missing
end

execute "install plugin #{plugin_local_path}" do
    user #{node['tomcat']['user']}
    unpack = <<-EOF
      cd #{tomcat_directory}
      unzip -u #{plugin_local_path} 
    EOF
    command unpack
end


service 'tomcat_geoserver' do
  action :restart
end
