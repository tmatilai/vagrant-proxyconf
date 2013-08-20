## Testing the plugin

1. Copy _Vagrantfile_ from the template:

        cp Vagrantfile.example Vagrantfile

2. Spin up the machine:

        bundle exec vagrant up

3. Test, hack, edit _Vagrantfile_ and test again:

        VAGRANT_LOG=debug bundle exec vagrant reload
        VAGRANT_APT_HTTP_PROXY="foo:8080" bundle exec vagrant provision
        # ...

4. Goto 3.
