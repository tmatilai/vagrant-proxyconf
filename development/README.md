## Testing the plugin

1. Copy _Vagrantfile_ from the template:

        cp Vagrantfile.example Vagrantfile

2. Spin up the machine:

        bundle exec vagrant up

3. Test, hack, edit _Vagrantfile_ and test again:

        VAGRANT_LOG=debug bundle exec vagrant reload
        APT_PROXY_HTTP="foo:8080" bundle exec vagrant reload
        # ...

4. Goto 3.
