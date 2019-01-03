#!/bin/bash

INSTALL_APT_PKGS=
APT_PKGS="tinyproxy
apt-transport-https
ca-certificates
curl
git
gnupg2
php-pear
npm
software-properties-common
subversion
yum
"

is_apt_pkg_installed() {
  dpkg -l ${1} >>/dev/null 2>&1
}

for PKG in $APT_PKGS
do
  is_apt_pkg_installed ${PKG}
  if [ $? -ne 0 ]; then
    [ -z "${INSTALL_APT_PKGS}" ] && INSTALL_APT_PKGS="${PKG}" || INSTALL_APT_PKGS="${INSTALL_APT_PKGS} ${PKG}"
  fi
done

if [ -n "${INSTALL_APT_PKGS}" ]; then
  apt-get update
  apt-get install -y ${INSTALL_APT_PKGS}
fi

command -v docker >>/dev/null
if [ $? -ne 0 ]; then
  curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -

  add-apt-repository \
     "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
     $(lsb_release -cs) \
     stable"

  apt-get update
  apt-get -y install docker-ce
fi

if [ -f /tmp/tinyproxy.conf ]; then
  cp /tmp/tinyproxy.conf /etc/tinyproxy/tinyproxy.conf
  chown root:root /etc/tinyproxy/tinyproxy.conf
  chmod 0644 /etc/tinyproxy/tinyproxy.conf
  systemctl restart tinyproxy
fi

[ "$(systemctl is-enabled tinyproxy)" == "enabled" ] || systemctl enable tinyproxy
[ "$(systemctl is-active tinyproxy)" == "active" ] || systemctl start tinyproxy
