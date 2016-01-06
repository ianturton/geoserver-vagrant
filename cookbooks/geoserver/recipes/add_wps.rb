# fetch the WPS extension and addit to the running geoserver and restart
#
# Ian Turton
#

include_recipe 'java'
include_recipe 'tomcat::default'
include_recipe 'geoserver'

package "unzip"
package "curl"

url = "http://sourceforge.net/projects/geoserver/files/GeoServer/#{node['geoserver']['version']}/extensions/geoserver-#{node['geoserver']['version']}-wps-plugin.zip"

plugin_name = ::File.basename(url)
plugin_local_path = ::File.join(Chef::Config[:file_cache_path],plugin_name)
tomcat_directory = "#{node['tomcat']['webapp_dir']}/geoserver/WEB-INF/lib"

remote_file "#{plugin_local_path}" do
    source url
    notifies :run, 'execute[install plugin]', :immediately
    action :create_if_missing
end

execute 'install plugin' do
    user #{node['tomcat']['user']}
    unpack = <<-EOF
      cd #{tomcat_directory}
      unzip -u #{plugin_local_path} 
    EOF
    command unpack
    
    #only_if FileUtils.uptodate?('geoserver.war','#{tomcat_directory}/geoserver.war')
    #not_if {::File.exists?("#{tomcat_directory}/geoserver.war")}
end


service 'tomcat6' do
  action :restart
end
