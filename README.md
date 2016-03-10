# Sahara HortonWorks Cluster Deploy
This script is designed to work with an Openstack cluster that has Sahara deployed on it. 

**Requirements:**
* Openstack
* Sahara
* Access to controller node

##How to setup cluster
1. Open *create_hadoop_cluster.sh* 
2. Modify list of variables contained inside, particularly:
  *  FLOATING_IP_POOL - Should be your external network
  *  NETWORK_NAME - Should be your internal network
  *  IMAGE_NAME - Your base image for Hortonworks, this can be aquired from the sahara image repository: 
  
     http://sahara-files.mirantis.com/images/upstream/liberty/
     
     or built from the diskimage-builder:
     
     https://github.com/openstack/diskimage-builder
3. Once complete, source your openrc
4. Run sh create_hadoop_cluster.sh

##What it will do
1. Copy unmodified json files to a new directory
2. Update json files with new values
3. Create the worker & master node template
4. Create the cluster group template
5. Create a new ssh key
6. Update the my_cluster_create.json file which is the cluster you will deploy
7. Deploy the new cluster.

##How is this playbook licensed?

It's licensed under the Apache License 2.0. The quick summary is:

> A license that allows you much freedom with the software, including an explicit right to a patent. “State changes” means that you have to include a notice in each file you modified. 

Pull requests and Github issues are welcom!

-- James