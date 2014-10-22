FROM ubuntu:14.04
 
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update

#SSHD
RUN apt-get install -y openssh-server && \
    mkdir -p /var/run/sshd && \
    echo 'root:root' | chpasswd
RUN sed -i "s/session.*required.*pam_loginuid.so/#session    required     pam_loginuid.so/" /etc/pam.d/sshd
RUN sed -i "s/PermitRootLogin without-password/#PermitRootLogin without-password/" /etc/ssh/sshd_config

#Utilities
RUN apt-get install -y vim less net-tools inetutils-ping curl git nmap socat dnsutils netcat tree htop unzip sudo software-properties-common

#MariaDB
RUN apt-get -y install mariadb-server mariadb-client
 
#XE Requirements
RUN apt-get -y install apache2 libapache2-mod-php5 php5-mysql php-apc php5-gd php5
#RUN apt-get install -y php5-geoip libgeoip-dev

#XE
RUN rm -rf /var/www/html && \
    mkdir /var/www/html
RUN cd /var/www/html && \
    wget https://github.com/xpressengine/xe-core/releases/download/1.7.7.2/xe.master.tar.gz && \
    tar xvf xe.master.tar.gz
RUN chown -R www-data:www-data /var/www/html && \
    mkdir /var/www/html/files && \
    chmod -R 707 /var/www/html/files

#Runit
RUN apt-get install -y runit 
CMD ["/usr/sbin/runsvdir-start"]

#Add runit service configs to /etc/service
ADD sv /etc/service

#Init MariaDB
RUN rm /etc/mysql/conf.d/mysqld_safe_syslog.cnf
ADD xe.ddl /xe.ddl
RUN mysqld_safe & mysqladmin --wait=5 ping && \
    mysql < /xe.ddl && \
    mysqladmin shutdown
RUN sed -i -r 's/bind-address.*$/bind-address = 0.0.0.0/' /etc/mysql/my.cnf

