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

# port 80 tancat a tothom: drop
iptables -A INPUT -p tcp --dport 80 -j ACCEPT
# port 2080 tancat a tothom 
iptables -A INPUT -p tcp --dport 2080 -j DROP
# port 2080 tancat a tothom 
iptables -A INPUT -p tcp --dport 2080 -j REJECT
# port 3080 tancat a tothom obert a hostA
iptables -A INPUT -p tcp --dport 3080 -s 172.0.0.2 -j ACCEPT
iptables -A INPUT -p tcp --dport 3080 -j REJECT
# port 4080 obert a tohom tancat a hostB
iptables -A INPUT -p tcp --dport 4080 -s 10.0.0.2 -j REJECT
iptables -A INPUT -p tcp --dport 4080 -j ACCEPT
# port 5080 tancat a tothom excepte ne19 (obert), pero no al seu hostA (tancat)
iptables -A INPUT -p tcp --dport 5080 -s 10.0.0.0/8 -j ACCEPT
iptables -A INPUT -p tcp --dport 5080 -s 10.0.0.2 -j DROP
iptables -A INPUT -p tcp --dport 5080 -j ACCEPT
##############################################

# Mostrar les regles generades
iptables -L -t nat

