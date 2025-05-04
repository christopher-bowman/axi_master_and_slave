#
# Copyright (c) 2022 by Christopher R. Bowman. All rights reserved.
# contact: <my initials>@ChrisBowman.com
#

# Note: device_if.h bus_if.h and pci_if.h
# are all created by the build system but only
# if you add them to the SRCS dependencies

# SRCS=axi_2x7sd.c device_if.h bus_if.h ofw_bus_if.h
# KMOD=axi_2x7sd
SRCS=AXI_master_and_slave.c device_if.h bus_if.h ofw_bus_if.h
KMOD=AXI_master_and_slave

DTC=/usr/bin/dtc

artyz7_axi_mas_overlay.dtb: artyz7_axi_mas_overlay.dts
	${DTC} -I dts -O dtb -o artyz7_axi_mas_overlay.dtb artyz7_axi_mas_overlay.dts 

# note make sure your .dts file uses /include/ not #include
zynq-artyz7.dtb: zynq-7000.dtsi zynq-artyz7.dts
	${DTC} -@ -i . -I dts -O dtb -o zynq-artyz7.dtb zynq-artyz7.dts

load:
	kldload ./AXI_master_and_slave.ko

unload:
	kldunload AXI_master_and_slave.ko

program:
	~crb/bin/xbit2bin ../../../../hardware/AXI_master_and_slave.bit

stat:
	kldstat

.include <bsd.kmod.mk>
