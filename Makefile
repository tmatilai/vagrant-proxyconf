.PHONY: clean
.PHONY: help
.PHONY: init
.PHONY: patch_bundler


all: clean init patch_bundler


clean:
	rm -f Gemfile.lock
	rm -rf .bundle/


help:
	@echo "[Commands]"
	@echo ""
	@echo "  all           -> The default which runs all tasks"
	@echo "  clean         -> Deletes Gemfile.lock and .bundle/"
	@echo "  init          -> Creates the bundle for developing the next release"
	@echo "  patch_bundler -> Attemps to patch vagrant bundler with known issues"
	@echo ""

init: clean
	bundle config set path '.bundle/gems'
	bundle install


patch_bundler:
	[ "$(VAGRANT_VERSION)" == "v2.2.5" ] && (patch -p0 --batch --backup -d "`bundle info --path vagrant`" < deps/patches/lib/vagrant/bundler.rb.patch) || true
	[ "$(VAGRANT_VERSION)" == "v2.2.6" ] && (patch -p0 --batch --backup -d "`bundle info --path vagrant`" < deps/patches/lib/vagrant/bundler.rb.patch) || true
	[ "$(VAGRANT_VERSION)" == "v2.2.7" ] && (patch -p0 --batch --backup -d "`bundle info --path vagrant`" < deps/patches/lib/vagrant/bundler.rb.patch) || true
	[ "$(VAGRANT_VERSION)" == "v2.2.8" ] && (egrep -q 'cap/redhat' `bundle info --path vagrant`/plugins/provisioners/docker/plugin.rb && sed -i.bak -e 's/redhat/centos/g' `bundle info --path vagrant`/plugins/provisioners/docker/plugin.rb) || true
