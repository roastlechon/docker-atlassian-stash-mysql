FROM phusion/baseimage:0.9.12

ENV HOME /root

RUN /etc/my_init.d/00_regen_ssh_host_keys.sh

CMD ["/sbin/my_init"]

# Some Environment Variables
ENV DEBIAN_FRONTEND noninteractive

ENV STASH_VERSION 3.7.1

ENV DOWNLOAD_URL https://downloads.atlassian.com/software/stash/downloads/atlassian-stash-3.7.1.tar.gz

# https://confluence.atlassian.com/display/STASH/Stash+home+directory
ENV STASH_HOME /var/atlassian/application-data/stash

# Install Atlassian Stash to the following location
ENV STASH_INSTALL_DIR /opt/atlassian/stash

RUN apt-get update
RUN apt-get install -y wget git default-jre

RUN sudo /bin/sh -c 'echo JAVA_HOME=$(readlink -f /usr/bin/java | sed "s:/jre/bin/java::") >> /etc/environment'
RUN sudo /bin/sh -c 'echo STASH_HOME=${STASH_HOME} >> /etc/environment'
RUN source /etc/environment

RUN mkdir -p ${STASH_INSTALL_DIR}
RUN mkdir -p ${STASH_HOME}

RUN wget -P /tmp ${DOWNLOAD_URL} && cd /tmp
RUN tar zxf atlassian-stash-3.7.1.tar.gz
RUN mv /tmp/atlassian-stash-3.7.1/* ${STASH_INSTALL_DIR}

RUN wget -P /tmp http://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-5.1.34.tar.gz && cd /tmp
RUN tar zxf mysql-connector-java-5.1.34.tar.gz
RUN mv mysql-connector-java-5.1.34/mysql-connector-java-5.1.34-bin.jar ${STASH_INSTALL_DIR}/lib/

RUN mkdir /etc/service/stash
ADD runit/stash.sh /etc/service/stash/run
RUN chmod +x /etc/service/stash/run

EXPOSE 7990
EXPOSE 7999

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*