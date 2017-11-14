#!yaml
#install docker-ce
#/srv/salt/init.sls

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