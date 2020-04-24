# PRACTICA 4: IPTABLES - FIREWALLS

Gustavo Tello Beltran - M11SAD

## Estructura

- Host local (portatil)

- Host exterior (docker hostA - xarxa net19)

```
# Xarxa net19
[root@localhost IPTABLES]# docker network inspect net19 | grep Subnet
                    "Subnet": "10.0.0.0/8"

# Posar en marxa el docker, exemple:
[gustavo@localhost IPTABLES]$ docker run --rm --name hostA -h hostA --net net19 -p 7:7 -p 13:13 -p 80:80 -d isx43577298/net19:nethost

```

### CONCEPTES

* -j: especifica l'objectiu de la regla
* -d: destí
* -s: origen
* -F: elimina totes les regles
* -A: append
* -P: politica d'accept o drop
* -Z: omple de zeros els comptadors de paquest i bytes de totes les cadenes
* -I: insert
* --dport: configura el port de desti pel paquet.
* --sport: configura el port d'origen pel paquet.
* -p: protocol
* DROP: no notifica el moment de l'error de connexió, es queda l'espera.
* REJECT: informa de l'error 
* RELATED: el paquet seleccionat está inicant una nova connexió en algun punt de la connexió existent
* ESTABLISHED: el paquet seleccionat s'asocia amb altres paquets en una connexió establerta
* INVALID: el paquet seleccionat no pot asociar-se a una connexió coneguda
* NEW: el paquet seleccionat está creant una nova connexió o está formant part d'una connexió desconeguda

### Exemple 1

 * **ip-default.sh**

Exemple de configuracio iptables que esborra les regles actuals, estableix una politica per
defecte de tot obert, permet tot el trafic IN/OUT del loopback i de la propia adreça IP. 

Accions basiques de configuracio d'un script de iptables:
   * Esborar les regles (flush) i comptadors actuals
   * Regles per defecte
   * Obrir la connectivitat propia al loopback i a la propia adreça ip
   * Llistar les regles


```
[root@localhost IPTABLES]# ./ip-default.sh
Chain PREROUTING (policy ACCEPT)
target     prot opt source               destination         
Chain INPUT (policy ACCEPT)
target     prot opt source               destination         
Chain OUTPUT (policy ACCEPT)
target     prot opt source               destination         
Chain POSTROUTING (policy ACCEPT)
target     prot opt source               destination         
Chain DOCKER (0 references)
target     prot opt source               destination 
```

### Exemple 2

 * **01-ip-input.sh**

    Regles INPUT.

    Exemples basics de filtrats INPUT. Jugant amb el port 80
    s'han redefinit ports alternatius on aplicar regles de filtrat d'entrada.
    Les classiques regles
    * Port 80 obert a tothom
    * Port 2080 tancat a tothom amb reject
    * Port 2080 tancat a tothom amb drop
    * Port 3080 tancat a tothom excepte hostA
    * Port 4080 obert a tothom excepte hostA
    * Port 5080 tancat a tothom excepte ne19 (obert), pero no al seu hostA (tancat)
    * pendent: obert a tothom, tancat a net19 i obert a hostA


