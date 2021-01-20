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

source /etc/profile

jenkins_uc_download=$1
maven_public_mirror=$2

# wait for some system-update work done
sleep 180

################################################################################
# install jenkins via ubuntu package manager
# see https://www.jenkins.io/doc/book/installing/linux/#debianubuntu
#
# This package installation will:
#
# - Setup Jenkins as a daemon launched on start. See /etc/init.d/jenkins for more details.
# - Create a ‘jenkins’ user to run this service.
# - Direct console log output to the file /var/log/jenkins/jenkins.log. Check this file if you are troubleshooting Jenkins.
# - Populate /etc/default/jenkins with configuration parameters for the launch, e.g JENKINS_HOME
# - Set Jenkins to listen on port 8080. Access this port with your browser to start configuration.
# - admin password is initialized in /var/lib/jenkins/secrets/initialAdminPassword

JENKINS_VER="2.269"
JENKINS_PLUGIN_MGR_VER="2.5.0"

cat >> /etc/profile <<EOF

export JENKINS_VER=${JENKINS_VER}
export JENKINS_PLUGIN_MGR_VER=${JENKINS_PLUGIN_MGR_VER}

#export JENKINS_UC=http://updates.jenkins-ci.org
#export JENKINS_URL=http://localhost:8080
export JENKINS_UC_DOWNLOAD=${jenkins_uc_download}/

EOF

log_info "etc/profile:"
source /etc/profile
cat /etc/profile


# the nginx is used  to reverse-proxy as mirror ###############################

export DEBIAN_FRONTEND=noninteractive

NGINX_APT_VER="1.14.0-0ubuntu1.7"
log_block "install nginx ${NGINX_APT_VER}"
apt-get -qq install -y nginx=${NGINX_APT_VER}

log_info "nginx log directory for builder machine: /var/log/nginx/builder"
mkdir -p /var/log/nginx/builder

log_info "copy builder machine nginx configuration file to /etc/nginx/sites-enabled/"
mv /home/vagrant/files/etc/nginx/sites-enabled/* /etc/nginx/sites-enabled/
nginx -s reload


# offline install #############################################################
log_block "install jenkins ${JENKINS_VER}"
log_info "cd /tmp/"
cd /tmp/

log_info "install apt package for jenkins headless mode"
apt install  -y daemon ttf-dejavu fontconfig

log_info "download jenkins installer: ${download_site}/jenkins/${JENKINS_VER}/jenkins_${JENKINS_VER}_all.deb"
wget --quiet ${download_site}/jenkins/${JENKINS_VER}/jenkins_${JENKINS_VER}_all.deb

log_info "install jenkins using dpkg"
dpkg -i jenkins_${JENKINS_VER}_all.deb
rm jenkins_${JENKINS_VER}_all.deb

log_info "copy jenkins etc file"
mv /home/vagrant/files/etc/default/jenkins /etc/default/jenkins
chown -R jenkins:jenkins /etc/default/jenkins

# see https://www.jenkins.io/doc/book/managing/cli/

log_info "copy jenkins casc"
mv /home/vagrant/files/var/lib/jenkins/casc /var/lib/jenkins/

log_block "install jenkins plugins"
mv /home/vagrant/files/root/jenkins-tool/ /root/ && cd /root/jenkins-tool/

log_info "download jenkins plugin manager ${download_site}/jenkins/jenkins-plugin-manager-${JENKINS_PLUGIN_MGR_VER}.jar"
wget --quiet ${download_site}/jenkins/jenkins-plugin-manager-${JENKINS_PLUGIN_MGR_VER}.jar
ln -s /root/jenkins-tool/jenkins-plugin-manager-${JENKINS_PLUGIN_MGR_VER}.jar /root/jenkins-tool/jenkins-plugin-manager.jar

# optional - useful for jenkins adminstration work later
# wget --quiet ${JENKINS_URL}/jnlpJars/jenkins-cli.jar

## uncomment below lines to install plugin by yourself
## begin -----------------------------------------------------------------------
## see https://github.com/jenkinsci/plugin-installation-manager-tool
## download plugin to /usr/share/jenkins/ref/plugins
## java -jar jenkins-plugin-manager-*.jar --war /your/path/to/jenkins.war --plugin-file /your/path/to/plugins.txt --plugins delivery-pipeline-plugin:1.3.2 deployit-plugin
#java -jar /root/jenkins-tool/jenkins-plugin-manager.jar \
#     --verbose \
#     --jenkins-update-center ${jenkins_uc_download}/updates/dynamic-${JENKINS_VER}/update-center.actual.json \
#     --jenkins-experimental-update-center ${jenkins_uc_download}/updates/experimental/update-center.actual.json \
#     --jenkins-plugin-info ${jenkins_uc_download}/updates/current/plugin-versions.json \
#     --plugin-file /root/jenkins-tool/plugins.yaml \
#     --plugin-download-directory /var/lib/jenkins/plugins
#     --skip-failed-plugins
## end -----------------------------------------------------------------------



# comment below lines to install plugin by yourself
# begin -----------------------------------------------------------------------
# see https://github.com/jenkinsci/plugin-installation-manager-tool
log_info "download jenkins plugin descriptor from ${download_site}/jenkins to /root/.cache/jenkins-plugin-management-cli/"
mkdir -p /root/.cache/jenkins-plugin-management-cli/
wget --quiet ${download_site}/jenkins/experimental-update-center-${JENKINS_VER}.json -O /root/.cache/jenkins-plugin-management-cli/experimental-update-center-${JENKINS_VER}.json
wget --quiet ${download_site}/jenkins/plugin-versions.json                           -O /root/.cache/jenkins-plugin-management-cli/plugin-versions.json
wget --quiet ${download_site}/jenkins/update-center-${JENKINS_VER}.json              -O /root/.cache/jenkins-plugin-management-cli/update-center-${JENKINS_VER}.json

log_info "download jenkins plugins from ${download_site}/jenkins/plugins.tar.gz"
wget --quiet ${download_site}/jenkins/plugins.tar.gz    -O /root/.cache/jenkins-plugin-management-cli/plugins.tar.gz

log_info "copy plugins files to /var/lib/jenkins/plugins"
tar -C /var/lib/jenkins/ -xzf /root/.cache/jenkins-plugin-management-cli/plugins.tar.gz
# end -----------------------------------------------------------------------


log_info "enable jenkins to talk with docker"
usermod -aG sudo jenkins
usermod -aG docker jenkins
echo "jenkins  ALL=(ALL) NOPASSWD:/usr/bin/docker,/usr/local/bin/docker-compose" | tee /etc/sudoers.d/jenkins

log_block "set up maven settings"

mkdir /var/lib/jenkins/.m2
cat > /var/lib/jenkins/.m2/settings.xml <<EOF
<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0 http://maven.apache.org/xsd/settings-1.0.0.xsd">
  <mirrors>
    <mirror>
      <id>maven-public-mirror</id>
      <mirrorOf>*</mirrorOf>
      <name>maven-public-mirror</name>
      <url>${maven_public_mirror}</url>
    </mirror>
  </mirrors>
</settings>
EOF

chown -R jenkins:jenkins /var/lib/jenkins/

log_block "restart jenkins"
systemctl restart jenkins

sleep 300

JENKINS_USER_ID=$(id -u jenkins)
#chmod a+rw /var/run/docker.sock
mkdir -p /run/user/${JENKINS_USER_ID}
ln -s /var/run/docker.sock  /run/user/${JENKINS_USER_ID}/docker.sock
chown -R jenkins:jenkins /run/user/111/docker.sock


