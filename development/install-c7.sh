#!/bin/bash

INSTALL_YUM_PKGS=
YUM_PKGS="curl
git
gnupg2
php-pear
npm
subversion
"

is_yum_pkg_installed() {
  rpm -q ${1} >>/dev/null 2>&1
}

is_yum_pkg_installed "epel-release" || yum -y install epel-release

for PKG in $YUM_PKGS
do
  is_yum_pkg_installed ${PKG}
  if [ $? -ne 0 ]; then
    [ -z "${INSTALL_YUM_PKGS}" ] && INSTALL_YUM_PKGS="${PKG}" || INSTALL_YUM_PKGS="${INSTALL_YUM_PKGS} ${PKG}"
  fi
done

if [ -n "${INSTALL_YUM_PKGS}" ]; then
  yum clean expire-cache
  yum install -y ${INSTALL_YUM_PKGS}
fi

SESTATUS=$(command -v sestatus)
[ -n "${SESTATUS}" ] && setenforce 0 || true

command -v docker >>/dev/null
if [ $? -ne 0 ]; then
  cd /etc/yum.repos.d/
  curl -LO https://download.docker.com/linux/centos/docker-ce.repo
  cd - >>/dev/null

  yum clean expire-cache
  yum -y install docker-ce

fi

[ "$(systemctl is-enabled docker)" == "enabled" ] || systemctl enable docker
[ "$(systemctl is-active docker)" == "active" ] || systemctl start docker