```
# Port 80 obert a tothom
 
[root@hostA docker]# telnet 192.168.0.12 80
Trying 192.168.0.12...
Connected to 192.168.0.12.
Escape character is '^]'.
GET / HTTP/1.0

HTTP/1.1 403 Forbidden
Date: Wed, 22 Apr 2020 15:47:18 GMT
Server: Apache/2.4.34 (Fedora)
Last-Modified: Fri, 20 Jul 2018 10:43:23 GMT
ETag: "122a-5716bf70088c0"
Accept-Ranges: bytes
Content-Length: 4650
Connection: close
Content-Type: text/html; charset=UTF-8

@isx43577298 ASIX M11-SAD
Connection closed by foreign host.

# Port 2080 tancat a tothom amb reject
[root@hostA docker]# telnet 192.168.0.12 2080
Trying 192.168.0.12...
telnet: connect to address 192.168.0.12: Connection refused

# Port 2080 tancat a tothom amb drop
[root@hostA docker]# telnet 192.168.0.12 2080
Trying 192.168.0.12...

# Port 3080 tancat a tothom excepte hostA
[root@hostA docker]# telnet 192.168.0.12 3080
Trying 192.168.0.12...
Connected to 192.168.0.12.
Escape character is '^]'.
GET / HTTP/1.0

HTTP/1.1 403 Forbidden
Date: Wed, 22 Apr 2020 15:52:45 GMT
Server: Apache/2.4.34 (Fedora)
Last-Modified: Fri, 20 Jul 2018 10:43:23 GMT
ETag: "122a-5716bf70088c0"
Accept-Ranges: bytes
Content-Length: 4650
Connection: close
Content-Type: text/html; charset=UTF-8

@isx43577298 ASIX M11-SAD
Connection closed by foreign host.


# Port 4080 obert a tothom excepte hostA
[root@hostA docker]# telnet 192.168.0.12 4080
Trying 192.168.0.12...
telnet: connect to address 192.168.0.12: Connection refused

# Port 5080 tancat a tothom excepte ne19 (obert), pero no al seu hostA (tancat)
[root@hostA docker]# telnet 192.168.0.12 5080
Trying 192.168.0.12...

```



 * **ip-02-output.sh**


    Regles OUTPUT.

    Exemples basics de filtrats OUTPUT. Jugant amb el port 13
    s'han redefinit ports alternatius on aplicar regles de filtrat de sortida.
    * Accedir a qualsevol host/port extern
    * Accedir a qualsevol port extern 13.
    * Accedir a qualsevol port 2013 excepte el del hostA
    * Denegar l’accés a qualsevol port 3013, pero permetent accedir al 3013 de hostA.
    * Permetre accedir al port 4013 de tot arreu, excepte dels hosts de la xarxa net19, però si permetent accedir al port 4013 del hostA.
    * Xapar l’accés a qualsevol port 80, 13, 7.
    * No permetre accedir al hostA.
    * No permetre accedir a la xarxa net19
    * No permetre accedir a la xarxa net19 excepte per ssh.

```
# Accedir a qualsevol host/port extern 
[root@hostA docker]# telnet 192.168.0.12 7
Trying 192.168.0.12...
Connected to 192.168.0.12.
Escape character is '^]'.
holaaaaaa
holaaaaaa

# Accedir a qualsevol port extern 13.
[root@hostA docker]# telnet 192.168.0.12 13
Trying 192.168.0.12...
Connected to 192.168.0.12.
Escape character is '^]'.
Thu Apr 23 18:09:36 UTC 2020
Connection closed by foreign host.

# Denegar l’accés a qualsevol port 3013, pero permetent accedir al 3013 de hostA.
[root@hostA docker]# telnet 192.168.0.12 2013
Trying 192.168.0.12...
Connected to 192.168.0.12.
Escape character is '^]'.
Thu Apr 23 18:12:22 UTC 2020
Connection closed by foreign host.

# Permetre accedir al port 4013 de tot arreu, excepte dels hosts de la xarxa net19, però si permetent accedir al port 4013 del hostA.
[root@hostA docker]# telnet 192.168.0.12 4013
Trying 192.168.0.12...
Connected to 192.168.0.12.
Escape character is '^]'.
Thu Apr 23 18:13:13 UTC 2020
Connection closed by foreign host.

# Xapar l’accés a qualsevol port 80, 13, 7.
[root@hostA docker]# telnet 192.168.0.12 80
Trying 192.168.0.12...
telnet: connect to address 192.168.0.12: Connection refused

[root@hostA docker]# telnet 192.168.0.12 13
Trying 192.168.0.12...
telnet: connect to address 192.168.0.12: Connection refused

[root@hostA docker]# telnet 192.168.0.12 7
Trying 192.168.0.12...
telnet: connect to address 192.168.0.12: Connection refused

# No permetre accedir al hostA.
[root@hostA docker]# telnet 192.168.0.12
Trying 192.168.0.12...
telnet: connect to address 192.168.0.12: Connection refused

# No permetre accedir a la xarxa net19 excepte per ssh.
[root@hostA docker]# telnet 192.168.0.12 22
Trying 192.168.0.12...
Connected to 192.168.0.12.
Escape character is '^]'.
SSH-2.0-OpenSSH_7.6

```


 * **ip-03-established.sh**

    Identificar trafic de resposta (RELATED, ESTABLISHED).
    * Permetre "navegar per internet". És a dir, accedir a qualsevol servidor
      web extern i acceptar només les respostes.
    * "Ser un servidor web". permetre que accedeixin al nostre servei web i 
      permetre únicament les respostes de sortida.

