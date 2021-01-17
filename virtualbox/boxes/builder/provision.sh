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


if [ ${opt_verbose} == "true" ]; then
  set -x
else
  set +x
fi

k8s_gpg=$1
k8s_apt=$2
GOPROXY=$3

cat > /etc/profile <<EOF

export k8s_gpg=${k8s_gpg}
export k8s_apt=${k8s_apt}

EOF

log_info "etc/profile:"
source /etc/profile
cat /etc/profile

#docker pull --quiet jenkinsci/blueocean:1.24.3
#docker pull --quiet nginx:1.19.5

# /tmp folder is used to save downloaded file.
cd /tmp

export DEBIAN_FRONTEND=noninteractive

log_block "install kubectl"

log_info "add k8s gpg: ${k8s_gpg}"
curl -s ${k8s_gpg} | apt-key add -

log_info "add k8s apt: ${k8s_apt}"
echo "deb ${k8s_apt} kubernetes-xenial main" >> /etc/apt/sources.list.d/kubernetes.list

log_block "update apt for k8s"
apt-get -qq update && apt-get -qq upgrade

K8S_APT_VER="${K8S_VER}-00"
log_block "install kubectl, version: ${K8S_APT_VER}"
apt-get -qq install -y kubectl=${K8S_APT_VER}

log_info "hold apt package upgrade for kubectl"
apt-mark hold kubectl

# /opt is the installation folder for various of software

# wget --quiet "${download_site}/other_tools/putget/putget.linux"
# chmod a+x putget.linux
# mv putget.linux /usr/local/bin/putget

################################################################################
GO_VER=1.14.13
log_block "install golang, version ${GO_VER}"
GO_TGZ=go${GO_VER}.linux-amd64.tar.gz

log_info "download golang installer: ${download_site}/golang/${GO_VER}/${GO_TGZ}"
wget --quiet "${download_site}/golang/${GO_VER}/${GO_TGZ}"
tar -C /usr/local/ -xzf ${GO_TGZ}

# TODO: take GOPROXY be optional
cat > /etc/profile <<EOF

export GOPROXY=\${GOPROXY}
export GOPATH=\$HOME/go
export PATH=\$GOPATH/bin:\$PATH:/usr/local/go/bin
export GO111MODULE=on

EOF

log_info "etc/profile:"
source /etc/profile
cat /etc/profile

################################################################################
# install jdk 11, which is the default jdk
JDK11_VER=11.0.9.1+1
log_block "install jdk-11, version ${JDK11_VER}"

JDK11_DOCKER=openjdk:11.0.9.1-jdk
JDK11_TGZ=OpenJDK11U-jdk_x64_linux_hotspot_${JDK11_VER}.tar.gz

log_info "pull jdk-11 docker image: ${JDK11_DOCKER}"
docker pull --quiet ${JDK11_DOCKER}

log_info "download jdk-11 installer: ${download_site}/jdk/11/${JDK11_TGZ}"
wget --quiet "${download_site}/jdk/11/${JDK11_TGZ}"
tar -C /opt/ -xzf ${JDK11_TGZ}
ln -s /opt/jdk-${JDK11_VER} /opt/jdk-11
ln -s /opt/jdk-11/bin/java /usr/bin/java
log_info "jdk-11 is installed to  /opt/jdk-${JDK11_VER}, and linked as /opt/jdk-11, and is default jdk"

log_info "set JAVA_HOME to /opt/jdk-11"

cat > /etc/profile <<EOF

export JAVA_HOME=/opt/jdk-11
export PATH=\$JAVA_HOME/bin:\$PATH

EOF

log_info "etc/profile:"
source /etc/profile
cat /etc/profile

################################################################################
# install jdk 8, not the default jdk
JDK8_VER=8u275-b01
log_block "install jdk-8, version ${JDK8_VER}"

JDK8_TGZ=OpenJDK8U-jdk_x64_linux_hotspot_${JDK8_VER}.tar.gz

log_info "download jdk-8 installer: ${download_site}/jdk/8/${JDK8_TGZ}"
wget --quiet "${download_site}/jdk/8/${JDK8_TGZ}"
tar -C /opt/ -xzf ${JDK8_TGZ}
ln -s /opt/jdk${JDK8_VER} /opt/jdk-8
log_info "jdk-11 is installed to /opt/jdk-8, BUT not default jdk"

