#!yaml
#install docker-ce
#/srv/salt/docker/init.sls

docker-repo:
  pkgrepo.managed:
    - humanname: Docker-ce
    - key_url: https://download.docker.com/linux/ubuntu/gpg
    - architectures: amd64
    - name: deb https://download.docker.com/linux/ubuntu/ xenial stable  

docker:
  pkg.installed:
    - name: docker-ce
  service.running:
    - name: docker
    - require:
      - pkg: docker-ce
      
download-docker-compose:
  cmd.run:
    - name: sudo curl -L https://github.com/docker/compose/releases/download/1.17.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
    - creates: /usr/local/bin/docker-compose
    
install-docker-compose:
  cmd.run:
    - name: sudo chmod +x /usr/local/bin/docker-compose

manage-docker-compose-yaml:
  file.managed:
    - name: /docker-compose.yaml
    - source: salt://docker/docker-compose.yaml
    
startup-swarm:
  cmd.run:
    - name: sudo docker swarm join --token SWMTKN-1-1tfcidr4dcrznab3lk5mxrdha1wwd7caloyv4k75a4sasrq3rn-9upanwf9kzss7vbhstcztwctp 10.5.1.60:2377
    
start-docker-containers:
  cmd.run:
    - name: sudo docker-compose up -d
    
