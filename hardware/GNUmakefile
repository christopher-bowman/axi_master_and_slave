#
#	Copyright (c) 2023 by Christopher R. Bowman. All rights reserved.
# 	contact: <my initials>@ChrisBowman.com

#
#	This make file is intended to be run via gmake as that is what's 
#	natively available on the Linux systems that would run Vivado
#

VIVADO_VERSION?=2024.2
VIVADO_PATH?=/eda/xilinx/$(VIVADO_VERSION)
VIVADO_INSTALL?=$(VIVADO_PATH)/Vivado/$(VIVADO_VERSION)
PROJ_NAME?=AXI_master_and_slave
SCRIPT?=project.tcl
#SCRIPT?=$(PROJ_NAME).tcl
XBIT2BIN_LOCATION?=~/bin
OS:=$(shell uname)
ARCH:=$(shell uname -p)

# Experimental support for executing Vivado on FreeBSD
# while this works to call Vivado, Vivado doesn't always work
# the same on FreeBSD 
# don't really need to call a shell on Linux but it keeps things
# similar between the two platforms.  On FreeBSD we definitely do
# need to run the shell so that the scripts are executed in Linux
# emulation mode so that when a Vivado binary is finally called
# it's run under Linux emulation

ifeq ($(OS), Linux)
	SHELL=/bin/sh
else
	SHELL=/compat/linux/bin/sh
endif

# default target is to build the bit file

bit: $(PROJ_NAME).bit 

boards/vivado-boards/new/board_files/arty-z7-20/A.0:
	echo "fetching Digilent master board files git repo"
	mkdir -p boards
	(cd  boards && git clone https://github.com/Digilent/vivado-boards)

source/constraints/Arty-Z7-20-Master.xdc:
	(cd source/constraints ; fetch https://raw.githubusercontent.com/Digilent/digilent-xdc/deb00e66689337700b3a18c0e3776dcf4a59655b/Arty-Z7-20-Master.xdc)

$(PROJ_NAME).bit: implementation/$(PROJ_NAME)/$(PROJ_NAME).runs/impl_1/$(PROJ_NAME)_bd_wrapper.bit 
	cp implementation/$(PROJ_NAME)/$(PROJ_NAME).runs/impl_1/$(PROJ_NAME)_bd_wrapper.bit $(PROJ_NAME).bit

implementation/$(PROJ_NAME)/$(PROJ_NAME).runs/impl_1/$(PROJ_NAME)_bd_wrapper.bit: source/verilog/* source/constraints/* boards/vivado-boards/new/board_files/arty-z7-20/A.0
	mkdir -p implementation
	$(SHELL) -c "source $(VIVADO_INSTALL)/settings64.sh ; cd implementation ; vivado -mode tcl -source ../scripts/$(SCRIPT) -tclargs --generate_bit"

# you can also just build the project so that you can run it in the Vivado GUI
$(PROJ_NAME):
	mkdir -p implementation
	(cd implementation && $(SHELL) -c "vivado -mode tcl -source ../scripts/$(SCRIPT)")
	
ip:
	mkdir -p implementation/ip
	(cd implementation/ip && $(SHELL) -c "vivado -mode batch -source ../../scripts/create_ip.tcl")

program: $(PROJ_NAME).bit
ifeq ($(OS), FreeBSD)
	ifeq ($(ARCH), armv7)
		$(XBIT2BIN_LOCATION)/xbit2bin $(PROJ_NAME).bit
	else
		@echo "Programming must happen on the target board"
		exit 1
	endif
else
	@echo "Programming must happen on the target board"
	exit 1
endif
	
clean:
	rm -rf implementation
	rm -rf $(PROJ_NAME).bit
	rm -rf .Xil vivado.jou vivado.log

realclean: clean
	rm -rf boards
    
.PHONY: $(PROJ_NAME) bit clean program
