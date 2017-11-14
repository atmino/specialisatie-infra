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