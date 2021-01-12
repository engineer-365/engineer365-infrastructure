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

set -e
set -x

echo "192.168.50.151  k8s-master1" >> /etc/hosts

# https://kubernetes.io/docs/reference/setup-tools/kubeadm/kubeadm-init
kubeadm init --config=kubeadm-config.yaml --upload-certs

# generate join command and save it for other nodes to get
kubeadm token create --print-join-command >> /home/admin/kubeadm_join_command.sh
chown -R admin:admin /home/admin/kubeadm_join_command.sh

# verify
# systemctl status kubelet
# journalctl -xeu kubelet
# docker ps -a | grep kube | grep -v pause
# docker logs CONTAINERID

mkdir -p /root/.kube
cp -i /etc/kubernetes/admin.conf /root/.kube/config

mkdir -p /home/admin/.kube
cp -i /etc/kubernetes/admin.conf /home/admin/.kube/config
chown $(id admin -u):$(id admin -g) /home/admin/.kube/config

# install calico CNI addon following https://docs.projectcalico.org/getting-started/kubernetes/
# references:
# - https://kubernetes.io/docs/concepts/policy/pod-security-policy/

# TODO: loop to query the ready status
sleep 60

kubectl create -f /home/vagrant/files/calico/3.17.1/calico.yaml
# or
# kubectl create -f /home/vagrant/files/calico/3.17.1/tigera-operator.yaml
# kubectl create -f /home/vagrant/files/calico/3.17.1/custom-resources.yaml

# wait for ready?
# TODO: loop to query the ready status
sleep 60

kubectl get pods -n kube-system

# then run `vagrant ssh -c "sudo kubeadm token create --print-join-command"` to get join command

# kubectl apply -f /home/vagrant/files/nginx-ingress.yaml
# then configure the domain name 'fleashop.engineer365.org' to the host machine, will got 404 error which is expected
