#voor het tomatisch opzetten van de sql server hebben we het een en ander nodig.
#debconf zodat we het pillar password mee kunnen geven
#de pillar data zelf
#de configuratie files voor mysql
#voor het grootste gedeelte is deze init.sls overgenomen van: https://www.digitalocean.com/community/tutorials/saltstack-infrastructure-creating-salt-states-for-mysql-database-servers

#installeren van debconf:
debconf-utils:
    pkg.installed: []

#de waarden voor het installeren van de mysql server
mysql_setup:
    debconf.set:
      - name: mysql-server
      - data:
          'mysql-server/root_password': {'type': 'password', 'value': '{{ pillar['mysql']['root_pwd'] }}' }
          'mysql-server/root_password_again': {'type': 'password', 'value': '{{ pillar['mysql']['root_pwd'] }}' }
      - require:
        - pkg: debconf-utils

#python-mysqldb zodat salt goed met mysql kan praten
python-mysqldb:
    pkg.installed: []

#de daadwerkelijke server
mysql-server:
    pkg.installed: []


