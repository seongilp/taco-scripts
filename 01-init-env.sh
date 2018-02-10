#!/bin/bash
(( EUID )) && echo You need to be root. && exit 1
set -ex

echo LC_ALL="en_US.UTF-8" >> /etc/environment
echo LANG="en_US.UTF-8" >> /etc/environment

echo LC_ALL="en_US.UTF-8" >> ~/.bashrc
echo LANG="en_US.UTF-8" >> ~/.bashrc

export LC_ALL="en_US.UTF-8"
export PATH=$PATH:/usr/local/bin

EXIP=$(ip route get 8.8.8.8 | awk '/8.8.8.8/ {print $7}')
echo $EXIP 'taco-aio' >> /etc/hosts

OS_DISTRO=$(cat /etc/os-release | grep "PRETTY_NAME" | sed 's/PRETTY_NAME=//g' | sed 's/["]//g' | awk '{print $1}')
if [ $OS_DISTRO == Red ]; then
    yum update -y
    yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-$(rpm -E '%{rhel}').noarch.rpm
    yum install -y yum-utils python-pip python-devel
    yum groupinstall -y 'development tools'
    yum -y install ceph-common git jq nmap bridge-utils net-tools
elif [ $OS_DISTRO == CentOS ]; then
    yum update -y
    yum install -y epel-release
    yum install -y yum-utils python-pip python-devel
    yum groupinstall -y 'development tools'
    yum -y install ceph-common git jq nmap bridge-utils net-tools
elif [ $OS_DISTRO == Ubuntu ]; then
    apt-get update
    apt-get -y upgrade
    apt install -y python python-pip
    apt install -y ceph-common git jq nmap bridge-utils ipcalc
else
    echo "This Linux Distribution is NOT supported"
fi
pip install --upgrade pip
pip install 'pyOpenSSL==16.2.0'
pip install 'python-openstackclient'

swapoff -a
sed -i '/swap/s/^/#/g' /etc/fstab
modprobe rbd
ssh-keygen -b 2048 -t rsa -f ~/.ssh/id_rsa -q -N ""
