# This script help easily setup port forwarding in a brand new Linux/VM.
# Require root permission.
# Example Usage:
# $ ./port_forwarding.sh 80 eth0 eth1 120.55.151.115
#
#!/bin/bash

echo 1 > /proc/sys/net/ipv4/ip_forward
sed -ie '/net.ipv4.ip_forward/s/^#*\s*//g' /etc/sysctl.conf
sysctl -p
sysctl --system

PORT=$1
IN_IF=$2
OUT_IF=$3
DEST_ADDR=$4

IN_ADDR=`ifconfig $IN_IF | awk '/inet /{print $2}' | cut -d: -f 2`
OUT_ADDR=`ifconfig $OUT_IF | awk '/inet /{print $2}' | cut -d: -f 2`

iptables -A FORWARD -i $IN_IF -o $OUT_IF -p tcp --syn --dport $PORT -m conntrack --ctstate NEW -j ACCEPT
iptables -A FORWARD -i $IN_IF -o $OUT_IF -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -i $OUT_IF -o $IN_IF -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

iptables -t nat -A PREROUTING -i $IN_IF -p tcp --dport $PORT -j DNAT --to-destination $DEST_ADDR
iptables -t nat -A POSTROUTING -o $OUT_IF -p tcp --dport $PORT -d $DEST_ADDR -j SNAT --to-source $OUT_ADDR

