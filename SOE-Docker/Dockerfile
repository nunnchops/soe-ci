# soe-cii openshift-jenkins-mock-httpd
#
# This image provides a Jenkins-mock-cii server, primarily intended for integration with
# OpenShift v3.
# 
# based on James Rawlings Fabric8 Jenkins image and 
# bparees jenins-1-centos: https://github.com/openshift/jenkins-1-centos
# Thanks also to Laurent Dombs excellent fork of the SOE-CI master branch 
# that includes the original SOE Jenkins installer scripts 
#
# rnunn@redhat.com
#
# This is just a start it would be nicer and more Docker compliant 
# to make use of a linked httpd Docker image
# but this will suffice for illustration porpoises. 

#
# The aim is to provide the SOE-CI Jenkins orchestration platform 
# pre-configured in an Openshift ready Docker container. This needs 
# refinement though (as per previous note) and testing   
#

#FROM openshift/origin
#rebasing to James Rawlings Fabric8 Jenkins
FROM rawlingsj/fabric8-jenkins

USER root

#### JENKINS AND REPO
ENV HOME /var/jenkins_home
ENV JENKINS_HOME /var/jenkins_home

RUN wget -O /etc/yum.repos.d/jenkins.repo http://pkg.jenkins-ci.org/redhat/jenkins.repo && \
  rpm --import http://pkg.jenkins-ci.org/redhat/jenkins-ci.org.key && \
  yum install -y zip unzip java-1.7.0-openjdk docker jenkins git mock httpd mercurial rpm-build patch gcc-c++ java && yum clean all 

#Automagically grab the latest versions of the required plugins
RUN  curl -L -o /$JENKINS_HOME/plugins/git.hpi http://updates.jenkins-ci.org/latest/git.hpi
RUN  curl -L -o /$JENKINS_HOME/plugins/git-client.hpi http://updates.jenkins-ci.org/latest/git-client.hpi
RUN  curl -L -o /$JENKINS_HOME/plugins/scm-api.hpi http://updates.jenkins-ci.org/latest/scm-api.hpi
RUN  curl -L -o /$JENKINS_HOME/plugins/ssh-credentials.hpi http://updates.jenkins-ci.org/latest/ssh-credentials.hpi
RUN  curl -L -o /$JENKINS_HOME/plugins/credentials.hpi http://updates.jenkins-ci.org/latest/credentials.hpi

RUN ls /$JENKINS_HOME/plugins/*.hpi 

#Obtain the SOE-CI Jenkins config.xml from Github project repo
RUN mkdir -p /$JENKINS_HOME/jobs/SOE/ && curl -Lk -o /$JENKINS_HOME/jobs/SOE/config.xml https://raw.githubusercontent.com/RedHatEMEA/soe-ci/master/config.xml 

RUN  usermod -m -d "$JENKINS_HOME" jenkins && \
  chown -R jenkins "$JENKINS_HOME"

#thanks to Laurent Domb for following steps from his installer branch
#set default mock file 
RUN cd /etc/mock/
RUN unlink /etc/mock/default.cfg
RUN curl -Lk -o /etc/mock/rhel-7-x86_64.cfg  https://raw.githubusercontent.com/RedHatEMEA/soe-ci/master/rhel-7-x86_64.cfg
RUN ln -s /etc/mock/rhel-7-x86_64.cfg /etc/mock/default.cfg 

#add user kenkins to mock group so it can build rpms
RUN usermod -a -G mock jenkins

#createsoe-repo for rpms and puppet this needs to be an external mounted volume or link 
RUN mkdir -p /var/www/html/pub/soe-repo
RUN mkdir -p /var/www/html/pub/soe-puppet
RUN chown -R jenkins.jenkins /var/www/html/pub/soe-repo
RUN chown -R jenkins.jenkins /var/www/html/pub/soe-puppet

#This is better and more dynamically handled as a Jenkins user credential using the ssh-credentials plugin above
##su - jenkins -s /bin/bash -c ssh-keygen 

#Jenknis-apache.sh needs testing currently dont have the power on this test machine :) 
COPY jenkins-apache.sh /usr/local/bin/jenkins-apache.sh

# for main web interface:
EXPOSE 8080

# will be used by attached slave agents:
EXPOSE 50000

USER jenkins

# Apache
EXPOSE 80

# TODO
#create sensible run scripts and expose endpoints for the webserver ? and mock apis? 
# git clone the soe-cii artefacts and install the jenkins cii config xml file. 

ENTRYPOINT ["/usr/local/bin/jenkins-apache.sh"]
