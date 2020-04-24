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

# Regles amb trafic related, established
###################################################
# permetre navegar web
iptables -A OUTPUT -p tcp --dport 80 -j ACCEPT
iptables -A INPUT  -p tcp --sport 80 -j ACCEPT
# filtrant tràfic només de resposta
iptables -A OUTPUT -p tcp --dport 80 -j ACCEPT
iptables -A INPUT  -p tcp --sport 80 -m tcp -m state --state RELATED,ESTABLISHED  -j ACCEPT
# oferir el servei web, permetre només respostes a peticions establertes.
iptables -A OUTPUT -p tcp --sport 80 -m tcp -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A INPUT -p tcp --dport 80 -j ACCEPT


# Mostrar les regles generades
iptables -L -t nat

