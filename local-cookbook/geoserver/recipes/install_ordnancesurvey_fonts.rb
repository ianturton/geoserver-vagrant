#install the Ordnance Survey fonts
#
#


cookbook_file '/usr/share/fonts/Strategi_Symbols.ttf' do
  source 'Strategi_Symbols.ttf'
  mode '0755'
  action :create
  not_if 'fc-list | grep Strategi_Symbols'
  notifies :run, 'bash[refresh cache]', :immediately
end

bash 'refresh cache' do
  code 'fc-cache -f'
  
  notifies :restart, "service[#{node['tomcat']['base_instance']}]", :immediately
end


