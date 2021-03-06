#!/bin/bash

#
#  MIT License
#
#  Copyright (c) 2020 engineer365.org
#
#  Permission is hereby granted, free of charge, to any person obtaining a copy
#  of this software and associated documentation files (the "Software"), to deal
#  in the Software without restriction, including without limitation the rights
#  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#  copies of the Software, and to permit persons to whom the Software is
#  furnished to do so, subject to the following conditions:
#
#  The above copyright notice and this permission notice shall be included in all
#  copies or substantial portions of the Software.
#
#  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
#  SOFTWARE.

etc_hosts_file=$virtualbox_dir/etc_hosts
rm -f $etc_hosts_file

log_info "write ip and hosts to $etc_hosts_file"

# ip and host
echo "127.0.0.1 localhost" >> $etc_hosts_file
echo "221.231.81.239  mirrors.aliyun.com" >> $etc_hosts_file
#echo "101.6.8.193 mirrors.tuna.tsinghua.edu.cn" >> $etc_hosts_file
#echo "120.55.105.209 registry.cn-hangzhou.aliyuncs.com" >> $etc_hosts_file
#echo "47.97.242.13 dockerauth.cn-hangzhou.aliyuncs.com" >> $etc_hosts_file
#echo "118.31.232.191 aliregistry.oss-cn-hangzhou.aliyuncs.com" >> $etc_hosts_file

export monitor1_ip="192.168.50.11"
export monitor1_host="monitor1.${org}"
echo "${monitor1_ip}    ${monitor1_host}" >> $etc_hosts_file
echo "${monitor1_ip}    monitor1" >> $etc_hosts_file


export store1_ip="192.168.50.21"
export store1_host="store1.${org}"
echo "${store1_ip}    ${store1_host}" >> $etc_hosts_file
echo "${store1_ip}    store1" >> $etc_hosts_file
export store2_ip="192.168.50.22"
export store2_host="store2.${org}"
echo "${store2_ip}    ${store2_host}" >> $etc_hosts_file
echo "${store2_ip}    store2" >> $etc_hosts_file
export store3_ip="192.168.50.23"
export store3_host="store3.${org}"
echo "${store3_ip}    ${store3_host}" >> $etc_hosts_file
echo "${store3_ip}    store3" >> $etc_hosts_file
export store4_ip="192.168.50.24"
export store4_host="store4.${org}"
echo "${store4_ip}    ${store4_host}" >> $etc_hosts_file
echo "${store4_ip}    store4" >> $etc_hosts_file
export store5_ip="192.168.50.25"
export store5_host="store5.${org}"
echo "${store5_ip}    ${store5_host}" >> $etc_hosts_file
echo "${store5_ip}    store5" >> $etc_hosts_file


export proxy1_ip="192.168.50.101"
export proxy1_host="proxy1.${org}"
echo "${proxy1_ip}    ${proxy1_host}" >> $etc_hosts_file
echo "${proxy1_ip}    proxy1" >> $etc_hosts_file
export proxy2_ip="192.168.50.102"
export proxy2_host="proxy2.${org}"
echo "${proxy2_ip}    ${proxy2_host}" >> $etc_hosts_file
echo "${proxy2_ip}    proxy2" >> $etc_hosts_file


export builder_ip="192.168.50.121"
export builder_host="builder.${org}"
echo "${builder_ip}    ${builder_host}" >> $etc_hosts_file
echo "${builder_ip}    builder" >> $etc_hosts_file

export builder1_ip=${builder_ip}
export builder1_host=${builder_host}
echo "${builder1_ip}    ${builder1_host}" >> $etc_hosts_file
echo "${builder1_ip}    builder1" >> $etc_hosts_file

export builder2_ip="192.168.50.122"
export builder2_host="builder2.${org}"
echo "${builder2_ip}    ${builder2_host}" >> $etc_hosts_file
echo "${builder2_ip}    builder2" >> $etc_hosts_file