```
# permetre navegar web
[root@hostA docker]# telnet 192.168.0.12 3080
Trying 192.168.0.12...
Connected to 192.168.0.12.
Escape character is '^]'.
GET / HTTP/1.0

HTTP/1.1 403 Forbidden
Date: Wed, 23 Apr 2020 18:39:45 GMT
Server: Apache/2.4.34 (Fedora)
Last-Modified: Fri, 20 Jul 2018 10:43:23 GMT
ETag: "122a-5716bf70088c0"
Accept-Ranges: bytes
Content-Length: 4650
Connection: close
Content-Type: text/html; charset=UTF-8

@isx43577298 ASIX M11-SAD
Connection closed by foreign host.

```

 * **ip-04-icmp.sh**

    Trafic ICMP de ping request (8) i ping reply (0).
    * No permetre fer pings a l'exterior.
    * No permetre fer pings al hostA.
    * No respondre als pings que ens facin
    * No acceptem, rebre respostes ping

```
# No permetre fer pings a l'exterior.
[root@localhost IPTABLES]# ping 10.0.0.2
PING 10.0.0.2 (10.0.0.2) 56(84) bytes of data.
ping: sendmsg: Operation not permitted
ping: sendmsg: Operation not permitted
ping: sendmsg: Operation not permitted
^C
--- 10.0.0.2 ping statistics ---
3 packets transmitted, 0 received, 100% packet loss, time 93ms

# No permetre fer pings al hostA.
[root@localhost IPTABLES]# ping 10.0.0.2
PING 10.0.0.2 (10.0.0.2) 56(84) bytes of data.
ping: sendmsg: Operation not permitted
ping: sendmsg: Operation not permitted
ping: sendmsg: Operation not permitted
^C
--- 10.0.0.2 ping statistics ---
3 packets transmitted, 0 received, 100% packet loss, time 60ms



# No respondre als pings que ens facin
[root@hostA docker]# ping 192.168.0.12
PING 192.168.0.12 (192.168.0.12) 56(84) bytes of data.



^C
--- 192.168.0.12 ping statistics ---
6 packets transmitted, 0 received, 100% packet loss, time 5117ms


# No acceptem, rebre respostes ping
[root@hostA docker]# ping 192.168.0.12
PING 192.168.0.12 (192.168.0.12) 56(84) bytes of data.

```

 * **ip-05-nat.sh**
    
    Activar NAT per a dues xarxes internes. Podem crear dues xarxes (xarxaA i xarxaB) 
    de docker i engegar dos hosts (isx43577298/net19:nethost) a cada xarxa. 
    * Verificar que 'abans de fer res' els hosts de docker tenen accés extern i a internet.
    * Eliminar totes les refles de iptables aplicant ip-default.sh. Ara els hosts són
      interns, no es fa nat, per tant no tenen accés a l'exterior (hostA1, 8.8.8.8, etc).
    * Aplicar NAT per a les dues xarxes. verificar que tornen a tenir connectivitat a l'exterior.
       
