#!/bin/bash
# # DIR="/usr/local/nagios/etc/new"
# # if [ "$(ls -A $DIR)" ]; then
        # # HOST=$(sed '1!d;' $DIR/nagconf)
        # # IP=$(sed '2!d' $DIR/nagconf)
        # # sudo rm $DIR/nagconf
        # # sudo cp /usr/local/nagios/etc/servers/host.template /usr/local/nagios/etc/servers/$HOST.cfg
        # # sudo sed -i 's/minion/'$HOST'/g' /usr/local/nagios/etc/servers/$HOST.cfg
        # # sudo sed -i 's/ipaddress/'$IP'/g' /usr/local/nagios/etc/servers/$HOST.cfg
        # # sudo service nagios restart
# # else
        # # exit
# # fi


# while getopts hname:ipaddr option
# do
  # case "${option}"
  # in
  # hname) HOST=${OPTARG};;
  # ipaddr)    IP=${OPTARG};;
  # esac
# done

HOST=$1
IP=$2

cp /usr/local/nagios/etc/servers/host.template /usr/local/nagios/etc/servers/$HOST.cfg
sed -i 's|minion|'$HOST'|g' /usr/local/nagios/etc/servers/$HOST.cfg
sed -i 's|ipaddress|'$IP'|g' /usr/local/nagios/etc/servers/$HOST.cfg
service nagios restart