export k8s_master1_ip="192.168.50.151"
export k8s_master1_host="k8s-master1.${org}"
echo "${k8s_master1_ip}    ${k8s_master1_host}" >> $etc_hosts_file
echo "${k8s_master1_ip}    k8s-master1" >> $etc_hosts_file
export k8s_master2_ip="192.168.50.152"
export k8s_master2_host="k8s-master2.${org}"
echo "${k8s_master2_ip}    ${k8s_master2_host}" >> $etc_hosts_file
echo "${k8s_master2_ip}    k8s-master2" >> $etc_hosts_file


export k8s_node1_ip="192.168.50.171"
export k8s_node1_host="k8s-node1.${org}"
echo "${k8s_node1_ip}    ${k8s_node1_host}" >> $etc_hosts_file
echo "${k8s_node1_ip}    k8s-node1" >> $etc_hosts_file
export k8s_node2_ip="192.168.50.172"
export k8s_node2_host="k8s-node2.${org}"
echo "${k8s_node2_ip}    ${k8s_node2_host}" >> $etc_hosts_file
echo "${k8s_node2_ip}    k8s-node2" >> $etc_hosts_file
export k8s_node3_ip="192.168.50.173"
export k8s_node3_host="k8s-node3.${org}"
echo "${k8s_node3_ip}    ${k8s_node3_host}" >> $etc_hosts_file
echo "${k8s_node3_ip}    k8s-node3" >> $etc_hosts_file
export k8s_node4_ip="192.168.50.174"
export k8s_node4_host="k8s-node4.${org}"
echo "${k8s_node4_ip}    ${k8s_node4_host}" >> $etc_hosts_file
echo "${k8s_node4_ip}    k8s-node4" >> $etc_hosts_file
export k8s_node5_ip="192.168.50.175"
export k8s_node5_host="k8s-node5.${org}"
echo "${k8s_node5_ip}    ${k8s_node5_host}" >> $etc_hosts_file
echo "${k8s_node5_ip}    k8s-node5" >> $etc_hosts_file

# aliases
export mysql_router1_ip=$proxy1_ip
export mysql_router1_host="mysql-router1.${org}"
echo "${mysql_router1_ip}    ${mysql_router1_host}" >> $etc_hosts_file
echo "${mysql_router1_ip}    mysql-router1" >> $etc_hosts_file
export mysql_router2_ip=$proxy2_ip
export mysql_router2_host="mysql-router2.${org}"
echo "${mysql_router2_ip}    ${mysql_router2_host}" >> $etc_hosts_file
echo "${mysql_router2_ip}    mysql-router2" >> $etc_hosts_file
export mysql_master1_ip=$store1_ip
export mysql_master1_host="mysql-master1.${org}"
echo "${mysql_master1_ip}    ${mysql_master1_host}" >> $etc_hosts_file
echo "${mysql_master1_ip}    mysql-master1" >> $etc_hosts_file
export mysql_master2_ip=$store2_ip
export mysql_master2_host="mysql-master2.${org}"
echo "${mysql_master2_ip}    ${mysql_master2_host}" >> $etc_hosts_file
echo "${mysql_master2_ip}    mysql-master2" >> $etc_hosts_file
export mysql_slave1_ip=$store3_ip
export mysql_slave1_host="mysql-slave1.${org}"
echo "${mysql_slave1_ip}    ${mysql_slave1_host}" >> $etc_hosts_file
echo "${mysql_slave1_ip}    mysql-slave1" >> $etc_hosts_file
export mysql_slave2_ip=$store4_ip
export mysql_slave2_host="mysql-slave2.${org}"
echo "${mysql_slave2_ip}    ${mysql_slave2_host}" >> $etc_hosts_file
echo "${mysql_slave2_ip}    mysql-slave2" >> $etc_hosts_file
export mysql_slave3_ip=$store5_ip
export mysql_slave3_host="mysql-slave3.${org}"
echo "${mysql_slave3_ip}    ${mysql_slave3_host}" >> $etc_hosts_file
echo "${mysql_slave3_ip}    mysql-slave3" >> $etc_hosts_file

