####################################################################################################
#
#  Root makefile for w4orocos project.
#
####################################################################################################

help:
	@echo -e "Use wrmos targets:"
	@echo -e "  make build   P=<path/*.prj> W=<wrmos-dir> B=<build-dir> [ V=1 ]"
	@echo -e "  make rebuild P=<path/*.prj> W=<wrmos-dir> B=<build-dir> [ V=1 ]"
	@echo -e "  make clean   P=<path/*.prj> W=<wrmos-dir> B=<build-dir> [ V=1 ]"
	@echo -e
	@echo -e "Use localhost targets:"
	@echo -e "  make localhost-full B=<build-dir>  - full build and run demo as executable and by deployer"
	@echo -e "  make localhost-min B=<build-dir>   - minimal build and run demo as executable"
	@echo -e ""

build:
	mkdir -p $B
	+make -C $W build P=$(shell pwd)/$P B=$(abspath $B) E=$(shell pwd) V=$V

clean:
	mkdir -p $B
	+make -C $W clean P=$(shell pwd)/$P B=$(abspath $B) E=$(shell pwd) V=$V

rebuild:
	+make clean P=$P W=$W B=$B
	+make build P=$P W=$W B=$B

# LOCALHOST RULES

localhost-full:  localhost-build-full
	+make localhost-run-executable
	+make localhost-run-deployer

localhost-min:  localhost-build-min
	+make localhost-run-executable

localhost-build-full:  localhost-get-sources
	+make localhost-build-orocos-full
	+make localhost-build-demo

localhost-build-min:  localhost-get-sources
	+make localhost-build-orocos-min
	+make localhost-build-demo

localhost-get-sources:
	mkdir -p $B
	+make -C lib/orocos $(abspath $B)/orocos/src/orocos_toolchain/.git blddir=$(abspath $B)
	rsync -au app/orocos/demo.oro/ $B/demo.oro/

localhost-clean:
	+make localhost-clean-orocos
	+make localhost-clean-demo

localhost-distclean:
	rm -fr $B/*

# LOCALHOST OROCOS RULES

localhost-build-orocos-full:
	cd $B/orocos && \
		catkin_make_isolated --install -DBUILD_STATIC=ON

localhost-build-orocos-min:
	cd $B/orocos  && \
		catkin_make_isolated --install \
			--pkg log4cpp rtt \
			-DBUILD_STATIC=ON \
			-DENABLE_MQ=0 \
			-DPLUGINS_ENABLE_SCRIPTING=0 \
			-DBUILD_TASKBROWSER=0 \
			-DBUILD_DEPLOYMENT=0 \
			-DPLUGINS_ENABLE=1

localhost-clean-orocos:
	cd $B/orocos  &&  \
		rm -fr build_isolated .catkin_workspace devel_isolated install_isolated

# LOCALHOST DEMO RULES

localhost-build-demo:
	mkdir -p $B/demo.oro/build
	cd $B/demo.oro/build  && \
		. ../../orocos/install_isolated/setup.sh  && \
			cmake ..  \
				-DOROCOS_TARGET=gnulinux \
				-DOROCOS_INSTALL_DIR=$(abspath $B)/orocos/install_isolated \
				-DEXTERNAL_LD_FLAGS='-pthread -lboost_system -lboost_filesystem -ldl'  && \
			make

localhost-clean-demo:
	rm -fr $B/demo.oro/build

# LOCALHOST RUN RULES

localhost-run-executable:
	@# change dir before to avoid creating orocos.log file inside source dir
	cd $B/demo.oro/build  &&  ./demo.elf

run_deployer = $(abspath $B)/orocos/install_isolated/bin/deployer -s ../src/start.ops -linfo

localhost-run-deployer:
	cd $B/demo.oro/build  &&  \
		expect -c "\
			set timeout 10; \
			if { [catch {spawn $(run_deployer)} reason] } { \
				puts \"failed to spawn deployer: $$reason\r\"; exit 1 }; \
			expect \"to exit this program\" { send \"quit\r\" } timeout { exit 2 }; \
		exit 0"
