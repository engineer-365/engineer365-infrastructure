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

# https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/

set -x
set -e

# turn off swap
swapoff -a

# in /etc/fstab, ensure to comment swap mount, like below
#/swap.img      none    swap    sw      0       0
sed -i '/swap/d' /etc/fstab

echo "127.0.0.1 localhost" >> /etc/hosts
echo "221.231.81.239  mirrors.aliyun.com" >> /etc/hosts

export DEBIAN_FRONTEND=noninteractive

# Set up the Docker daemon
# See https://kubernetes.io/docs/setup/production-environment/container-runtimes/#docker
rm -f /etc/docker/daemon.json
cat <<EOF | tee /etc/docker/daemon.json
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2",
  "registry-mirrors": [
    "https://docker.mirrors.ustc.edu.cn",
    "https://hub-mirror.c.163.com"
  ]
}
EOF

# Restart Docker
systemctl daemon-reload
systemctl restart docker


# Make sure that the br_netfilter module is loaded. This can be done by running lsmod | grep br_netfilter.
# load it explicitly now
modprobe br_netfilter

# Now install kubeadmin following https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/

# As a requirement for iptables to correctly see bridged traffic, we should ensure net.bridge.bridge-nf-call-iptables
# is set to 1 in your sysctl config
# For more details please see
#   https://kubernetes.io/docs/concepts/extend-kubernetes/compute-storage-net/network-plugins/#network-plugin-requirements
cat <<EOF | tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sysctl --system

# Check required ports
# Control-plane node(s)
# Protocol	Direction	Port Range	Purpose	                Used By
# TCP	      Inbound	  6443*	      Kubernetes API server	  All
# TCP	      Inbound	  2379-2380	  etcd server client API	kube-apiserver, etcd
# TCP	      Inbound	  10250	      kubelet API	            Self, Control plane
# TCP	      Inbound	  10251	      kube-scheduler	        Self
# TCP	      Inbound	  10252	      kube-controller-manager	Self

# Worker node(s)
# Protocol	Direction	Port Range	Purpose	                Used By
# TCP	      Inbound	  10250	      kubelet API	            Self, Control plane
# TCP	      Inbound	  30000-32767	NodePort Services†	    All

# install these packages on all cluster machines:
# kubeadm: the command to bootstrap the cluster.
# kubelet: the component that runs on all cluster machines and does things like starting pods and containers.
# kubectl: the command line util to talk to your cluster.
apt-get install -qq -y apt-transport-https curl ebtables ethtool

# curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
curl -s https://mirrors.aliyun.com/kubernetes/apt/doc/apt-key.gpg | apt-key add -

#cat <<EOF | tee /etc/apt/sources.list.d/kubernetes.list
#deb https://apt.kubernetes.io/ kubernetes-xenial main
#EOF
echo "deb https://mirrors.aliyun.com/kubernetes/apt/ kubernetes-xenial main" >> /etc/apt/sources.list.d/kubernetes.list

apt-get update -qq && apt-get upgrade -qq

# After installed, kubelet will keep restarting every few seconds, as it waits in a crashloop for kubeadm to tell it what to do.
K8S_VER="1.20.1-00"
apt-get install -qq -y kubelet=${K8S_VER} kubeadm=${K8S_VER} kubectl=${K8S_VER}

# exclude all Kubernetes packages from any system upgrades. This is because kubeadm and Kubernetes require special attention to upgrade.
# see https://kubernetes.io/docs/tasks/administer-cluster/kubeadm/kubeadm-upgrade/
apt-mark hold kubelet kubeadm kubectl

# Creating a cluster with kubeadm:
# see https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/
#
# Objectives
# - Install a single control-plane Kubernetes cluster
# - Install a Pod network on the cluster so that your Pods can talk to each other

# default: kubeadm config print init-defaults

cat <<EOF | tee kubeadm-config.yaml
apiVersion: kubeadm.k8s.io/v1beta2
kind: InitConfiguration
localAPIEndpoint:
  advertiseAddress: 192.168.50.151
  bindPort: 6443
---
apiVersion: kubeadm.k8s.io/v1beta2
kind: ClusterConfiguration
imageRepository: registry.cn-hangzhou.aliyuncs.com/google_containers
kubernetesVersion: v1.20.1
controlPlaneEndpoint: k8s-master1.engineer365.org:6443
networking:
  dnsDomain: cluster.local
  serviceSubnet: 10.96.0.0/12
  podSubnet: 10.100.0.1/16
EOF

kubeadm config images list --config=kubeadm-config.yaml
kubeadm config images pull --config=kubeadm-config.yaml

# pull calico images

# for calico 3.17.1
docker pull --quiet calico/pod2daemon-flexvol:v3.17.1
docker pull --quiet calico/cni:v3.17.1
docker pull --quiet calico/node:v3.17.1
docker pull --quiet calico/kube-controllers:v3.17.1
docker pull --quiet calico/typha:v3.17.1

# for calico 3.10.2
# docker pull --quiet calico/pod2daemon-flexvol:v3.10.2
# docker pull --quiet calico/cni:v3.10.2
# docker pull --quiet calico/node:v3.10.2
# docker pull --quiet calico/kube-controllers:v3.10.2
# docker pull --quiet calico/typha:v3.10.2
