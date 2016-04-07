
 # Cookbook Name:: geoserver
 # Recipe:: default


include_recipe 'java'
#include_recipe 'tomcat'

# Install Tomcat 8.0.32 to the default location
tomcat_install 'geoserver' do
  version '7.0.68'
end

# start the geoserver tomcat service using a non-standard pid location
tomcat_service 'geoserver' do
  action [:start, :enable, :restart]
  env_vars [{ 'CATALINA_PID' => '/opt/tomcat_geoserver/bin/non_standard_location.pid' }]
end

apt_repository 'ubuntugis-unstable' do
  uri          'ppa:ubuntugis/ubuntugis-unstable'
  distribution node['lsb']['codename']
end

package "unzip"
package "curl"
package "gdal-bin"
package "postgresql" #for psql

if "#{node[:geoserver][:version]}" == "latest" 
#  http://ares.boundlessgeo.com/geoserver/master/geoserver-master-latest-war.zip
  url = "http://ares.boundlessgeo.com/geoserver/master/geoserver-master-latest-war.zip"
elsif "#{node[:geoserver][:version]}".include? "x" 
  #http://ares.boundlessgeo.com/geoserver/2.8.x/geoserver-2.8.x-latest-war.zip
  url = "http://ares.boundlessgeo.com/geoserver/#{node[:geoserver][:version]}/geoserver-#{node[:geoserver][:version]}-latest-war.zip"
else
  url = "http://sourceforge.net/projects/geoserver/files/GeoServer/#{node[:geoserver][:version]}/geoserver-#{node[:geoserver][:version]}-war.zip"
end
geoserver_name = ::File.basename("#{url}")
geoserver_local_path = ::File.join(Chef::Config[:file_cache_path],geoserver_name)
geoserver_tmp = ::File.join(Chef::Config[:file_cache_path],"geoserver")
tomcat_directory = "/opt/tomcat_geoserver/webapps"
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
  notifies :run, 'execute[unpack geoserver]', :immediately
end


execute 'own_data' do
  command "chown -R #{node['tomcat']['user']}:#{node['tomcat']['group']} #{node[:geoserver][:data_dir]}"
  only_if {::File.exists?("#{node[:geoserver][:data_dir]}")}
end

execute 'unpack geoserver' do
    unpack = <<-EOF
        cd #{Chef::Config[:file_cache_path]}
        unzip -p #{geoserver_name} > geoserver.war
    EOF
    command unpack
end    
execute 'install geoserver' do
    unpack = <<-EOF
        cd #{Chef::Config[:file_cache_path]}
        cp geoserver.war #{tomcat_directory}
    EOF
    command unpack
#    only_if FileUtils.uptodate?('geoserver.war','#{tomcat_directory}/geoserver.war')
  notifies :run, 'ruby_block[block_until_geoserver_operational]', :immediately
end

ruby_block "block_until_geoserver_operational" do
  block do
    block do
        true until ::File.exists?("#{tomcat_directory}/geoserver/WEB-INF/web.xml") && ::File.exists?("#{tomcat_directory}/geoserver/data/logs/geoserver.log") && ::File.foreach("#{tomcat_directory}/geoserver/data/logs/geoserver.log").any?{ |l| l['Mapped URL path [/wms] onto handler'] }
    end
  end
  action :nothing
end

template "#{tomcat_directory}/geoserver/WEB-INF/web.xml" do
  source "web-xml.erb"
end
