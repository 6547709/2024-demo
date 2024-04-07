#!/bin/bash

# Optimized Bootstrap script

set -euo pipefail

# Function to check if customization already ran
check_customization() {
    if [ -e /usr/local/customization/ran_customization ]; then
        exit
    fi
}

# Functions to convert mask to CIDR and vice versa
mask2cdr() {
    local x=${1##*255.}
    set -- 0^^^128^192^224^240^248^252^254^ $(( (${#1} - ${#x})*2 )) ${x%%.*}
    x=${1%%$3*}
    echo $(( $2 + (${#x}/4) ))
}

cdr2mask() {
    set -- $(( 5 - ($1 / 8) )) 255 255 255 255 $(( (255 << (8 - ($1 % 8))) & 255 )) 0 0 0
    [ $1 -gt 1 ] && shift $1 || shift
    echo ${1-0}.${2-0}.${3-0}.${4-0}
}

# Function to get property from VM tools
get_property() {
    vmtoolsd --cmd "info-get guestinfo.ovfEnv" | grep "guestinfo.$1" | awk -F 'oe:value="' '{print $2}' | awk -F '"' '{print $1}'
}

# Function to configure network settings
configure_network() {
    UUID=$(nmcli con show ens192 | grep connection.uuid | awk '{print $2}')
    NETMASK_CIDR=$(mask2cdr ${NETMASK})

    echo -e "\e[92mConfiguring Static IP Address ..." > /dev/console
    nmcli con mod ${UUID} ipv4.addresses ${IP_ADDRESS}/${NETMASK_CIDR}
    nmcli con mod ${UUID} ipv4.gateway ${GATEWAY}
    nmcli con mod ${UUID} ipv4.method manual
    nmcli con mod ${UUID} ipv4.dns "${DNS_SERVERS}"
    nmcli con mod ${UUID} ipv4.dns-search ${SEARCH_DOMAINS}
    nmcli con up ${UUID}
}

# Function to configure NTP server
configure_ntp() {
    echo -e "\e[92mConfiguring ntp ..." > /dev/console
    sed -i '/^server /d' /etc/chrony.conf
    if [ -z "${NTP_SERVERS}" ]; then
        NTP_SERVERS="ntp.aliyun.com ntp1.aliyun.com"
    fi
    for server in $NTP_SERVERS; do
        echo "server $server iburst" >> /etc/chrony.conf
    done
    systemctl restart chronyd
}

# Function to add cloud_user account
add_cloud_user() {
    useradd -m -s /bin/bash cloud-user
    echo "cloud-user:${USER_PASSWORD}" | /usr/sbin/chpasswd
    echo "cloud-user ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/cloud-user
}
disabled_root_user() {
    sed -i 's/PermitRootLogin yes/PermitRootLogin no/g' /etc/ssh/sshd_config
    systemctl restart sshd
}

# Function to register node-exporter to consul
register_node_exporter() {
    echo -e "\e[92mConfiguring node-exporter ..." > /dev/console
    sed -i "s/@@IP_ADDRESS@@/${IP_ADDRESS}/g" /usr/local/node-exporter.json
    sed -i "s/@@HOSTNAME@@/${HOSTNAME}/g" /usr/local/node-exporter.json
    curl -k -XPUT --data @/usr/local/node-exporter.json https://mgmt-consul.corp.local/v1/agent/service/register
}

# Function to clean kickstart file
clean_kickstart() {
    rm -rf /root/*.cfg /root/*.log
}

# Function to ensure customization doesn't run again
finalize_customization() {
    mkdir -p /usr/local/customization
    touch /usr/local/customization/ran_customization
}

# Main script starts here
check_customization

DEBUG=$(get_property "debug")
LOG_FILE=/var/log/bootstrap.log
[ "${DEBUG}" == "True" ] && LOG_FILE=/var/log/rocky-customization-debug.log && set -x && exec 2> ${LOG_FILE}

HOSTNAME=$(get_property "hostname")
IP_ADDRESS=$(get_property "ipaddress")
NETMASK=$(get_property "netmask")
GATEWAY=$(get_property "gateway")
DNS_SERVERS=$(get_property "dnss")
SEARCH_DOMAINS=$(get_property "domains")
NTP_SERVERS=$(get_property "ntps")
USER_PASSWORD=$(get_property "user_password")
DISABLEDROOT=$(get_property "disabledroot")
SEARCH_DOMAINS=${SEARCH_DOMAINS:-corp.local}
hostnamectl set-hostname $HOSTNAME
if [ -n "${IP_ADDRESS}" ]; then
    configure_network
fi
configure_ntp
add_cloud_user
if [ -n "${DISABLEDROOT}" ]; then
    disabled_root_user
fi
clean_kickstart
finalize_customization
