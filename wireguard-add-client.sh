#!/usr/bin/env bash
function next_ip() {
	LINE=$(grep "AllowedIPs" /etc/wireguard/wg0.conf | tail -1)
	IFS=',' read -ra LASTADDR <<< "$LINE"		
	IFS=' ' read -ra IPADDR <<< "${LASTADDR[0]}"
	IFS='/' read -ra IP_W_NO_SUBNET <<< "${IPADDR[${#IPADDR[@]}-1]}"
	IFS='.' read -ra LAST_OCTET <<< "${IP_W_NO_SUBNET[0]}"
	lastoct=${LAST_OCTET[${#LAST_OCTET[@]}-1]}
	if [ "$lastoct" -eq 99 ]; then
		echo "There is too many clients. Fix you script or delete some clients"
		exit
	fi

	iv4=${IPADDR[${#IPADDR[@]}-1]}
	newipv4=$(echo "$iv4" | awk -F/ '{print $1"."$2}' | awk -F. '{print $1"."$2"."$3"."$4+1"/"$5}')

	iv6=${LASTADDR[1]}
	newipv6=$(echo "$iv6" | awk -F/ '{print $1":"$2}' | awk -F: '{print $1":"$2":"$3":"$4+1"/"$5}')
	echo "$newipv4, $newipv6"
}

function main() {
	if [ "$EUID" -ne 0 ]
	then
		echo "Please run the script as root"
		exit
	fi

	cd /etc/wireguard
	umask 077
	read -p "Enter the new username: " name

	# Adding client to server configuration 
	echo "##### Adding client to server configuration #####"

	# Key-pair generation for the new client
	wg genkey | tee "${name}.key" | wg pubkey > "${name}.pub"
	# PSK key generation for the new client
	wg genpsk > "${name}.psk"

	# Getting the next available ip addresses 
	ipaddr=$(next_ip)

	# Adding the new client to the server configuration
	echo "[Peer]" >> /etc/wireguard/wg0.conf
	echo "PublicKey = $(cat "${name}.pub")" >> /etc/wireguard/wg0.conf
	echo "PresharedKey = $(cat "${name}.psk")" >> /etc/wireguard/wg0.conf
	echo "AllowedIPs = $ipaddr" >> /etc/wireguard/wg0.conf

	# Restarting the server
	echo "##### Resarting the VPN server #####"
	systemctl restart wg-quick@wg0

	# Creating the client configuration
	echo "##### Creating the client configuration #####"
	echo "[Interface]" > "${name}.conf"
	echo "Address = $ipaddr" >> "${name}.conf" 
	echo "DNS = 10.100.0.1" >> "${name}.conf"
	echo "PrivateKey = $(cat "${name}.key")" >> "${name}.conf"
	echo "[Peer]" >> "${name}.conf"
	echo "AllowedIPs = 10.100.0.1/32, fd08::1/128" >> "${name}.conf"
	echo "Endpoint = <your public ip or you domain name here>:47111" >> "${name}.conf"
	echo "PersistentKeepalive = 25" >> "${name}.conf"
	echo "PublicKey = $(cat server.pub)" >> "${name}.conf"
	echo "PresharedKey = $(cat "${name}.psk")" >> "${name}.conf"
	echo "##### Finisshed creating the client configuration #####"


	cp /etc/wireguard/${name}.conf <user home dir path here (ex. /home/pi)>
	chown -R pi <user home dir path here>/${name}.conf
	echo "##### Configuration file for user $name copied to /home/pi #####"

	qrencode -t ansiutf8 -r "/etc/wireguard/${name}.conf"

}

main