```
docker network create netA
docker network create netB 
docker run --rm --name hostA1 -h hostA1 --net netA --privileged -d isx43577298/net19:nethost
docker run --rm --name hostA1 -h hostA1 --net netA --privileged -d isx43577298/net19:nethost 
docker run --rm --name hostA2 -h hostA2 --net netA --privileged -d isx43577298/net19:nethost
docker run --rm --name hostB1 -h hostB1 --net netB --privileged -d isx43577298/net19:nethost
docker run --rm --name hostB2 -h hostB2 --net netB --privileged -d isx43577298/net19:nethost

[gustavo@localhost IPTABLES]$ docker network inspect netA | grep Subnet
                    "Subnet": "172.19.0.0/16",

[gustavo@localhost IPTABLES]$ docker network inspect netB | grep Subnet
                    "Subnet": "172.20.0.0/16",

# Activem la NAT
[root@localhost IPTABLES]# echo 1 > /proc/sys/net/ipv4/ip_forward
[root@localhost IPTABLES]# cat /proc/sys/net/ipv4/ip_forward
1

# Comprovem connexió amb l'exterior
[root@hostA1 docker]# ping 192.168.0.12
PING 192.168.0.12 (192.168.0.12) 56(84) bytes of data.
64 bytes from 192.168.0.12: icmp_seq=1 ttl=64 time=0.107 ms
64 bytes from 192.168.0.12: icmp_seq=2 ttl=64 time=0.122 ms
64 bytes from 192.168.0.12: icmp_seq=3 ttl=64 time=0.129 ms
64 bytes from 192.168.0.12: icmp_seq=4 ttl=64 time=0.121 ms
^C
--- 192.168.0.12 ping statistics ---
4 packets transmitted, 4 received, 0% packet loss, time 3074ms
rtt min/avg/max/mdev = 0.107/0.119/0.129/0.015 ms


[root@hostA1 docker]# ping 8.8.8.8
PING 8.8.8.8 (8.8.8.8) 56(84) bytes of data.
64 bytes from 8.8.8.8: icmp_seq=1 ttl=55 time=16.7 ms
64 bytes from 8.8.8.8: icmp_seq=2 ttl=55 time=19.2 ms
64 bytes from 8.8.8.8: icmp_seq=3 ttl=55 time=15.3 ms
^C
--- 8.8.8.8 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 5ms
rtt min/avg/max/mdev = 15.325/17.055/19.174/1.595 ms

```


 * **ip-06-forward.sh**

    Definir regles de forwarding. Usar configuració de host/router amb dues subxarxes
    xarxaA i xarxaB fetes amb dos hosts de docker cada una.
    * xarxaA no pot accedir xarxaB
    * xarxaA no pot accedir a B2.
    * host A1 no pot connectar host B1
    * xarxaA no pot accedir a port 13.
    * xarxaA no pot accedir a ports 2013 de la xarxaB
    * xarxaA permetre navegar per internet però res més a l'exterior
    * xarxaA accedir port 2013 de totes les xarxes d'internet excepte de la xarxa xarxaB
    * evitar que es falsifiqui la ip de origen: SPOOFING


```
# xarxaA no pot accedir xarxaB

[root@hostA1 docker]# ping 172.20.0.1
PING 172.20.0.1 (172.19.0.1) 56(84) bytes of data.
From 172.19.0.2 icmp_seq=1 Destination Host Unreachable
From 172.19.0.2 icmp_seq=2 Destination Host Unreachable
From 172.19.0.2 icmp_seq=3 Destination Host Unreachable
From 172.19.0.2 icmp_seq=4 Destination Host Unreachable
^C
--- 172.20.0.1 ping statistics ---
4 packets transmitted, 0 received, +4 errors, 100% packet loss, time 6139ms
pipe 4

# xarxaA no pot accedir a B2.
[root@hostA1 docker]# ping 172.20.0.3
PING 172.20.0.3 (172.20.0.3) 56(84) bytes of data.
From 172.19.0.2 icmp_seq=1 Destination Host Unreachable
From 172.19.0.2 icmp_seq=2 Destination Host Unreachable
From 172.19.0.2 icmp_seq=3 Destination Host Unreachable
^C
--- 172.20.0.3 ping statistics ---
3 packets transmitted, 0 received, +3 errors, 100% packet loss, time 4622ms
pipe 4


# host A1 no pot connectar host B1
[root@hostA1 docker]# ping 172.20.0.2
PING 172.20.0.2 (172.20.0.2) 56(84) bytes of data.
From 172.19.0.2 icmp_seq=1 Destination Host Unreachable
From 172.19.0.2 icmp_seq=2 Destination Host Unreachable
From 172.19.0.2 icmp_seq=3 Destination Host Unreachable
^C
--- 172.20.0.2 ping statistics ---
3 packets transmitted, 0 received, +4 errors, 100% packet loss, time 3459ms
pipe 4


# xarxaA no pot accedir a port 13.
[root@hostA1 docker]# telnet 192.168.0.12 13
Trying 192.168.0.12...
telnet: connect to address 192.168.0.12: Connection refused

# xarxaA no pot accedir a ports 2013 de la xarxaB
[root@hostA1 docker]# telnet 172.20.0.1 13
Trying 172.20.0.1...
telnet: connect to address 172.20.0.1: Connection refused

# xarxaA permetre navegar per internet però res més a l'exterior
[root@hostA1 docker]# ping 8.8.8.8
PING 8.8.8.8 (8.8.8.8) 56(84) bytes of data.
64 bytes from 8.8.8.8: icmp_seq=1 ttl=55 time=48.10 ms
64 bytes from 8.8.8.8: icmp_seq=2 ttl=55 time=18.6 ms
^C
--- 8.8.8.8 ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 2ms
pipe 4



# xarxaA accedir port 2013 de totes les xarxes d'internet excepte de la xarxa xarxaB


# evitar que es falsifiqui la ip de origen: SPOOFING

```

 * **ip-07-ports.sh**
    
    Refinir regles de port/host forwarding.
    * ports del router/firewall que porten a hosts de la lan
    * port forwarding també en funció de la ip origen



 * **ip-08-dmz.sh**

    Configurar un host/router amb dues xarxes privades locals xarxaA i xarxaB i una
    tercera xarxa DMZ amb servidors. Implementar-ho amb containers i xarxes docker.

   Implementeu el següent firewall:
    * (1) de la xarxaA només es pot accedir del router/fireall als serveis: ssh i  daytime(13)
    * (2) de la xarxaA només es pot accedir a l'exterior als serveis web,  ssh  i daytime(2013)
    * (3) de la xarxaA només es pot accedir dels serveis que ofereix la DMZ al servei web
    * (4) redirigir els ports perquè des de l'exterior es tingui accés a: 3001->hostA1:80, 
      3002->hostA2:2013, 3003->hostB1:2080,3004->hostB2:3013
    * (5) s'habiliten els ports 4001 en endavant per accedir per ssh als ports ssh de: 
      hostA1(4001), hostA2(4002), hostB1(4003), hostB2(4004).
    * (6) s'habilita el port 4000 per accedir al port ssh del router/firewal si la ip origen és 
      del host i26.
    * (7) els hosts de la xarxaB tenen accés a tot arreu excepte a la xarxaA.


