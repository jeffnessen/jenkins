FROM jenkins/jenkins:lts

USER root

# Install Docker Engine AND sudo
RUN apt-get update && apt-get install -y \
      software-properties-common \
      apt-transport-https \
      apt-utils \
    && curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add - \
    && add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian \
      $(lsb_release -cs) stable" \
    && apt-get update && apt-get install -y docker-ce jq sudo \
    && usermod -aG docker jenkins \
    && adduser jenkins sudo \
    && curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.9.0/bin/linux/amd64/kubectl \
    && chmod a+x kubectl \
    && mv kubectl /usr/local/bin/kubectl \
    && rm -rf /var/lib/apt/lists/*

RUN echo "jenkins ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers


COPY hack.sh /usr/local/bin/hack.sh

RUN sed -i "/#! \/bin\/bash -e/r /usr/local/bin/hack.sh" /usr/local/bin/jenkins.sh

USER jenkins

# Install plugins
RUN /usr/local/bin/install-plugins.sh cloudbees-folder jackson2-api credentials structs matrix-auth git github-api

# Skip initial setup
ENV JAVA_OPTS -Djenkins.install.runSetupWizard=false

# Create admin user
ENV JENKINS_USER admin
ENV JENKINS_PASS password
COPY default-user.groovy /usr/share/jenkins/ref/init.groovy.d/