################################################################################
# install maven
MAVEN_VER=3.6.3
log_block "install maven, version ${MAVEN_VER}"

MAVEN_TGZ=apache-maven-${MAVEN_VER}-bin.tar.gz
MAVEN_DOCKER=maven:${MAVEN_VER}-jdk-11

log_info "pull maven docker image: ${MAVEN_DOCKER}"
docker pull --quiet ${MAVEN_DOCKER}

log_info "download maven installer: ${download_site}/maven/${MAVEN_VER}/${MAVEN_TGZ}"
wget --quiet "${download_site}/maven/${MAVEN_VER}/${MAVEN_TGZ}"
tar -C /opt/ -xzf ${MAVEN_TGZ}
ln -s /opt/apache-maven-${MAVEN_VER} /opt/maven
log_info "maven is installed to /opt/apache-maven-${MAVEN_VER}, and linked as /opt/maven"

log_info "set MAVEN_HOME_HOME to /opt/maven"

cat > /etc/profile <<EOF

export MAVEN_HOME=/opt/maven
export PATH=\$MAVEN_HOME/bin:\$PATH

EOF

log_info "etc/profile:"
source /etc/profile
cat /etc/profile


################################################################################
# install jmeter
JMETER_VER=5.4
log_block "install jmeter, version ${JMETER_VER}"

JMETER_TGZ=apache-jmeter-${JMETER_VER}.tgz

log_info "download jmeter installer: ${download_site}/jmeter/${JMETER_VER}/${JMETER_TGZ}"
wget --quiet "${download_site}/jmeter/${JMETER_VER}/${JMETER_TGZ}"
tar -C /opt/ -xzf ${JMETER_TGZ}
ln -s /opt/apache-jmeter-${JMETER_VER} /opt/jmeter
log_info "jmeter is installed to /opt/apache-jmeter-${JMETER_VER}}, and linked as /opt/jmeter"

log_info "set JMETER_HOME to /opt/jmeter"

cat > /etc/profile <<EOF

export JMETER_HOME=/opt/jmeter
export PATH=\$JMETER_HOME/bin:\$PATH

EOF

log_info "etc/profile:"
source /etc/profile
cat /etc/profile


################################################################################
# install node.js
NODEJS_VER=14.15.1
log_block "install node.js, version ${NODEJS_VER}"

NODEJS_TGZ=node-v${NODEJS_VER}-linux-x64.tar.gz

log_info "download node.js installer: ${download_site}/node.js/14/${NODEJS_TGZ}"
wget --quiet "${download_site}/node.js/14/${NODEJS_TGZ}"
tar -C /usr/local/lib/ -xzf ${NODEJS_TGZ}
ln -s /usr/local/lib/node-v${NODEJS_VER}-linux-x64 /usr/local/lib/node.js
log_info "node.js is installed to /usr/local/lib/node-v${NODEJS_VER}-linux-x64, and linked as /usr/local/lib/node.js"

log_info "add /usr/local/lib/node.js/ to PATH"

cat > /etc/profile <<EOF

export PATH=/usr/local/lib/node.js/bin:\$PATH

EOF

log_info "etc/profile:"
source /etc/profile
cat /etc/profile


################################################################################
# install gradle
GRADLE_VER=6.7.1
log_block "install gradle, version ${GRADLE_VER}"

GRADLE_ZIP=gradle-${GRADLE_VER}-bin.zip

log_info "download gradle installer: ${download_site}/gradle/${GRADLE_VER}/${GRADLE_ZIP}"
wget --quiet "${download_site}/gradle/${GRADLE_VER}/${GRADLE_ZIP}"
unzip -q ${GRADLE_ZIP} -d /opt/
ln -s /opt/gradle-${GRADLE_VER} /opt/gradle
log_info "gradle is installed to /opt/gradle-${GRADLE_VER}, and linked as /opt/gradle"

log_info "set GRADLE_HOME to /opt/gradle"

cat > /etc/profile <<EOF

export GRADLE_HOME=/opt/gradle
export PATH=\$GRADLE_HOME/bin:\$PATH

EOF

log_info "etc/profile:"
source /etc/profile
cat /etc/profile


