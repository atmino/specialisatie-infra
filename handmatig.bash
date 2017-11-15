#!/bin/bash
#Dingen om handmatig te doen na aanmaken instance

#Toevoegen aan nagios:
sudo sh add-to-nagios.sh hname ip
#salt-key accepteren
sudo salt-key -d minion* -y
#salt state.apply
sudo salt 'minion*' state.apply

#Dingen om te doen na het verwijderen van een instance
#salt-key verwijderen (alle met hostname beginnend met minion)
sudo salt-key -d minion* -y
#verwijderen uit docker swarm
docker swarm rm [ID]
#verwijderen uit nagios
sudo rm /usr/local/nagios/etc/servers/((minion nr).cfg
#nagios herstarten
sudo systemctl restart nagios.service