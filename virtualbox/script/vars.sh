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

log_block "Variables:"

export org="example.com"
log_info "\t  org:" ${org}

export download_site="https://download.engineer365.org:40443"
log_info "\t  download_site:" ${download_site}

export scp_upload_path="192.168.4.2:/hdd/engineer365/download/vagrant/box/${org}"
log_info "\t  scp_upload_path:" ${scp_upload_path}

export scp_upload_port="30022"
log_info "\t  scp_upload_port:" ${scp_upload_port}

export box_download_path="${download_site}/vagrant/box"
log_info "\t  box_download_path:" ${box_download_path}

export ubuntu_mirror="https://mirrors.tuna.tsinghua.edu.cn/ubuntu/"
log_info "\t  ubuntu_mirror:" ${ubuntu_mirror}

export timezone="Asia/Shanghai"
log_info "\t  timezone:" ${timezone}
# users
export admin_user="admin"
log_info "\t  admin_user:" ${admin_user}

export dev_user="dev"
log_info '\t  dev_user:' ${dev_user}

export docker_mirror_1="https://docker.mirrors.ustc.edu.cn"
log_info '\t  docker_mirror_1:' ${docker_mirror_1}

export docker_mirror_2="https://hub-mirror.c.163.com"
log_info '\t  docker_mirror_2:' ${docker_mirror_2}

# https://packages.cloud.google.com/apt/doc/apt-key.gpg
export k8s_gpg="https://mirrors.aliyun.com/kubernetes/apt/doc/apt-key.gpg"
log_info '\t  k8s_gpg:' ${k8s_gpg}

# https://apt.kubernetes.io/
export k8s_apt="https://mirrors.aliyun.com/kubernetes/apt/"
log_info '\t  k8s_apt:' ${k8s_apt}

export GOPROXY=https://goproxy.io
log_info '\t  GOPROXY:' ${GOPROXY}

export jenkins_uc_download="https://mirrors.tuna.tsinghua.edu.cn/jenkins"
log_info '\t  jenkins_uc_download:' ${jenkins_uc_download}

export maven_public_mirror="https://maven.aliyun.com/repository/public"
log_info '\t  maven_public_mirror:' ${maven_public_mirror}

export k8s_images_registry="registry.cn-hangzhou.aliyuncs.com/google_containers"
log_info '\t  k8s_images_registry:' ${k8s_images_registry}