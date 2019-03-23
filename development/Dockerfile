# https://gist.github.com/codylane/6ebee3595a02f57d35c325db4e102c55
FROM centos:7

EXPOSE 22

RUN yum clean all && \
    yum makecache fast && \
    yum -y install \
      curl \
      device-mapper-persistent-data \
      git \
      initscripts \
      lvm2 \
      openssh-clients \ 
      openssh-server \ 
      rsync \ 
      sudo \
      wget \
      yum-utils \ 
      xfsprogs && \
    yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo && \
    yum clean expire-cache && \
    yum install -y docker-ce && \
    /usr/sbin/sshd-keygen && \
    getent passwd vagrant || useradd -m -d /home/vagrant -s /bin/bash vagrant && \
    echo "vagrant:vagrant" | chpasswd && \
    mkdir -p /etc/sudoers.d && \
    echo 'Defaults:vagrant !requiretty' > /etc/sudoers.d/vagrant && \
    echo 'vagrant ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers.d/vagrant && \
    chmod 0440 /etc/sudoers.d/vagrant && \
    visudo -cf /etc/sudoers.d/vagrant && \
    mkdir -p /var/run/sshd && \
    mkdir -p /home/vagrant/.ssh && \
    touch /home/vagrant/.ssh/authorized_keys

VOLUME [ "/sys/fs/cgroup" ]

RUN grep -q 'OHlnVYCzRdK8jlqm8tehUc9c9WhQ==' /home/vagrant/.ssh/authorized_keys || echo "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ==" >> /home/vagrant/.ssh/authorized_keys && \
    chmod 0600 /home/vagrant/.ssh/authorized_keys && \
    chown vagrant:vagrant /home/vagrant/.ssh/authorized_keys

# -e write logs to stderr
# -D run in foreground
# CMD ["/usr/sbin/sshd", "-e", "-D"]
CMD ["/usr/sbin/init"]
