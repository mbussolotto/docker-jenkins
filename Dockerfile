FROM jenkins/jenkins:lts

USER root

RUN apt-get update; \
  # Connect git-lfs repo
  curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | bash; \
  # Install various packages
  apt-get install -y apt-transport-https dirmngr sudo rsync git-lfs \
  && apt-get autoclean \
  && apt-get autoremove

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

# Install Habitus (http://www.habitus.io/)
RUN HABITUS_VERSION=1.0.4; \
  curl -Ls -o /usr/local/bin/habitus https://github.com/cloud66-oss/habitus/releases/download/$HABITUS_VERSION/habitus_linux_amd64; \
  chmod a+x /usr/local/bin/habitus

# Configure docker group and jenkins user
RUN usermod -aG docker jenkins && usermod -aG sudo jenkins && id jenkins
RUN echo "jenkins ALL=(ALL)	NOPASSWD: ALL" >> /etc/sudoers

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

USER jenkins
RUN git lfs install

EXPOSE 8080