```
docker network create netA netB netZ
docker run --rm --name hostA1 -h hostA1 --net netA --privileged -d edtasixm11/net18:nethost
docker run --rm --name hostA2 -h hostA2 --net netA --privileged -d edtasixm11/net18:nethost
docker run --rm --name hostB1 -h hostB1 --net netB --privileged -d edtasixm11/net18:nethost
docker run --rm --name hostB2 -h hostB2 --net netB --privileged -d edtasixm11/net18:nethost
docker run --rm --name dmz1 -h dmz1 --net netDMZ --privileged -d edtasixm11/net18:nethost
docker run --rm --name dmz2 -h dmz2 --net netDMZ --privileged -d edtasixm06/ldapserver:18group
docker run --rm --name dmz3 -h dmz3 --net netDMZ --privileged -d edtasixm11/k18:kserver
docker run --rm --name dmz4 -h dmz4 --net netDMZ --privileged -d edtasixm06/samba:18detach
docker run --rm --name dmz5 -h dmz5 --net netDMZ --privileged -d edtasixm11/tls18:ldaps
```

 * **ip-09-dmz2.sh**

    Configurar un host/router amb dues xarxes privades locals xarxaA i xarxaB i una
    tercera xarxa DMZ amb servidors: *nethost*, *ldap*, *kerberos*, *samba*.
    Implementar-ho amb containers i xarxes docker.

    Exercicis a implementar:
    * (1) des d'un host exterior accedir al servei ldap de la DMZ. Ports 389, 636.
    * (2) des d'un host exterior, engegar un container kclient i obtenir un tiket
      kerberos del servidor de la DMZ. Ports: 88, 543, 749.
    * (3) des d'un host exterior muntar un recurs samba del servidor de la DMZ.
  
```
ldapsearch -x -LLL  -h profen2i -b 'dc=edt,dc=org' dn
ldapsearch -x -LLL  -ZZ -h profen2i -b 'dc=edt,dc=org' dn 
    #(falta configurar certificat CA en el client)
ldapsearch -x -LLL  -H  ldaps://profen2i -b 'dc=edt,dc=org' dn  
    #(falta configurar certificat CA en el client

docker run --rm -it edtasixm11/k18:khost
kinit anna

smbclient //profen2i/public
```

 * **ip-10-drop.sh**

    Configurar un host amb un firewall amb política drop per defecte
    input i output. Configurar el propi host d'alumne, no actua com a router.

    A tenir en compte en el DROP:
    * dns 53
    * dhclient (68)
    * ssh (22)
    * rpc 111, 507
    * chronyd 123, 371
    * cups 631
    * xinetd 3411
    * postgresql 5432
    * x11forwarding 6010, 6011
    * avahi 368
    * alpes 462
    * tcpnethaspsrv 475
    * rxe 761


