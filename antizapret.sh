#!/bin/sh

TUN=`ifconfig | grep tun | awk '{print $1}'`
MIN_ROUTES="15"

if [ "$TUN" == "" ]; then
	exit;
fi

CHECK_ROUTES=`route | wc -l`

if [ "$CHECK_ROUTES" -gt "$MIN_ROUTES" ]; then
	exit;
fi

route add 8.8.8.8/32 dev $TUN;
route add 8.8.4.4/32 dev $TUN;
route add 77.88.8.8/32 dev $TUN;

wget "http://reestr.rublacklist.net/api/ips" -O /tmp/ip_list;
LIST=`cat /tmp/ip_list | sed 's/;/\n/g' | grep -v '"' | awk -F. '{print $1"."$2"."$3".0/24"}' | sort | uniq`

for IP in $LIST
do
	echo "Adding $IP..."
	route add -net $IP dev $TUN;
done

REMOTE_IP=`cat /etc/openvpn/config.conf | grep remote | tail -n1 | awk '{print $2}'`;
DEFAULT_GW=`route | grep default | awk '{print $2}'`

route add ${REMOTE_IP}/32 gw $DEFAULT_GW;  

rm -rf /tmp/ip_list;
