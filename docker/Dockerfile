FROM fedora:27
LABEL author="@isx43577298 ASIX M11-SAD"
LABEL description="practica4"
RUN dnf -y install xinetd iproute iputils nmap uw-imap procps net-tools passwd httpd vsftpd openssh-server tftp-server telnet 
RUN mkdir /opt/docker
ADD * /opt/docker/
RUN chmod +x /opt/docker/startup.sh /opt/docker/install.sh
WORKDIR /opt/docker
CMD /opt/docker/startup.sh

