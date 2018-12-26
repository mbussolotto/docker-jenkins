FROM jenkins/jenkins:lts

USER root

# Install various packages
RUN apt-get update && apt-get install -y apt-transport-https dirmngr sudo && \
  apt-get autoclean && apt-get autoremove

# Install Docker and all versions of Docker Compose
RUN curl https://get.docker.com/ | bash
RUN TAGS=$(git ls-remote https://github.com/docker/compose | grep refs/tags | grep -oP '[0-9]+\.[0-9][0-9]+\.[0-9]+$'); \
  for COMPOSE_VERSION in $TAGS; do \
  echo "Fetching Docker Compose version ${COMPOSE_VERSION}"; \
  curl -LsS -C - https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose-${COMPOSE_VERSION}; \
  done; \
  chmod a+x /usr/local/bin/docker-compose-*; \
  echo "Symlinking most recent stable Docker Compose version"; \
  ln -s /usr/local/bin/docker-compose-${COMPOSE_VERSION} /usr/local/bin/docker-compose

# Configure docker group and jenkins user
RUN usermod -aG docker jenkins && usermod -aG sudo jenkins && id jenkins
RUN echo "jenkins ALL=(ALL)	NOPASSWD: ALL" >> /etc/sudoers

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

# Connect git-lfs repo
RUN curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | bash

# Install rsync and git-lfs
RUN apt-get update && apt-get install -y rsync git-lfs && apt-get autoclean && apt-get autoremove

USER jenkins
RUN git lfs install

EXPOSE 8080
