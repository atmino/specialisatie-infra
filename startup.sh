#!bin/sh
# To be executed to make a nice salt-minion
# We don't need sudo (right?)

# Setting the right timezone
timedatectl set-timezone 'Europe/Amsterdam'

#Getting the saltstack public key to add to apt
wget -O - https://repo.saltstack.com/apt/ubuntu/16.04/amd64/latest/SALTSTACK-GPG-KEY.pub | sudo apt-key add -

#Copying the repo to a source list
sh -c 'echo "deb http://repo.saltstack.com/apt/ubuntu/16.04/amd64/latest xenial main" >> /etc/apt/sources.list.d/saltstack.list'

#updating apt so it includes the new source
apt-get update -y

#installing the minion
apt-get install salt-minion -y

#giving the minion the master's IP address
sed -i -e 's/#master: salt/master: 10.5.1.60/' /etc/salt/minion

#salt-minion needs to be restarted to see the changes in config
systemctl restart salt-minion

# # #Next, we want docker on the salt minion
# # #We want to uninstall any previous versions, if present.
# # #Just a precaution.
# # apt-get remove docker docker-engine docker.io

# # #Add the docker key to apt 
# # curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

# # #To ease installation/upgrading we add the docker repositories for the stable release
# # sudo add-apt-repository \
   # # "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   # # $(lsb_release -cs) \
   # # stable"
   
# # #update apt so it includes the new sources (TODO: merge all update statements)
# # apt-get update -y

# # #install the latest Docker (community edition) version
# # apt-get install docker-ce -y

# # #next we add a docker user and group to avoid it running as root
# # useradd docker-user
# # groupadd docker
# # usermod -aG docker docker-user

# # #note that for changes to take effect on user privileges the VM has to be restarted.
# # #The machine will be restarted AFTER all the installations in this script have run.

# # #enable docker to start on boot
# # systemctl enable docker

# # #WAARSCHIJNLIJK NIET NODIG MET KANT EN KLARE CONTAINERS
# # #next we want to install docker-compose for easy breezy administration of containers
# # #lines from https://github.com/docker/compose/releases
# # #curl -L https://github.com/docker/compose/releases/download/1.17.1/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
# # #chmod +x /usr/local/bin/docker-compose

#adding the minion to the monitor
apt-get install nagios-nrpe-server nagios-plugins -y

#edit the config to point to the monitor server
sed -i -e 's/#server_address=127.0.0.1/server_address=10.5.1.60/' /etc/nagios/nrpe.cfg

#restart the service to find changes
service nagios-nrpe-server restart

#adding the logserver to rsyslog.conf
echo "*.*       @@10.5.1.60:514" >> /etc/rsyslog.conf

#restarting the logging services
systemctl restart rsyslog

