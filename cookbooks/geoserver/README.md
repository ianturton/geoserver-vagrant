# geoserver

Spin up a GeoServer Test VM
============================

This Chef cookbook is the one I use in conjunction with Vagrant to spin up quick
test VMs to allow me to play with new GeoServer features and versions with out
breaking my current install.

Requirements
------------
### Platforms
- Debian / Ubuntu derivatives

### Chef
- Chef 12.1+

### Cookbooks
- java
- tomcat


#Attributes

* `node["geoserver"]["version"] - the version number to install
* `node["geoserver"]["data_dir"] - the directory to use as the data dir (if this
  is shared then no_squash_root must be set on the share).

#Usage 

Just include the recipie when you need to install GeoServer. 

  
