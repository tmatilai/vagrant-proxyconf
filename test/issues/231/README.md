Tests
-----

* Linked to github issue #231
* If you are testing the current release of this plugin via bundler

```
bundle exec vagrant up
```


## To run all acceptance tests

```
bundle exec rake spec
```

## To get a list of availabe Rake tasks

```
bundle exec rake -T
```

* Example output

```
rake spec:_default     # Run serverspec tests to default
rake spec:docker_host  # Run serverspec tests to docker_host
```

## Expect

### Box `default``

  - The box `default` is a docker container that will be a reverse
    proxy. It should provision itself and work without errors.

  - You can check that the proxy is working by
    `tail -f /var/log/tinyproxy/tinyproxy.log` inside the container

  - **NOTE**: You'll need to use `docker exec <hash> -it bash` to get into the container


### Box `docker-host`

  - Vagrant should automatically install docker-ce.
  - The box should come up and provision itself with the proxy settings
    configured in your Vagrantfile.

  - **NOTE**: You can use `ssh` to connect to this container.
