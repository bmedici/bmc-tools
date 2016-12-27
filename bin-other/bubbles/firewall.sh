#!/bin/bash
# set -x
#
### BEGIN INIT INFO
# Provides:          firewall
# Required-Start:    $named $network $syslog
# Required-Stop:     $named $network $syslog
# Should-Start:
# Should-Stop:
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Firewall script
# Description:       Initializes simple iptables rules for this specific server
### END INIT INFO
#
IPT=/sbin/iptables
IF=eth0
#set -x

acceptboth () {
	accept tcp $1 $2
	accept udp $1 $2
	}
accept () {
	local proto="$1"
	local port="$2"
	local source="$3"

	for int in $IF 
	do
		if [ -z "$source" ]
			then $IPT -A INPUT -i $int -p $proto --dport $port -j ACCEPT
			else $IPT -A INPUT -i $int -p $proto --dport $port --source "$source" -j ACCEPT
		fi
	done
	}	
reset () {
	$IPT -F
	$IPT -F INPUT
	$IPT -F OUTPUT
	$IPT -F FORWARD
	$IPT -F -t nat
	$IPT -X
	$IPT -P INPUT ACCEPT
	$IPT -P OUTPUT ACCEPT
	$IPT -P FORWARD ACCEPT
	}
prepare () {
	$IPT -A INPUT -i $IF -m state --state ESTABLISHED,RELATED -j ACCEPT
	$IPT -A INPUT -i $IF -p icmp -j ACCEPT
	$IPT -t nat -A POSTROUTING -o $IF -j MASQUERADE
	echo 1 > /proc/sys/net/ipv4/ip_forward
	}
lock () {
	#$IPT -A INPUT -j LOG
	$IPT -A INPUT -i $IF -j DROP
	#$IPT -P INPUT DROP
	}

case "$1" in
	start)
		reset
		prepare
		
		# simple services
		accept tcp 22
		acceptboth 123
		accept tcp 21

		# port-forarding CDN
		accept tcp 22130
		accept tcp 2240
		accept tcp 8040

		# vmware
		accept tcp 8222
		accept tcp 8333
		accept tcp 902
		
		# dns for iodined
		accept udp 53

		# ldap
		accept tcp 389
		accept tcp 636

		# web
		accept tcp 80
		accept tcp 443
		
		# web
		accept tcp 16514

		# mysql replication
		accept tcp 3306 crush.bmconseil.com		

		# email
		#accept tcp 25 bourse.brunom.net
		accept tcp 25
		accept tcp 143
		accept tcp 993
		accept tcp 8080

		# teamspeak
		accept udp 8767
		accept tcp 14534

		# rsync
		accept tcp 873
		accept tcp 873 bourse.brunom.net
		accept tcp 873 crush.bmconseil.com

		# icmp
		#accept icmp proxy.ovh.net
		#accept icmp proxy.p19.ovh.net
		#accept icmp proxy.rbx.ovh.net
		#accept icmp ping.ovh.net
		#accept icmp lille.brunom.net
		

		lock
		exit 0
	;;

	stop)
		$IPT -F INPUT
		exit 0
	;;
	
	*)
	echo "Usage: $0 {start|stop}"
	exit 1
	;;
esac
