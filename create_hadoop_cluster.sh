#!/bin/bash
#
# Copyright 2016 James Benson
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#
CLUSTER_NAME="MyCluster"
PLUGIN_NAME="ambari"
HADOOP_VERSION="2.3"
FLOATING_IP_POOL="net04_ext"
AUTO_SECURITY_GROUP=true
CLUSTER_FLAVOR_ID="4"
KEYPAIR_NAME="tmp_keypair"
SECURITY_GROUPS=d
NETWORK_NAME="net04"
NETWORK_ID=`neutron net-list | grep net04[^_] | awk '{print$2}'`
WORKING_DIR="/tmp/sahara_image"
IMAGE_NAME="My_image_name"
#######################
# Copy files to temp.
#######################
cp -r *.json $WORKING_DIR/

#############################################
# Setup Master & Worker Node Group Template
#############################################
NETWORK_ID=`neutron net-list | grep net04[^_] | awk '{print$2}'`
FLOATING_IP_POOL_ID=`openstack network list |grep $FLOATING_IP_POOL |awk '{print $2}'`
for i in /tmp/sahara_image/*.json; do
    sed -i "s/{CLUSTER_NAME}/$CLUSTER_NAME/" $i
    sed -i "s/{PLUGIN_NAME}/$PLUGIN_NAME/" $i
    sed -i "s/{HADOOP_VERSION}/$HADOOP_VERSION/" $i
    sed -i "s/{FLOATING_IP_POOL_ID}/$FLOATING_IP_POOL_ID/" $i
    sed -i "s/{AUTO_SECURITY_GROUP}/$AUTO_SECURITY_GROUP/" $i
    sed -i "s/{CLUSTER_FLAVOR_ID}/$CLUSTER_FLAVOR_ID/" $i
    sed -i "s/{EXTERNAL_NETWORK}/$EXTERNAL_NETWORK/" $i
    sed -i "s/{KEY_PAIR_NAME}/$KEY_PAIR_NAME/" $i
    sed -i "/^.*{SECURITY_GROUPS}.*$/d" $i
    sed -i "s/{NETWORK_NAME}/$NETWORK_NAME/" $i
    sed -i "s/{NETWORK_ID}/$NETWORK_ID/" $i
done
sahara node-group-template-create --json $WORKING_DIR/worker_node_template.json &> /dev/null
echo "INFO: Worker Node Template Created"
sahara node-group-template-create --json $WORKING_DIR/master_node_template.json &> /dev/null
echo "INFO: Master Node Template Created"

################################
# Setup Cluster Group Template
################################
sleep 2
WORKER_NODE_ID=`sahara node-group-template-list | grep $PLUGIN_NAME-worker | awk '{print$4}'`
MASTER_NODE_ID=`sahara node-group-template-list | grep $PLUGIN_NAME-master | awk '{print$4}'`
echo $WORKER_NODE_ID
echo $MASTER_NODE_ID
for i in $WORKING_DIR/*.json; do
    sed -i "s/{WORKER_NODE_ID}/$WORKER_NODE_ID/" $i
    sed -i "s/{MASTER_NODE_ID}/$MASTER_NODE_ID/" $i
done
sahara cluster-template-create --json $WORKING_DIR/cluster_template.json &> /dev/null
echo "INFO: Cluster Group Template Created"

##################
# Deploy cluster
##################
sleep 2
CLUSTER_TEMPLATE_ID=`sahara cluster-template-list |grep $PLUGIN_NAME-cluster | awk '{print $4}'`
nova keypair-add $KEY_PAIR_NAME > $WORKING_DIR/KEY_PAIR_NAME.pem
DEFAULT_IMAGE_ID=`nova image-list | grep $IMAGE_NAME | awk '{print$2}'`
for i in $WORKING_DIR/*.json; do
    sed -i "s/{CLUSTER_TEMPLATE_ID}/$CLUSTER_TEMPLATE_ID/" $i
    sed -i "s/{KEYPAIR_ID}/$KEYPAIR_ID/" $i
    sed -i "s/{DEFAULT_IMAGE_ID}/$DEFAULT_IMAGE_ID/" $i
done

sahara cluster-create --json $WORKING_DIR/my_cluster_create.json &> /dev/null
echo "INFO: Cluster successfully deployed!"