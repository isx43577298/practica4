#! /bin/bash
# @isx43577298 ASIX M11-SAD Curs 2020
# iptables

#echo 1 > /proc/sys/ipv4/ip_forward

# Regles flush
iptables -F
iptables -X
iptables -Z
iptables -t nat -F

# Polítiques per defecte: 
iptables -P INPUT ACCEPT
iptables -P OUTPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -t nat -P PREROUTING ACCEPT
iptables -t nat -P POSTROUTING ACCEPT

# obrir el localhost
iptables -A INPUT  -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

# obrir la nostra ip
iptables -A INPUT -s 192.168.0.12 -j ACCEPT
iptables -A OUTPUT -d 192.168.0.12 -j ACCEPT


# ICMP  echo-requets:8, echo-reply:0
############################################
# No permetre fer pings cap a l'exterior
iptables -A OUTPUT -p icmp --icmp-type 8 -j DROP
# No podem fer pings cap al hostA
iptables -A OUTPUT -p icmp --icmp-type 8 -d 10.0.0.2 -j DROP
# No permetem respondre als pings que ens facin
iptables -A OUTPUT -p icmp --icmp-type 0 -j DROP
# No permetem rebre respostes de ping
iptables -A INPUT -p icmp --icmp-type 0 -j DROP

# Mostrar les regles generades
iptables -L -t nat

