#!/bin/bash

## Prevent the execution of the script if the user has no root privileges
if [ "${UID:-$(id -u)}" -ne 0 ]; then
    echo 'Error: root privileges are needed to run this script'
    exit 87 # Not root exit code
fi

if [ $# -eq 0 ]; then
	echo "No arguments are provided"
	echo "Please run with auto-run.sh activate or auto-run.sh root [payload] to continue"
fi

COMMAND=$1
PAYLOAD=""

if [ "$COMMAND" != "activate" -a "$COMMAND" != "root" ]; then
	echo "Invalid command given $COMMAND"
	exit -1
fi

echo "Running: $COMMAND"

if [ $# -eq 2 -a "$COMMAND" = "root" ]; then
	PAYLOAD=$2
	echo "Payload: $PAYLOAD"
fi

apt-get install -y dhcpcd hostapd dnsmasq

echo "Creating backup of /etc/dhcpcd.conf -> /etc/dhcpcd.conf.bak"
cp /etc/dhcpcd.conf /etc/dhcpcd.conf.bak

echo "Creating backup of /etc/dnsmasq.conf -> /etc/dnsmasq.conf.bak"
cp /etc/dnsmasq.conf /etc/dnsmasq.conf.bak

echo "Creating backup of /etc/hostapd/hostapd.conf -> /etc/hostapd/hostapd.conf.bak"
cp /etc/hostapd/hostapd.conf /etc/hostapd/hostapd.conf.bak

echo "Copying dhcpcd configuration"
cp dhcpcd.conf /etc/dhcpcd.conf

echo "Copying dnsmasq configuration"
cp dnsmasq.conf /etc/dnsmasq.conf

echo "Copying hostapd configuration"
cp hostapd.conf /etc/hostapd/hostapd.conf

if [ "$COMMAND" = "activate" ]; then
	./activate-toon.sh
elif [ "$COMMAND" = "root" ]; then
	if [ "$PAYLOAD" = "" ]; then
		./root-toon.sh
	else
		./root-toon.sh $PAYLOAD
	fi
fi

echo "Resotring backup of /etc/dhcpcd.conf"
cp /etc/dhcpcd.conf.bak /etc/dhcpcd.conf

echo "Restoring backup of /etc/dnsmasq.conf"
cp /etc/dnsmasq.conf.bak /etc/dnsmasq.conf

echo "Restoring backup of /etc/hostapd/hostapd.conf"
cp /etc/hostapd/hostapd.conf.bak /etc/hostapd/hostapd.conf

