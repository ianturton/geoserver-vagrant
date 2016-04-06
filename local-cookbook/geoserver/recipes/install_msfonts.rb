#fonts_rpm="http://www.my-guides.net/en/images/stories/fedora12/msttcore-fonts-2.0-3.noarch.rpm"
#if platform_family?('rhel') do
#  fonts_rpm="msttcore-fonts-2.0-3.noarch.rpm"
#  fonts_name = ::File.basename("#{fonts_rpm}")
#  fonts_local_path = ::File.join(Chef::Config[:file_cache_path],fonts_name)
#  fonts_tmp = ::File.join(Chef::Config[:file_cache_path],"fonts")
#
#  remote_file fonts_local_path do
#      source fonts_rpm
#      notifies :run, 'execute[install_fonts]', :immediately
#  end 
#  #cookbook_file fonts_local_path do
#      #source fonts_rpm
#      #notifies :run, 'execute[install_fonts]', :immediately
#  #end
#  execute "install_fonts" do
#      repo_name = ::File.basename(fonts_local_path,".rpm")
#      not_if "rpm -qi #{repo_name}"
#      command "rpm -Uvh #{fonts_local_path}"
#  end
#
#end

#if platform_family?('debian') do
  repos = [
          "deb http://us.archive.ubuntu.com/ubuntu/ trusty multiverse",
          "deb-src http://us.archive.ubuntu.com/ubuntu/ trusty multiverse",
          "deb http://us.archive.ubuntu.com/ubuntu/ trusty-updates multiverse",
          "deb-src http://us.archive.ubuntu.com/ubuntu/ trusty-updates multiverse"
                                        ]
  repos.each do |repo|
    bash "add_repo_#{repo}" do
      not_if "grep -q #{repo} /etc/apt/sources.list"
      code 'echo "#{repo} >> /etc/apt/sources.list"'
    end
  end


  execute "update" do
    command "apt-get update"
  end


  bash 'accept eula' do
    code 'echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | debconf-set-selections'
  end

  package 'ttf-mscorefonts-installer' 


  execute 'restart tomcat' do
    command 'echo service tomcat6 restart'
#    notifies :restart, "tomcat_service[geoserver]", :immediately
  end
#end