export mongodb_router1_ip=$proxy1_ip
export mongodb_router1_host="mongodb-router1.${org}"
echo "${mongodb_router1_ip}    ${mongodb_router1_host}" >> $etc_hosts_file
echo "${mongodb_router1_ip}    mongodb-router1" >> $etc_hosts_file
export mongodb_router2_ip=$proxy2_ip
export mongodb_router2_host="mongodb-router2.${org}"
echo "${mongodb_router2_ip}    ${mongodb_router2_host}" >> $etc_hosts_file
echo "${mongodb_router2_ip}    mongodb-router2" >> $etc_hosts_file

export mongodb_master1_ip=$store1_ip
export mongodb_master1_host="mongodb-master1.${org}"
echo "${mongodb_master1_ip}    ${mongodb_master1_host}" >> $etc_hosts_file
echo "${mongodb_master1_ip}    mongodb-master1" >> $etc_hosts_file
export mongodb_slave0_ip=$store2_ip
export mongodb_slave0_host="mongodb-slave0.${org}"
echo "${mongodb_slave0_ip}    ${mongodb_slave0_host}" >> $etc_hosts_file
echo "${mongodb_slave0_ip}    mongodb-slave0" >> $etc_hosts_file
export mongodb_slave1_ip=$store3_ip
export mongodb_slave1_host="mongodb-slave1.${org}"
echo "${mongodb_slave1_ip}    ${mongodb_slave1_host}" >> $etc_hosts_file
echo "${mongodb_slave1_ip}    mongodb-slave1" >> $etc_hosts_file
export mongodb_slave2_ip=$store4_ip
export mongodb_slave2_host="mongodb-slave2.${org}"
echo "${mongodb_slave2_ip}    ${mongodb_slave2_host}" >> $etc_hosts_file
echo "${mongodb_slave2_ip}    mongodb-slave2" >> $etc_hosts_file
export mongodb_slave3_ip=$store5_ip
export mongodb_slave3_host="mongodb-slave3.${org}"
echo "${mongodb_slave3_ip}    ${mongodb_slave3_host}" >> $etc_hosts_file
echo "${mongodb_slave3_ip}    mongodb-slave3" >> $etc_hosts_file


export redis1_ip=$proxy1_ip
export redis1_host="redis1.${org}"
echo "${redis1_ip}    ${redis1_host}" >> $etc_hosts_file
echo "${redis1_ip}    redis1" >> $etc_hosts_file
export redis2_ip=$proxy2_ip
export redis2_host="redis2.${org}"
echo "${redis2_ip}    ${redis2_host}" >> $etc_hosts_file
echo "${redis2_ip}    redis2" >> $etc_hosts_file


export ingress1_ip=$proxy1_ip
export ingress1_host="ingress1.${org}"
echo "${ingress1_ip}    ${ingress1_host}" >> $etc_hosts_file
echo "${ingress1_ip}    ingress1" >> $etc_hosts_file
export ingress2_ip=$proxy2_ip
export ingress2_host="ingress2.${org}"
echo "${ingress2_ip}    ${ingress2_host}" >> $etc_hosts_file
echo "${ingress2_ip}    ingress2" >> $etc_hosts_file


export kibana1_ip=$proxy1_ip
export kibana1_host="kibana1.${org}"
echo "${kibana1_ip}    ${kibana1_host}" >> $etc_hosts_file
echo "${kibana1_ip}    kibana1" >> $etc_hosts_file
export elasticsearch1_ip=$store3_ip
export elasticsearch1_host="elasticsearch1.${org}"
echo "${elasticsearch1_ip}    ${elasticsearch1_host}" >> $etc_hosts_file
echo "${elasticsearch1_ip}    elasticsearch1" >> $etc_hosts_file
export elasticsearch2_ip=$store4_ip
export elasticsearch2_host="elasticsearch2.${org}"
echo "${elasticsearch2_ip}    ${elasticsearch2_host}" >> $etc_hosts_file
echo "${elasticsearch2_ip}    elasticsearch2" >> $etc_hosts_file


