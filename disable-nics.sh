#!/usr/bin/env bash

set -ex

if [[ -f /boot/mac_addresses ]]; then
  primary_mac=$(cat /boot/mac_addresses | awk -F= '/PRIMARY_MAC/ {print $2}')
  nmcli device status | grep -v disconnected | grep connected | awk '/ethernet/ {print $1}'
  for dev in $(nmcli device status | grep -v disconnected | grep connected | awk '/ethernet/ {print $1}'); do
    dev_mac=$(nmcli -g GENERAL.HWADDR dev show $dev | sed -e 's/\\//g' | tr '[A-Z]' '[a-z]')
    if [[ $dev_mac != $primary_mac ]]; then
        echo "disabling $dev"
        profile=$(nmcli -g GENERAL.CONNECTION dev show $dev)
        echo $profile
        nmcli conn down "$profile"
        nmcli conn mod "$profile" connection.autoconnect no
    fi
   done
else
  echo "no mac address file found"
fi
