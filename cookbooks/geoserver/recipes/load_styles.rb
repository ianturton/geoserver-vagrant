#load styles
user = node.default['user']
dataset = node['dataset']
cookbook_file "/home/#{user}/#{dataset}-sld.tgz" do
    mode '0644'
    owner "#{user}"
    source "#{dataset}/#{dataset}-sld.tgz"
end


shpDir = "/home/#{user}/#{dataset}/#{dataset}-sld"

execute "unpack styles #{shpDir}" do
    command "tar xvf /home/#{user}/#{dataset}-sld.tgz -C /home/#{user}/#{dataset}; chmod -R +wr #{shpDir}"
    
    not_if { ::File.exists?(shpDir) }
end