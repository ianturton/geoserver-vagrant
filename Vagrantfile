# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant::configure("2") do |config|
  # All Vagrant configuration is done here. The most common configuration
  # options are documented and commented below. For a complete reference,
  # please see the online documentation at vagrantup.com.

  # Every Vagrant virtual environment requires a box to build off of.
  config.vm.box = "ubuntu/trusty32"

  if Vagrant.has_plugin?("vagrant-cachier")
    # Configure cached packages to be shared between instances of the same base box.
    # More info on http://fgrehm.viewdocs.io/vagrant-cachier/usage
    config.cache.scope = :box

    # OPTIONAL: If you are using VirtualBox, you might want to use that to enable
    # NFS for shared folders. This is also very useful for vagrant-libvirt if you
    # want bi-directional sync
    config.cache.synced_folder_opts = {
      type: :nfs,
      # The nolock option can be useful for an NFSv3 client that wants to avoid the
      # NLM sideband protocol. Without this option, apt-get might hang if it tries
      # to lock files needed for /var/cache/* operations. All of this can be avoided
      # by using NFSv4 everywhere. Please note that the tcp option is not the default.
      mount_options: ['rw', 'vers=3', 'tcp', 'nolock']
    }
    # For more information please check http://docs.vagrantup.com/v2/synced-folders/basic_usage.html
  end
  # Configure VM Ram usage

  # VirtualBox configuration
  config.vm.provider :virtualbox do |vb|

    # Use VBoxManage to customize the VM
    vb.customize ["modifyvm", :id, "--memory", "1024"]
#    vb.customize ["setextradata", :id, "VBoxInternal2/SharedFoldersEnableSymlinksCreate/src", "1"]
  end


  # The url from where the 'config.vm.box' box will be fetched if it
  # doesn't already exist on the user's system.
  #config.vm.box_url = "http://files.vagrantup.com/trusty32.box"

  # Boot with a GUI so you can see the screen. (Default is headless)
  # config.vm.boot_mode = :gui

  # Assign this VM to a host-only network IP, allowing you to access it
  # via the IP. Host-only networks can talk to the host machine as well as
  # any other machines on the same network, but cannot be accessed (through this
  # network interface) by any external networks.
  # config.vm.network :hostonly, "192.168.33.10"

  # Assign this VM to a bridged network, allowing you to connect directly to a
  # network using the host's network device. This makes the VM appear as another
  # physical device on your network.
  # config.vm.network :bridged

  # Forward a port from the guest to the host, which allows for outside
  # computers to access the VM, whereas host only networking does not.
  # config.vm.forward_port 80, 8080

  config.vm.network :forwarded_port, guest: 8080, host: 4080, auto_correct: true
  config.vm.network "private_network", ip: "192.168.50.4"

  #config.vm.synced_folder "data/", "/data", owner: "tomcat6", group: "tomcat6", type: "nfs"
  config.vm.synced_folder "data/", "/data", 
    :nfs => true,
    :linux__nfs_options => ['rw','no_subtree_check','no_root_squash','async']

  # Share an additional folder to the guest VM. The first argument is
  # an identifier, the second is the path on the guest to mount the
  # folder, and the third is the path on the host to the actual folder.
  # config.vm.share_folder "v-data", "/vagrant_data", "../data"

 # Provisioning with chef solo
  config.vm.provision :chef_solo do |chef|
    chef.data_bags_path = "data_bags"
    #chef.log_level = :debug
    chef.add_recipe "apt"
    chef.add_recipe "java"
    chef.add_recipe "tomcat"
    chef.add_recipe "tomcat::users"
    chef.add_recipe "geoserver::install_msfonts"
    chef.add_recipe "geoserver"
    chef.add_recipe "geoserver::add_wps"
    chef.add_recipe "geoserver::install_ordnancesurvey_fonts"

    chef.json = {
      :geoserver => {:version => '2.8.1',
        :data_dir => '/data/geoserver' },
      :install_repo => {:repos => [
        "deb http://us.archive.ubuntu.com/ubuntu/ trusty multiverse",
        "deb-src http://us.archive.ubuntu.com/ubuntu/ trusty multiverse",
        "deb http://us.archive.ubuntu.com/ubuntu/ trusty-updates multiverse",
        "deb-src http://us.archive.ubuntu.com/ubuntu/ trusty-updates multiverse"
      ]},
      :java => {
        :jdk_version => "8",
      },
#      :java => {
#        :install_flavor => "oracle",
#        :jdk_version => "8",
#        :oracle => {
#          :accept_oracle_download_terms => true
#        }
#      },
      :tomcat => {
            'catalina_options' => "-DGEOSERVER_DATA_DIR=/data/geoserver",
            'java_options' => "${JAVA_OPTS} -Djava.awt.headless=true -Xmx1024m -XX:NewSize=256m -XX:MaxNewSize=256m -XX:PermSize=512m -XX:MaxPermSize=512m -XX:CompileCommand=exclude,net/sf/saxon/event/ReceivingContentHandler.startElement",
            :keystore_password => "ianian"
      }
    }
  end


  #config.vm.provision :shell, :path=> "bootstrap.sh"

  # Enable provisioning with Puppet stand alone.  Puppet manifests
  # are contained in a directory path relative to this Vagrantfile.
  # You will need to create the manifests directory and a manifest in
  # the file precise32.pp in the manifests_path directory.
  #
  # An example Puppet manifest to provision the message of the day:
  #
  # # group { "puppet":
  # #   ensure => "present",
  # # }
  # #
  # # File { owner => 0, group => 0, mode => 0644 }
  # #
  # # file { '/etc/motd':
  # #   content => "Welcome to your Vagrant-built virtual machine!
  # #               Managed by Puppet.\n"
  # # }
  #
  # config.vm.provision :puppet do |puppet|
  #   puppet.manifests_path = "manifests"
  #   puppet.manifest_file  = "precise32.pp"
  # end

  # Enable provisioning with chef server, specifying the chef server URL,
  # and the path to the validation key (relative to this Vagrantfile).
  #
  # The Opscode Platform uses HTTPS. Substitute your organization for
  # ORGNAME in the URL and validation key.
  #
  # If you have your own Chef Server, use the appropriate URL, which may be
  # HTTP instead of HTTPS depending on your configuration. Also change the
  # validation key to validation.pem.
  #
  # config.vm.provision :chef_client do |chef|
  #   chef.chef_server_url = "https://api.opscode.com/organizations/ORGNAME"
  #   chef.validation_key_path = "ORGNAME-validator.pem"
  # end
  #
  # If you're using the Opscode platform, your validator client is
  # ORGNAME-validator, replacing ORGNAME with your organization name.
  #
  # IF you have your own Chef Server, the default validation client name is
  # chef-validator, unless you changed the configuration.
  #
  #   chef.validation_client_name = "ORGNAME-validator"
end
