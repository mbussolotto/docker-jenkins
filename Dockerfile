FROM jenkins/jenkins:latest

USER root

RUN sed -i 's/stretch/buster/g' /etc/apt/sources.list && \
  apt-get update --yes && \
  curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | bash ; \
  apt-get install --yes apt-transport-https dirmngr sudo rsync git-lfs file ansible maven less vim python \
  && apt-get autoclean --yes \
  && apt-get autoremove --yes

# Install Docker
RUN curl https://get.docker.com/ | bash

# Configure docker group and jenkins user
RUN groupadd docker ; usermod -aG docker jenkins && usermod -aG sudo jenkins && id jenkins
RUN echo "jenkins ALL=(ALL)     NOPASSWD: ALL" >> /etc/sudoers

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

USER jenkins
COPY .ssh $HOME/.ssh
RUN git lfs install

EXPOSE 8080
                            