export logstash1_ip=$store4_ip
export logstash1_host="logstash1.${org}"
echo "${logstash1_ip}    ${logstash1_host}" >> $etc_hosts_file
echo "${logstash1_ip}    logstash1" >> $etc_hosts_file
export logstash2_ip=$store5_ip
export logstash2_host="logstash2.${org}"
echo "${logstash2_ip}    ${logstash2_host}" >> $etc_hosts_file
echo "${logstash2_ip}    logstash2" >> $etc_hosts_file


export etcd1_ip=$store3_ip
export etcd1_host="etcd1.${org}"
echo "${etcd1_ip}    ${etcd1_host}" >> $etc_hosts_file
echo "${etcd1_ip}    etcd1" >> $etc_hosts_file
export etcd2_ip=$store4_ip
export etcd2_host="etcd2.${org}"
echo "${etcd2_ip}    ${etcd2_host}" >> $etc_hosts_file
echo "${etcd2_ip}    etcd2" >> $etc_hosts_file
export etcd3_ip=$store5_ip
export etcd3_host="etcd3.${org}"
echo "${etcd3_ip}    ${etcd3_host}" >> $etc_hosts_file
echo "${etcd3_ip}    etcd3" >> $etc_hosts_file


export prometheus1_ip=$store1_ip
export prometheus1_host="prometheus1.${org}"
echo "${prometheus1_ip}    ${prometheus1_host}" >> $etc_hosts_file
echo "${prometheus1_ip}    prometheus1" >> $etc_hosts_file
export prometheus2_ip=$store2_ip
export prometheus2_host="prometheus2.${org}"
echo "${prometheus2_ip}    ${prometheus2_host}" >> $etc_hosts_file
echo "${prometheus2_ip}    prometheus2" >> $etc_hosts_file


export grafana1_ip=$proxy1_ip
export grafana1_host="grafana1.${org}"
echo "${grafana1_ip}    ${grafana1_host}" >> $etc_hosts_file
echo "${grafana1_ip}    grafana1" >> $etc_hosts_file

export docker1_ip=$store4_ip
export docker1_host="docker1.${org}"
echo "${docker1_ip}    ${docker1_host}" >> $etc_hosts_file
echo "${docker1_ip}    docker1" >> $etc_hosts_file
export docker2_ip=$store5_ip
export docker2_host="docker2.${org}"
echo "${docker2_ip}    ${docker2_host}" >> $etc_hosts_file
echo "${docker2_ip}    docker2" >> $etc_hosts_file


export sonar1_ip=$store4_ip
export sonar1_host="sonar1.${org}"
echo "${sonar1_ip}    ${sonar1_host}" >> $etc_hosts_file
echo "${sonar1_ip}    sonar1" >> $etc_hosts_file
export sonar2_ip=$store5_ip
export sonar2_host="sonar2.${org}"
echo "${sonar2_ip}    ${sonar2_host}" >> $etc_hosts_file
echo "${sonar2_ip}    sonar2" >> $etc_hosts_file


export nexus1_ip=$store1_ip
export nexus1_host="nexus1.${org}"
echo "${nexus1_ip}    ${nexus1_host}" >> $etc_hosts_file
echo "${nexus1_ip}    nexus1_host" >> $etc_hosts_file
export nexus2_ip=$store2_ip
export nexus2_host="nexus2.${org}"
echo "${nexus2_ip}    ${nexus2_host}" >> $etc_hosts_file
echo "${nexus2_ip}    nexus2" >> $etc_hosts_file


export npm1_ip=$store2_ip
export npm1_host="npm1.${org}"
echo "${npm1_ip}    ${npm1_host}" >> $etc_hosts_file
echo "${npm1_ip}    npm1" >> $etc_hosts_file
export npm2_ip=$store3_ip
export npm2_host="npm2.${org}"
echo "${npm2_ip}    ${npm2_host}" >> $etc_hosts_file
echo "${npm2_ip}    npm2" >> $etc_hosts_file


export gitlab_ip=$store1_ip
export gitlab_host="gitlab.${org}"
echo "${gitlab_ip}    ${gitlab_host}" >> $etc_hosts_file
echo "${gitlab_ip}    gitlab" >> $etc_hosts_file

