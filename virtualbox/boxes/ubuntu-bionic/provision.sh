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

download_site=$1
org=$2
admin_user=$3
dev_user=$4
opt_size=$5
opt_verbose=$6
ubuntu_mirror=$7
timezone=$8
docker_mirror_1=$9
docker_mirror_2=${10}

K8S_VER="1.20.1"
CALICO_VER="3.17.1"


if [ ${opt_verbose} == "true" ]; then
  set -x
else
  set +x
fi

cat > /etc/profile <<EOF
export LC_ALL=en_US.UTF-8


export BLUE='\033[1;34m'
export PURPLE='\033[1;35m'
export NC='\033[0m'

function log_info() {
  local TM=\`date "+%Y-%m-%d %H:%M:%S"\`

  echo -e \${PURPLE}<\${TM}>\${BLUE} \$*\${NC}
}

function log_error() {
  local TM=\`date "+%Y-%m-%d %H:%M:%S"\`

  echo -e \${PURPLE}<\${TM}> \$*\${NC}
}

function log_block() {
  local TM=\`date "+%Y-%m-%d %H:%M:%S"\`

  echo -e "\${PURPLE}*******************************************************************\${NC}"
  echo -e "\${PURPLE}* \$*\${NC}"
  echo -e "\${PURPLE}* <\${TM}>\${NC}" 
  echo -e "\${PURPLE}*------------------------------------------------------------------\${NC}"
}

export download_site=${download_site}
export org=${org}
export admin_user=${admin_user}
export dev_user=${dev_user}
export opt_size=${opt_size}
export opt_verbose=${opt_verbose}
export ubuntu_mirror=${ubuntu_mirror}
export docker_mirror_1=${docker_mirror_1}
export docker_mirror_2=${docker_mirror_2}

export K8S_VER=${K8S_VER}
export CALICO_VER=${CALICO_VER}

EOF

source /etc/profile
log_info "etc/profile:"
cat /etc/profile


export DEBIAN_FRONTEND=noninteractive

# Set external DNS
# sed -i -e 's/#DNS=/DNS=8.8.8.8/' /etc/systemd/resolved.conf
# service systemd-resolved restart

log_block "set apt mirror"

cat > /etc/apt/sources.list <<EOF
deb ${ubuntu_mirror} bionic main restricted universe multiverse
deb-src ${ubuntu_mirror} bionic main restricted universe multiverse
deb ${ubuntu_mirror} bionic-security main restricted universe multiverse
deb-src ${ubuntu_mirror} bionic-security main restricted universe multiverse
deb ${ubuntu_mirror} bionic-updates main restricted universe multiverse
deb-src ${ubuntu_mirror} bionic-updates main restricted universe multiverse
deb ${ubuntu_mirror} bionic-proposed main restricted universe multiverse
deb-src ${ubuntu_mirror} bionic-proposed main restricted universe multiverse
deb ${ubuntu_mirror} bionic-backports main restricted universe multiverse
deb-src ${ubuntu_mirror} bionic-backports main restricted universe multiverse
EOF

log_info "/etc/apt/sources.list: "
cat /etc/apt/sources.list

log_block "apt-get update then upgrade"
apt-get update -qq
apt-get upgrade -qq -y

log_info "set timezone to ${timezone}"
ln -sf /usr/share/zoneinfo/${timezone} /etc/localtime && echo "${timezone}" > /etc/timezone

log_info "install more utilities"
apt-get install -qq -y linux-headers-$(uname -r) build-essential gcc make python zip cmake uuid tree jq
apt-get install -qq -y apt-transport-https bash-completion curl ebtables ethtool ca-certificates software-properties-common

log_block "install docker"
mkdir /etc/docker/
cat > /etc/docker/daemon.json <<EOF
{
    "registry-mirrors": [
      "${docker_mirror_1}",
      "${docker_mirror_2}"
    ]
}
EOF

log_info "/etc/docker/daemon.json:"
cat /etc/docker/daemon.json
log_info ""

# https://download.docker.com/linux/ubuntu/dists/bionic/pool/stable/amd64/containerd.io_1.3.9-1_amd64.deb
CONTAINERD_DEB=containerd.io_1.3.9-1_amd64.deb

log_info "download ${download_site}/docker/${CONTAINERD_DEB}"
wget --quiet "${download_site}/docker/${CONTAINERD_DEB}"

log_info "install ${CONTAINERD_DEB}"
dpkg -i ${CONTAINERD_DEB}

rm ${CONTAINERD_DEB}

# https://download.docker.com/linux/ubuntu/dists/bionic/pool/stable/amd64/docker-ce-cli_19.03.14~3-0~ubuntu-bionic_amd64.deb
DOCKER_CLI_DEB=docker-ce-cli_19.03.14~3-0~ubuntu-bionic_amd64.deb

log_info "download ${download_site}/docker/${DOCKER_CLI_DEB}"
wget --quiet "${download_site}/docker/${DOCKER_CLI_DEB}"

log_info "install ${DOCKER_CLI_DEB}"
dpkg -i ${DOCKER_CLI_DEB}

rm ${DOCKER_CLI_DEB}

# https://download.docker.com/linux/ubuntu/dists/bionic/pool/stable/amd64/docker-ce_19.03.14~3-0~ubuntu-bionic_amd64.deb
DOCKER_DEB=docker-ce_19.03.14~3-0~ubuntu-bionic_amd64.deb

log_info "download ${download_site}/docker/${DOCKER_DEB}"
wget --quiet "${download_site}/docker/${DOCKER_DEB}"

log_info "install ${DOCKER_DEB}"
dpkg -i ${DOCKER_DEB}

rm ${DOCKER_DEB}

log_box "install docker-compose"

# https://github.com/docker/compose/releases/download/1.27.4/docker-compose-Linux-x86_64
DOCKER_COMPOSE_BINARY=docker-compose-Linux-x86_64-1.27.4

log_info "download ${download_site}/docker/${DOCKER_COMPOSE_BINARY}"
curl --silent -L "${download_site}/docker/${DOCKER_COMPOSE_BINARY}" -o /usr/local/bin/docker-compose
chmod a+x /usr/local/bin/docker-compose

log_info "restart docker"
systemctl daemon-reload
systemctl restart docker

log_box "set up users: ${admin_user}, ${dev_user}"

log_info "add group: ${org}"
groupadd ${org}

log_info "allow group ${org} to ssh"
echo "AllowGroups root vagrant ${org}" >> /etc/ssh/sshd_config

log_info "disable root ssh"
#sed -i -e "s/PermitRootLogin yes/PermitRootLogin no/" /etc/ssh/sshd_config
echo "PermitRootLogin no" >> /etc/ssh/sshd_config

log_info "restart sshd"
systemctl restart sshd

## set up admin user -----------------------------------------------------------
log_info "add admin user: ${admin_user}"
useradd -g ${admin_user} --home-dir /home/${admin_user} --create-home --shell /bin/bash ${admin_user}
usermod -aG sudo ${admin_user}
usermod -aG docker ${admin_user}
usermod -aG ${org} ${admin_user}

# echo "${admin_user}  ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
echo "${admin_user}  ALL=(ALL) NOPASSWD:ALL" | tee /etc/sudoers.d/${admin_user}

log_info "generating ssh key for ${admin_user}"
mkdir -p /home/${admin_user}/.ssh
ssh-keygen -P "" -t rsa -C "${admin_user}@${org}" -f /home/${admin_user}/.ssh/id_rsa
cat /home/${admin_user}/.ssh/id_rsa.pub >> /home/${admin_user}/.ssh/authorized_keys
chown -R ${admin_user}:${admin_user} /home/${admin_user}/.ssh

## set up dev user -------------------------------------------------------------
log_info "add dev user: ${dev_user}"
useradd --user-group --home-dir /home/${dev_user} --create-home --shell /bin/bash ${dev_user}
usermod -aG sudo ${dev_user}
usermod -aG docker ${dev_user}
usermod -aG ${org} ${dev_user}

echo "${dev_user}  ALL=(ALL) NOPASSWD:/usr/bin/docker,/usr/local/bin/docker-compose" | tee /etc/sudoers.d/${dev_user}

log_info "generating ssh key for ${dev_user}"
mkdir -p /home/${dev_user}/.ssh
ssh-keygen -P "" -t rsa -C "${dev_user}@${org}" -f /home/${dev_user}/.ssh/id_rsa
cat /home/${dev_user}/.ssh/id_rsa.pub >> /home/${dev_user}/.ssh/authorized_keys
chown -R ${dev_user}:${dev_user} /home/${dev_user}/.ssh

apt autoremove

# set up root ca
log_block "set up root CA"
# install to Debian/Ubuntu Certificate Storage
installedCaCrt=/etc/ssl/certs/example_root_ca.pem
cp /home/vagrant/certs/ca.crt ${installedCaCrt}
log_info "root ca certification: ${installedCaCrt}"
chown root:root ${installedCaCrt}
chmod 644 ${installedCaCrt}
c_rehash
update-ca-certificates

installedCaKey=/etc/ssl/private/example_root_ca.key
cp /home/vagrant/certs/ca.key ${installedCaKey}
log_info "root ca private key: ${installedCaKey}"
chown root:root ${installedCaKey}
chmod 640 ${installedCaKey}

# install server cert & key
log_block "set up wildcard server certification and private key"

installedServerCrt=/etc/ssl/certs/example.com.pem
cp /home/vagrant/certs/example.com.crt ${installedServerCrt}
log_info "server wildcard certification: ${installedServerCrt}"
chown root:root ${installedServerCrt}
chmod 644 ${installedServerCrt}

installedServerKey=/etc/ssl/private/example.com.key
cp /home/vagrant/certs/example.com.key ${installedServerKey}
log_info "server wildcard private key: ${installedServerKey}"
chown root:root ${installedServerKey}
chmod 640 ${installedServerKey}

