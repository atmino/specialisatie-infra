#!bin/sh
#Startup script voor master

#De juiste tijdzone instellen
timedatectl set-timezone 'Europe/Amsterdam'

#Installeren van salt-master. 
#https://repo.saltstack.com/#ubuntu
#Toevoegen saltstack public key aan apt
wget -O - https://repo.saltstack.com/apt/ubuntu/16.04/amd64/latest/SALTSTACK-GPG-KEY.pub | sudo apt-key add -

#Kopieer repo naar apt source list
sh -c 'echo "deb http://repo.saltstack.com/apt/ubuntu/16.04/amd64/latest xenial main" >> /etc/apt/sources.list.d/saltstack.list'

#apt update zodat de sources gezien worden
apt-get update -y

#salt-master installeren
apt-get install salt-master -y


#Instellen van de log service
#Pakketjes doorlaten
ufw allow 514
ufw reload

#uncomment the tcp en udp modules in rsyslog.conf
sed -i -e 's/#module(load="imudp")/module(load="imudp")/' \
       -e 's/#input(type="imudp" port="514")/input(type="imudp" port="514")/' \
	   -e 's/#module(load="imtcp")/module(load="imtcp")/' \
       -e 's/#input(type="imtcp" port="514")/input(type="imtcp" port="514")/'	\   
		   /etc/rsyslog.conf
		   
#Herstarten service	   
systemctl restart rsyslog.service


#setup monitor service
#van https://support.nagios.com/kb/article/nagios-core-installing-nagios-core-from-source.html#Ubuntu
#Nagios CORE
#installeren van prerequisites
apt-get install -y autoconf gcc libc6 make wget unzip apache2 php libapache2-mod-php7.0 libgd2-xpm-dev

#downloaden van de source naar /tmp
cd /tmp
wget -O nagioscore.tar.gz https://github.com/NagiosEnterprises/nagioscore/archive/nagios-4.3.4.tar.gz
tar xzf nagioscore.tar.gz

#source compileren, we gebruiken een apache2 server voor de webinterface
cd /tmp/nagioscore-nagios-4.3.4/
./configure --with-httpd-conf=/etc/apache2/sites-enabled
make all

#toevoegen van nagios user, en aan groep nagios en www-data
useradd nagios
usermod -aG nagios www-data

make install
make install-init
update-rc.d nagios defaults
make install-commandmode
make install-config

#de configuratie voor apache2
make install-webconf
a2enmod rewrite
a2enmod cgi

#laat Apache door de firewall
ufw allow Apache
ufw reload

#nagios user aanmaken in apache (s3 privilege)
htpasswd -c -b /usr/local/nagios/etc/htpasswd.users nagiosadmin porkI9SwSmdQHv9AQmxD

systemctl restart apache2.services
systemctl start nagios.service


#installeer nagios plugins
#prereqs
apt-get install -y autoconf gcc libc6 libmcrypt-dev make libssl-dev wget bc gawk dc build-essential snmp libnet-snmp-perl gettext

#download source naar tmp, unpack
cd /tmp
wget --no-check-certificate -O nagios-plugins.tar.gz https://github.com/nagios-plugins/nagios-plugins/archive/release-2.2.1.tar.gz
tar zxf nagios-plugins.tar.gz

#navigeer naar folder, configureer en installeer
cd /tmp/nagios-plugins-release-2.2.1/
./tools/setup
./configure
make
make install

#configureer waar de config vandaan wordt gehaald
sed -i -e 's|#cfg_dir=/usr/local/nagios/etc/nagios.cfg|cfg_dir=/usr/local/nagios/etc/nagios.cfg|' /usr/local/nagios/etc/nagios.cfg

#herstart de service
systemctl restart nagios.service

#Next, we want docker on the salt master
#We want to uninstall any previous versions, if present.
#Just a precaution.
apt-get remove docker docker-engine docker.io

#Add the docker key to apt 
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

#To ease installation/upgrading we add the docker repositories for the stable release
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
   
#update apt so it includes the new sources (TODO: merge all update statements)
apt-get update -y

#install the latest Docker (community edition) version
apt-get install docker-ce -y

#next we add a docker user and group to avoid it running as root
useradd docker-user
groupadd docker
usermod -aG docker docker-user

#note that for changes to take effect on user privileges the VM has to be restarted.
#The machine will be restarted AFTER all the installations in this script have run.

#enable docker to start on boot
systemctl enable docker

#WAARSCHIJNLIJK NIET NODIG MET KANT EN KLARE CONTAINERS
#next we want to install docker-compose for easy breezy administration of containers
#lines from https://github.com/docker/compose/releases
curl -L https://github.com/docker/compose/releases/download/1.17.1/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

#setup the docker swarm
docker swarm init

#allow the docker swarm connections
ufw allow 2377
ufw reload

#build the docker swarm secrets
# echo "supersecretpassword" | docker secret create MYSQL_ROOT_PASSWORD -
# echo "wordpress" | docker secret create MYSQL_DATABASE -
# echo "wordpress" | docker secret create MYSQL_USER -
# echo "puddingbroodje" | docker secret create MYSQL_PASSWORD -
# echo "db:3306" | docker secret create WORDPRESS_DB_HOST -
# echo "wordpress" | docker secret create WORDPRESS_DB_USER -
# echo "puddingbroodje" | docker secret create WORDPRESS_DB_PASSWORD -

#create the network for the stack
docker network create wordpress_network -d overlay --subnet=10.5.1.0/24

#deploy to stack
docker stack deploy --compose-file=/srv/salt/docker/docker-compose.yaml wordpress

#create user specifically for copying nagios conf info
useradd nagios_conf
passwd -d nagios_conf
mkdir /usr/local/nagios/etc/new
chown -R nagios_conf: /usr/local/nagios/etc/new
chmod -R 644 /usr/local/nagios/etc/new