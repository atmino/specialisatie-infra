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
sed -i -e 's/#master: salt/master: salty-master' /etc/salt/minion

#salt-minion needs to be restarted to see the changes in config
systemctl restart salt-minion
