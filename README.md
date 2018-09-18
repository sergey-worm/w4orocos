# w4orocos

OROCOS ported to WrmOS.

## Description

This repository contains:
* lib/orocos - ported to WrmOS OROCOS (rtt);
* app/orocos - demonstration OROCOS project;
* Makefile   - rules to build and run OROCOS demo project on WrmOS or on localhost.

More information about OROCOS you can find here:
* orocos.org
* github.com/orocos/rtt_ros_integration

## How to

Build and run:

	qemu-sparc-leon3:
		make build P=cfg/prj/orocos-qemu-leon3.prj W=../wrmos B=../build/w4orocos
		qemu-system-sparc -M leon3_generic -display none -serial stdio \
			-kernel ../build/w4orocos/ldr/bootloader.elf

	localhost-with-deployer:
		make localhost-build-full B=../build/w4orocos.loc
		make localhost-run-deployer B=../build/w4orocos.loc

	localhost-minimal:
		make localhost-build-min B=../build/w4orocos.loc
		make localhost-run-executable B=../build/w4orocos.loc

Autotest (sanity check):

	mk/test.sh

## Contacts

Sergey Worm <sergey.worm@gmail.com>

