#!/bin/bash
#Dingen om handmatig te doen na aanmaken instance

#Toevoegen aan nagios:
sudo sh add-to-nagios.sh hname ip
#salt-key accepteren
sudo salt-key -A -y
#salt state.apply
sudo salt '*' state.apply

#Dingen om te doen na het verwijderen van een instance
#salt-key verwijderen
sudo salt-key -d minion* -y
#verwijderen uit docker swarm
docker swarm rm [ID]
