FROM centos:7

ENV CI_USERNAME vagrant
ENV CI_PASSWORD vagrant
ENV CI_HOMEDIR  /home/vagrant
ENV CI_SHELL    /bin/bash

EXPOSE 8888

RUN yum clean all && \
    yum makecache fast && \
    yum -y install epel-release && \
    yum clean expire-cache && \
    yum -y install \
      curl \
      initscripts \
      openssh-clients \
      openssh-server \
      sudo \
      tinyproxy

RUN /usr/sbin/sshd-keygen && \
    mkdir -p /var/run/sshd && \
    rm -f /usr/lib/tmpfiles.d/systemd-nologin.conf

RUN if ! getent passwd $CI_USERNAME; then \
      useradd -m -d ${CI_HOMEDIR} -s ${CI_SHELL} $CI_USERNAME; \
    fi && \
    echo "${CI_USERNAME}:${CI_PASSWORD}" | chpasswd && \
    echo "${CI_USERNAME} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    mkdir -p /etc/sudoers.d && \
    echo "${CI_USERNAME} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/${CI_USERNAME} && \
    chmod 0440 /etc/sudoers.d/${CI_USERNAME} && \
    mkdir -p ${CI_HOMEDIR}/.ssh && \
    chown -R ${CI_USERNAME}:${CI_USERNAME} ${CI_HOMEDIR}/.ssh && \
    chmod 0700 ${CI_HOMEDIR}/.ssh && \
    curl -L https://raw.githubusercontent.com/hashicorp/vagrant/master/keys/vagrant.pub > ${CI_HOMEDIR}/.ssh/vagrant.pub && \
    touch ${CI_HOMEDIR}/.ssh/authorized_keys && \
    grep -q "$(cat ${CI_HOMEDIR}/.ssh/vagrant.pub | awk '{print $2}')" ${CI_HOMEDIR}/.ssh/authorized_keys || cat ${CI_HOMEDIR}/.ssh/vagrant.pub >> ${CI_HOMEDIR}/.ssh/authorized_keys && \
    chown ${CI_USERNAME}:${CI_USERNAME} ${CI_HOMEDIR}/.ssh/authorized_keys && \
    chmod 0600 ${CI_HOMEDIR}/.ssh/authorized_keys

COPY tinyproxy.conf /etc/tinyproxy/tinyproxy.conf
COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD [ "start" ]
