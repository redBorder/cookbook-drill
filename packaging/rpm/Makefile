PACKAGE_NAME?= cookbook-drill
VERSION?=	$(shell git describe --abbrev=6 --tags HEAD --always | sed 's/-/_/g')
BUILD_NUMBER?=1
MOCK_CONFIG?=default
RESULT_DIR?=pkgs
LATEST?=HEAD

all: rpm

SOURCES:
	mkdir -p SOURCES

archive:
	mkdir -p SOURCES
	tar -C ../.. \
		-czvf SOURCES/$(PACKAGE_NAME)-$(VERSION).tar.gz \
		--transform="s,^,$(PACKAGE_NAME)-$(VERSION)/," \
		resources	

build_prepare: archive
	mkdir -p $(RESULT_DIR)
	rm -rf $(RESULT_DIR)/$(PACKAGE_NAME)*.rpm

srpm: build_prepare
	rpmbuild -bs \
		--define "_topdir $(shell pwd)" \
		--define "_sourcedir $(shell pwd)/SOURCES" \
		--define "_srcrpmdir $(shell pwd)/$(RESULT_DIR)" \
		--define "__version $(VERSION)" \
		--define "__release $(BUILD_NUMBER)" \
		cookbook-drill.spec


rpm: srpm
	/usr/bin/mock \
		-r $(MOCK_CONFIG) \
		--define "__version $(VERSION)" \
		--define "__release $(BUILD_NUMBER)" \
		--resultdir $(RESULT_DIR) \
		--rebuild $(RESULT_DIR)/$(PACKAGE_NAME)*.src.rpm
	echo "========= Binary RPMs created in $(RESULT_DIR) =========="

clean:
	rm -rf SOURCES pkgs

distclean: clean
	rm -f build.log root.log state.log available_pkgs installed_pkgs \
		*.rpm *.tar.gz
