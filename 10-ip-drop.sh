#! /bin/bash
# @isx43577298 ASIX M11-SAD Curs 2020
# iptables

echo 1 > /proc/sys/ipv4/ip_forward

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


Consultem i obrim DNS PRIMARI
iptables -A INPUT -s 192.168.0.12 -p udp  -m udp --sport 53 -j ACCEPT
iptables -A OUTPUT -d 192.168.0.12 -p udp -m udp --dport 53 -j ACCEPT

# Consultem i obrim DNS SECUNDARI

iptables -A INPUT -s 10.1.1.200 -p udp  -m udp --sport 53 -j ACCEPT
iptables -A OUTPUT -d 10.1.1.200 -p udp -m udp --dport 53 -j ACCEPT

#Consultem dhcp (obrim)
iptables -A INPUT -p udp --sport 67 -j ACCEPT
iptables -A OUTPUT -p udp --dport 67 -j ACCEPT
iptables -A INPUT -p udp --sport 68 -j ACCEPT
iptables -A OUTPUT -p udp --dport 68 -j ACCEPT

# Sincronitzem  el NTP (Network Time Protocol) amb enrutament (sistema de sicronització del rellotge del sistema).

iptables -A INPUT -p udp -m udp --sport 123 -j ACCEPT
iptables -A OUTPUT -p udp -m udp --dport 123 -j ACCEPT

# Consultem CUPS (Sistema d'impresio) (obrim)

iptables -A INPUT  -p tcp  --dport 631 -j ACCEPT
iptables -A OUTPUT -p tcp  --sport 631 -j ACCEPT

# Consultem servei xinetd (obrim)

iptables -A INPUT  -p tcp  --dport 3411 -j ACCEPT
iptables -A OUTPUT -p tcp  --sport 3411 -j ACCEPT

# Consultem X11-FORWARD (obrim)

iptables -A INPUT -p tcp --dport 6010 -j ACCEPT
iptables -A OUTPUT -p tcp --sport 6010 -j ACCEPT

#Consultem servei rpc (REMOTE PROCEDURE CALL) (obrim)
#PERMET CONNEXIÓ D'UNA APP A UN HOST SENSE PREOCUPAR-SE DE LA COMUNICACIÓ

iptables -A INPUT -p tcp --dport 111 -j ACCEPT
iptables -A OUTPUT -p tcp --sport 111 -j ACCEPT

# Consultem icmp (Linux IPv4 ICMP kernel module) (obrim)

iptables -A INPUT -p icmp --icmp-type echo-reply -j ACCEPT
iptables -A OUTPUT -p icmp --icmp-type echo-request -j ACCEPT

# Consultem servei ssh (obrim)
iptables -A INPUT -p tcp --dport 22 -j ACCEPT
iptables -A OUTPUT -p tcp --sport 22 -j ACCEPT

#Consultem servei http (obrim) 

#TOT EL QUE ENTRI AL PORT 80 de la maquina
iptables -A INPUT -p tcp --dport 80 -j ACCEPT
#TOT EL QUE SURTI DEL PORT 80
iptables -A OUTPUT -p tcp --sport 80 -m state --state RELATED,ESTABLISHED  -j ACCEPT
#Consultem servei ldap (obrim)
#ldap gandhi : 53110
iptables -A INPUT -p tcp --sport 389 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 389 -j ACCEPT
iptables -A INPUT -p tcp --sport 636 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 636 -j ACCEPT
iptables -A INPUT -p tcp --dport 53110 -j ACCEPT
iptables -A OUTPUT -p tcp --sport 53110 -j ACCEPT 

#Consultem servei smtp (obrim)

iptables -A INPUT -p tcp --dport 25 -j ACCEPT
iptables -A OUTPUT -p tcp --sport 25 -j ACCEPT

#Consultem servei echo (obrim)
#TOT EL QUE ENTRI/VINGUI D'UN PORT SOURCE 7
iptables -A INPUT -p tcp --sport 7 -j ACCEPT
#TOT EL QUE SURTI I VA AL PORT DESTÍ
iptables -A OUTPUT -p tcp --dport 7 -j ACCEPT

#Consultem servei daytime (obrim)
iptables -A INPUT -p tcp --sport 13 -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp --dport 13 -j ACCEPT

#Consultem servei ssh
iptables -A INPUT -p tcp --sport 22 -m state --state RELATED,ESTABLISHED -j ACCEPT 
iptables -A OUTPUT -p tcp --dport 22 -m state --state ESTABLISHED,RELATED -j ACCEPT

#Consultem tràfic UDP (ftp/tftp)

#Ofereix servei tftp
iptables -A INPUT -p udp --dport 69 -j ACCEPT
iptables -A OUTPUT -p udp --sport 69 -j ACCEPT

#oferir ports ftp
iptables -A INPUT -p udp --dport 20:21 -j ACCEPT
iptables -A OUTPUT -p udp --sport 20:21 -j ACCEPT

#obrir ports dinamics
iptables -A INPUT -p tcp --dport 49152:65535 -A ACCEPT


# Mostrar les regles generades
iptables -L -t nat

