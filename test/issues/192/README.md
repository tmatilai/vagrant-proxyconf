Tests
-----

If you are testing the current release of this plugin via bundler

```
bundle exec vagrant up default
```

## Expect


### Box `default`

  - The box `default` is a docker container that will be a reverse
    proxy. It should provision itself and work without errors.

  - You can check that the proxy is working by
    `tail -f /var/log/tinyproxy/tinyproxy.log` inside the container

  - **NOTE**: You'll need to use `docker exec <hash> -it bash` to get into the container


### Box `docker-host`

  - Vagrant should automatically instally docker-ce.
  - The box should come up and provision itself with the proxy settings
    configured in your Vagrantfile.
  - **NOTE**: You can use `ssh` to connect to this container.
