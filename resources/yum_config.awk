#!/usr/bin/env gawk
#
# Adds or modifies proxy configuration for Yum
#
# Usage:
#   yum_config.awk -v proxy=http://proxy:1234 -v user=foo -v pass=bar /etc/yum.comf
#
# License: MIT
# Copyright (c) 2013 Teemu Matilainen <teemu.matilainen@iki.fi>
#

BEGIN {
  FS = OFS = "="

  # [main] section:
  #   0: not seen yet
  #   1: inside of it
  #   2: already on another section
  main = 0

  conf["proxy"] = (proxy ? proxy : "_none_")
  conf["proxy_username"] = (proxy ? user : "")
  conf["proxy_password"] = (proxy ? pass : "")
}

# Section headers
/^\[.*\]$/ {
  if ($0 == "[main]") {
    # entering [main] section
    main = 1
  } else if (main == 1) {
    # [main] section ended
    print_proxy_conf()
    main = 2
  }
}

# Old configuration
$1 ~ /^proxy(_username|_password)?$/ {
  if (main == 1) {
    $2 = conf[$1]
    seen[$1] = 1
  }
}

# Print every line by default
{ print $0 }

# Print missing configuration if needed
END {
  if (main == 0) print "[main]"
  if (main < 2) print_proxy_conf()
}

# Prints proxy* configuration not seen yet
function print_proxy_conf() {
  print_key("proxy")
  print_key("proxy_username")
  print_key("proxy_password")
}

# Prints a proxy*=<value> line
function print_key(key) {
  if (!seen[key]) print key, conf[key]
}
