FROM phusion/baseimage:0.9.12

ENV HOME /root

RUN /etc/my_init.d/00_regen_ssh_host_keys.sh

CMD ["/sbin/my_init"]

# Some Environment Variables
ENV DEBIAN_FRONTEND noninteractive

ENV DOWNLOAD_URL https://downloads.atlassian.com/software/stash/downloads/atlassian-stash-3.7.1.tar.gz

# https://confluence.atlassian.com/display/STASH/Stash+home+directory
ENV STASH_HOME /var/atlassian/application-data/stash

# Install Atlassian Stash to the following location
ENV STASH_INSTALL_DIR /opt/atlassian/stash

RUN apt-get update

RUN apt-get install -y wget git default-jre

RUN sudo /bin/sh -c 'echo JAVA_HOME=$(readlink -f /usr/bin/java | sed "s:/jre/bin/java::") >> /etc/environment'
RUN sudo /bin/sh -c 'echo STASH_HOME=${STASH_HOME} >> /etc/environment'

RUN mkdir -p /opt/atlassian/
RUN mkdir -p ${STASH_HOME}

RUN wget -P /tmp ${DOWNLOAD_URL}
RUN tar zxf /tmp/atlassian-stash-3.7.1.tar.gz -C /tmp
RUN mv /tmp/atlassian-stash-3.7.1 /tmp/stash 
RUN mv /tmp/stash /opt/atlassian/

RUN wget -P /tmp http://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-5.1.34.tar.gz
RUN tar zxf /tmp/mysql-connector-java-5.1.34.tar.gz -C /tmp
RUN mv /tmp/mysql-connector-java-5.1.34/mysql-connector-java-5.1.34-bin.jar ${STASH_INSTALL_DIR}/lib/

RUN mkdir /etc/service/stash
ADD runit/stash.sh /etc/service/stash/run
RUN chmod +x /etc/service/stash/run

EXPOSE 7990
EXPOSE 7999

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
