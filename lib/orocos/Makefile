####################################################################################################
#
#  Static library makefile.
#
####################################################################################################

incs := $(cfgdir)
incs += $(wrmdir)/lib/wlibc/inc
incs += $(wrmdir)/lib/wrmos/inc
incs += $(wrmdir)/lib/l4/inc
incs += $(wrmdir)/lib/sys
libs := $(rtblddir)/lib/wlibc/libwlibc.a
libs += $(rtblddir)/lib/l4/libl4.a
libs += $(rtblddir)/lib/wrmos/libwrmos.a

# replace ' ' --> ';'
empty =
space = $(empty) $(empty)
oro_incdirs = $(subst $(space),;,$(incs))
oro_libs = $(subst $(space),;,$(libs))

.PHONY:  clean distclean FORCE

# must be first target
$(blddir)/liborocos.a:  FORCE $(libs) $(blddir)/orocos/src/orocos_toolchain/.git
	# build
	cd $(blddir)/orocos  && \
	touch librt.a  && \
	catkin_make_isolated --install --pkg log4cpp rtt \
		-DOROCOS_TARGET=wrmos \
		-DBUILD_STATIC=ON \
		-DCMAKE_CXX_COMPILER=$(gccprefix)g++ \
		-DCMAKE_C_COMPILER=$(gccprefix)gcc \
		-DCMAKE_SYSTEM_LIBRARY_PATH=$$(pwd) \
		-DENABLE_MQ=0 \
		-DPLUGINS_ENABLE_SCRIPTING=0 \
		-DBUILD_TASKBROWSER=0 \
		-DBUILD_DEPLOYMENT=0 \
		-DPLUGINS_ENABLE=0 \
		-DWRMOS_INCDIRS='$(oro_incdirs)' \
		-DWRMOS_LIBS='$(oro_libs)'
	# fake installation of plugin dir
	mkdir -p $(blddir)/orocos/install_isolated/include/rtt/plugin
	cp -u $(blddir)/orocos/src/orocos_toolchain/rtt/rtt/plugin/rtt-plugin-fwd.hpp \
		$(blddir)/orocos/install_isolated/include/rtt/plugin/
	# copy result
	cp -u $(blddir)/orocos/install_isolated/lib/liborocos-rtt-wrmos.a $(blddir)/liborocos.a

#git_url = $(shell dirname $(git config --get remote.origin.url))

# get sources
$(blddir)/orocos/src/orocos_toolchain/.git:
	mkdir -p $(blddir)/orocos/src
	git clone --recursive https://github.com/orocos-toolchain/orocos_toolchain.git \
		$(blddir)/orocos/src/orocos_toolchain
	# override rtt sources
	mv $(blddir)/orocos/src/orocos_toolchain/rtt/package.xml \
		$(blddir)/orocos/src/orocos_toolchain/rtt/_package.xml
	mv $(blddir)/orocos/src/orocos_toolchain/rtt $(blddir)/orocos/src/orocos_toolchain/rtt.orig
	rtt_base_url=$(shell dirname $(git config --get remote.origin.url))  && \
		if [ "$$rtt_base_url" == "" ]; then rtt_base_url=https://github.com/sergey-worm; fi  && \
		echo rtt_base_url=$$rtt_base_url  && \
		git clone -b wrmos $$rtt_base_url/rtt.git $(blddir)/orocos/src/orocos_toolchain/rtt

clean-files::
	rm -fr $(blddir)/orocos/build_isolated
	rm -fr $(blddir)/orocos/.catkin_workspace
	rm -fr $(blddir)/orocos/devel_isolated
	rm -fr $(blddir)/orocos/install_isolated
	rm -fr $(blddir)/orocos/librt.a

distclean:
	rm -fr $(blddir)/orocos

# need include for 'wrmos' and not need for 'localhost'
-include $(wrmdir)/mk/base.mk
