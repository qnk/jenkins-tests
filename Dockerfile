No Title
###Ref this dockerfile from https://github.com/target/jenkins-docker-master/blob/master/Dockerfile
#2.1381 is version when i found this dockerfile

ARG JENKINS_VER=2.138.1
FROM jenkins/jenkins:${JENKINS_VER}

LABEL name="gdm_Jenkins_front" \
      maintainer="GDM TEAM EVERIS" \
      io.k8s.display-name="Jenkins" \
      io.k8s.description="Provide a Jenkins image to run on Red Hat OpenShift" \
      io.openshift.expose-services="9000" \
      io.openshift.tags="Jenkins" \
      build-date="01-12-2018" \
      version=$JENKINS_VERSION \
      release="1"

ARG user=jenkins
ARG group=jenkins
ARG uid=1000
ARG gid=1000
ARG port=8080
ARG JENKINS_VER
ARG RELEASE=1

ENV JENKINS_HOME /var/jenkins_home

USER root

COPY files/jenkins_wrapper.sh /usr/local/bin/jenkins_wrapper.sh

# create version files to ensure Jenkins does not prompt for setup
# allow slave to master control - https://wiki.jenkins.io/display/JENKINS/Slave+To+Master+Access+Control
# create file for plugin versioning
RUN echo -n ${JENKINS_VER} > /usr/share/jenkins/ref/jenkins.install.UpgradeWizard.state && \
echo -n ${JENKINS_VER} > /usr/share/jenkins/ref/jenkins.install.InstallUtil.lastExecVersion && \
mkdir -p /usr/share/jenkins/ref/secrets/ && echo false > /usr/share/jenkins/ref/secrets/slave-to-master-security-kill-switch && \
echo ${JENKINS_VER}-${RELEASE} > /usr/share/jenkins/ref/jenkins.docker.image.version


# Install plugins that are predefined in the base-plugins.txt file
COPY files/base-plugins.txt /usr/share/jenkins/base-plugins.txt
RUN cat /usr/share/jenkins/base-plugins.txt | xargs /usr/local/bin/install-plugins.sh

##Create Jenkins user with system accounts and owner directory JENKINS_HOME
RUN chown ${uid}:${gid} $JENKINS_HOME &&\
    #groupadd -g ${gid} ${group} &&\
    #useradd -c "Jenkins System User" -d "$JENKINS_HOME" -u ${uid} -g ${gid} -m -s /bin/bash ${user} &&\
    chgrp -R 0 $JENKINS_HOME &&\
    chmod -R g=u $JENKINS_HOME

VOLUME $JENKINS_HOME

EXPOSE $port 5000

USER ${user}

ENTRYPOINT ["/sbin/tini", "--", "/usr/local/bin/jenkins_wrapper.sh"] 
