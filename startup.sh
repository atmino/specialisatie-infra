#!bin/sh
# To be executed to make a nice salt-minion

# Setting the right timezone
timedatectl set-timezone 'Europe/Amsterdam'

#updating sources
#Getting the saltstack public key to add to apt
wget -O - https://repo.saltstack.com/apt/ubuntu/16.04/amd64/latest/SALTSTACK-GPG-KEY.pub | sudo apt-key add -
#Copying the repo to a source list
sh -c 'echo "deb http://repo.saltstack.com/apt/ubuntu/16.04/amd64/latest xenial main" >> /etc/apt/sources.list.d/saltstack.list'
#updating apt so it includes the new source
apt-get update -y

#installing all the tings
#installing the minion
apt-get install salt-minion -y
#installing nagios
apt-get install nagios-nrpe-server nagios-plugins -y

#configuring all the tings
#giving the minion the master's IP address
sed -i -e 's/#master: salt/master: 10.5.1.60/' /etc/salt/minion
#edit the config to point to the monitor server
sed -i -e 's/#server_address=127.0.0.1/server_address=10.5.1.60/' /etc/nagios/nrpe.cfg
#adding the logserver to rsyslog.conf
echo "*.*       @@10.5.1.60:514" >> /etc/rsyslog.conf


#restarting all the tings
#restart the service to find changes
service nagios-nrpe-server restart
#restarting the logging services
systemctl restart rsyslog
#salt-minion needs to be restarted to see the changes in config
systemctl restart salt-minion
