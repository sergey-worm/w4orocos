####################################################################################################
#
#  Makefile for user application.
#  External vars my be:
#    arch      - target arch
#    dbg       - debug flag
#    cfgdir    - path to dir that contents sys-config.h
#    blddir    - path to dir that will content build result
#    wrmdir    - path to wrmos source dir
#
####################################################################################################

incflags   := -I$(cfgdir)
libs       := $(rtblddir)/lib/l4/libl4.a
libs       += $(rtblddir)/lib/wrmos/libwrmos.a
libs       += $(rtblddir)/lib/wlibc/libwlibc.a
libs       += $(rtblddir)/lib/console/libconsole.a
libs       += $(rtblddir)/lib/wpthread/libwpthread.a
libs       += $(rtblddir)/lib/orocos/liborocos.a

oro_ld_flags := -nostdlib -Wl,--start-group $(libs) -lgcc -lgcc_eh -lstdc++ -latomic
oro_ld_flags += /home/worm/Bin/Toolchains/__sparc_uclibc-1.0.17_libm.a
oro_ld_flags += -Wl,--end-group -Wl,-T$(blddir)/link.ld

oro_install_dir = $(blddir)/../../lib/orocos/orocos/install_isolated

.PHONY:  $(blddir)/orocos.elf clean distclean FORCE

# must be first target
$(blddir)/orocos.elf:  FORCE $(libs) $(blddir)/link.ld
	rsync -au ./demo.oro/ $(blddir)/demo.oro/
		mkdir -p $(blddir)/demo.oro/build  && \
		cd $(blddir)/demo.oro/build  && \
		source $(oro_install_dir)/setup.sh  && \
		cmake .. -DCMAKE_CXX_COMPILER=$(gccprefix)g++ \
			-DCMAKE_C_COMPILER=$(gccprefix)gcc \
			-DOROCOS_TARGET=wrmos \
			-DOROCOS_INSTALL_DIR=$(oro_install_dir) \
			-DEXTERNAL_LD_FLAGS='$(oro_ld_flags)' && \
		make VERBOSE=$V
	$(v)cp -f $(blddir)/demo.oro/build/demo.elf $(blddir)/orocos.elf

clean-files::
	rm -f $(blddir)/link.*
	rm -f $(blddir)/orocos.elf
	rm -fr $(blddir)/demo.oro/build

distclean:
	rm -f $(blddir)/link.*
	rm -f $(blddir)/orocos.elf
	rm -fr $(blddir)/demo.oro

include $(wrmdir)/mk/base.mk


