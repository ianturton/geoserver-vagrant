#!/usr/bin/env bash

apt-get update
apt-get -y install zip openjdk-7-jre tomcat7

wget -q -O geoserver.zip http://sourceforge.net/projects/geoserver/files/GeoServer/2.3.5/geoserver-2.3.5-war.zip

service tomcat7 start

unzip -u -qq geoserver.zip
#export JAVA_HOME=/usr/lib/jvm/java-7-openjdk-i386
cp geoserver.war /var/lib/tomcat7/webapps/
