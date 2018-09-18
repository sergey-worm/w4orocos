#!/bin/bash
####################################################################################################
#
#  Checks for WrmOS and its components.
#
####################################################################################################

blddir=/tmp/wrm-test/w4orocos

# CONFIG
orocos_sparc_build=1
orocos_sparc_exec=2
orocos_arm_veca9_build=3
orocos_arm_veca9_exec=4
orocos_arm_zynqa9_build=5
orocos_arm_zynqa9_exec=6
orocos_x86_build=7
orocos_x86_exec=8
orocos_x86_64_build=9
orocos_x86_64_exec=10
orocos_lochst_build_full=11
orocos_lochst_exec_full=12
orocos_lochst_build_min=13
orocos_lochst_exec_min=14
result[$orocos_sparc_build]=-
result[$orocos_sparc_exec]=-
result[$orocos_arm_veca9_build]=-
result[$orocos_arm_veca9_exec]=-
result[$orocos_arm_zynqa9_build]=-
result[$orocos_arm_zynqa9_exec]=-
result[$orocos_x86_build]=-
result[$orocos_x86_exec]=-
result[$orocos_x86_64_build]=-
result[$orocos_x86_64_exec]=-
result[$orocos_lochst_build_full]=-
result[$orocos_lochst_exec_full]=-
result[$orocos_lochst_build_min]=-
result[$orocos_lochst_exec_min]=-

res_ok='\e[1;32m+\e[0m'
res_bad='\e[1;31m-\e[0m'

errors=0

function get_result
{
	if [ $rc == 0 ]; then echo $res_ok; else echo $res_bad; fi
}

function do_build
{
	id=$1
	prj=$2
	arch=$3
	brd=$4
	if [ $id == $orocos_lochst_build_full ]; then
		time make localhost-build-full B=$blddir/w4orocos-localhost-full -j
	else
	if [ $id == $orocos_lochst_build_min ]; then
		time make localhost-build-min B=$blddir/w4orocos-localhost-min -j
	else
		time make build P=cfg/prj/${prj}-qemu-${brd}.prj W=../wrmos B=$blddir/$prj-qemu-${brd} -j
	fi
	fi
	rc=$?
	echo "Build:  rc=$rc."
	result[$id]=$(get_result $rc)
	if [ ${result[$id]} != $res_ok ]; then ((errors++)); fi
}

function do_exec
{
	id=$1
	prj=$2
	arch=$3
	brd=$4
	machine=$5

	qemu_args="-display none -serial stdio"
	qemu_args_x86="-serial stdio"
	run_cmd="qemu-system-$arch -M $machine $qemu_args -kernel $blddir/$prj-qemu-$brd/ldr/bootloader.elf"
	file=$blddir/$prj-qemu-$brd/ldr/bootloader.elf
	if [ "$arch" == "x86" ]; then
		run_cmd="qemu-system-i386 $qemu_args_x86 -drive format=raw,file=$(realpath $blddir/$prj-qemu-$arch/ldr/bootloader.img)"
		file=$blddir/$prj-qemu-$brd/ldr/bootloader.img
	fi
	if [ "$arch" == "x86_64" ]; then
		run_cmd="qemu-system-$arch $qemu_args_x86 -drive format=raw,file=$(realpath $blddir/$prj-qemu-$arch/ldr/bootloader.img)"
		file=$blddir/$prj-qemu-$brd/ldr/bootloader.img
	fi
	if [ $id == $orocos_lochst_exec_full ]; then
		run_cmd="make localhost-run-deployer B=$blddir/w4orocos-localhost-full"
		file=$blddir/w4orocos-localhost-full/demo.oro/build/demo.elf
	fi
	if [ $id == $orocos_lochst_exec_min ]; then
		run_cmd="sh -c \"cd $blddir/w4orocos-localhost-min/demo.oro/build  &&  ./demo.elf\""
		file=$blddir/w4orocos-localhost-min/demo.oro/build/demo.elf
	fi

	if [ -f $file ]; then
		if [ $prj == orocos ]; then
			if [ $id == $orocos_lochst_exec_full ]; then
				$run_cmd
			else
				expect -c "\
					set timeout 30; \
					if { [catch {spawn $run_cmd} reason] } { \
						puts \"failed to spawn qemu: $reason\r\"; exit 1 }; \
					expect \"Bye-bye!\r\" {} timeout { exit 1 }; \
					expect \"terminated.\r\"  {} timeout { exit 2 }; \
					exit 0"
			fi
			rc=$?
		else
			rc=100  # unknown project
		fi
	else
		rc=200  # no exec file
	fi

	echo -e "\nExecute:  rc=$rc."
	result[$id]=$(get_result $rc)
	if [ ${result[$id]} != $res_ok ]; then ((errors++)); fi
}

function do_all
{
	rm -fr $blddir

	# cmd     id                         prj      arch    brd     machine

	do_build  $orocos_sparc_build        orocos   sparc   leon3   leon3_generic
	do_exec   $orocos_sparc_exec         orocos   sparc   leon3   leon3_generic
	#do_build  $orocos_arm_veca9_build   orocos   arm     veca9   vexpress-a9
	#do_exec   $orocos_arm_veca9_exec    orocos   arm     veca9   vexpress-a9
	#do_build  $orocos_arm_zynqa9_build  orocos   arm     zynqa9  xilinx-zynq-a9
	#do_exec   $orocos_arm_zynqa9_exec   orocos   arm     zynqa9  xilinx-zynq-a9
	#do_build  $orocos_x86_build         orocos   x86     x86     ""
	#do_exec   $orocos_x86_exec          orocos   x86     x86     ""
	#do_build  $orocos_x86_64_build      orocos   x86_64  x86_64  ""
	#do_exec   $orocos_x86_64_exec       orocos   x86_64  x86_64  ""
	do_build  $orocos_lochst_build_full  orocos   ""      ""      ""
	do_exec   $orocos_lochst_exec_full   orocos   ""      ""      ""
	do_build  $orocos_lochst_build_min   orocos   ""      ""      ""
	do_exec   $orocos_lochst_exec_min    orocos   ""      ""      ""
}

do_all

echo -e "---------------------------------------------------"
echo -e "  REPORT:"
echo -e "---------------------------------------------------"
echo -e "  project  arch      machine         build  execute"
echo -e "- - - - - - - - - - - - - - - - - - - - - - - - - -"
echo -e "  orocos   sparc     leon3_generic       ${result[$orocos_sparc_build]}        ${result[$orocos_sparc_exec]}"
echo -e "  orocos   arm       vexpress-a9         ${result[$orocos_arm_veca9_build]}        ${result[$orocos_arm_veca9_exec]}"
echo -e "  orocos   arm       xilinx-zynq-a9      ${result[$orocos_arm_zynqa9_build]}        ${result[$orocos_arm_zynqa9_exec]}"
echo -e "  orocos   x86                           ${result[$orocos_x86_build]}        ${result[$orocos_x86_exec]}"
echo -e "  orocos   x86_64                        ${result[$orocos_x86_64_build]}        ${result[$orocos_x86_64_exec]}"
echo -e "  orocos   loc-full                      ${result[$orocos_lochst_build_full]}        ${result[$orocos_lochst_exec_full]}"
echo -e "  orocos   loc-min                       ${result[$orocos_lochst_build_min]}        ${result[$orocos_lochst_exec_min]}"

echo -e "errors:  $errors"
exit $errors
