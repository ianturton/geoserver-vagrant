# fetch the geoscript extension and addit to the running geoserver and restart
#
# Ian Turton
#

include_recipe 'java'
include_recipe 'geoserver'

package "unzip"
package "curl"

if "#{node[:geoserver][:version]}" == "latest" 
  url = "http://ares.boundlessgeo.com/geoserver/master/community-latest/geoserver-2.9-SNAPSHOT-python-plugin.zip"
else
  #http://ares.boundlessgeo.com/geoserver/2.8.x/ext-latest/geoserver-2.8-SNAPSHOT-wps-plugin.zip
  #http://ares.boundlessgeo.com/geoserver/2.8.x/community-latest/geoserver-2.8-SNAPSHOT-python-plugin.zip
  #NOTE THIS IS NOT PUBLISHED ALWAYS LOOK ON ARES
  basename = node[:geoserver][:version][0..-3]
  url = "http://ares.boundlessgeo.com/geoserver/#{basename}.x/community-latest/geoserver-#{basename}-SNAPSHOT-python-plugin.zip"
end

plugin_name = ::File.basename(url)
plugin_local_path = ::File.join(Chef::Config[:file_cache_path],plugin_name)
tomcat_directory = "/opt/tomcat_geoserver/webapps/geoserver/WEB-INF/lib"

remote_file "#{plugin_local_path}" do
    source url
    notifies :run, "install plugin #{plugin_local_path}", :immediately
    action :create_if_missing
end

execute "install plugin #{plugin_local_path}" do

    user #{node['tomcat']['user']}
    unpack = <<-EOF
      cd #{tomcat_directory}
      unzip -o -u #{plugin_local_path} 
    EOF
    command unpack
end


service 'tomcat_geoserver' do
  action :restart
end
