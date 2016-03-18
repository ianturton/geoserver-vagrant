geoserver-vagrant
=================

A vagrant setup for running the latest geoserver

Getting Started
===============

The script will use a local data folder (data/) in the main direcoty as the GeoServer data directory (mounted as /data on the VM) you must create at least an empty directory for the script to work but can provide an pre-existing data dir to run tests on.

I think you can then check this repo out and then do 

  vagrant up

wait a little bit and then point your browser to http://localhost:4080/geoserver

