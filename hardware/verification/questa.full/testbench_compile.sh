#!/bin/sh

set -Eeuo pipefail
vlog -64 -incr -mfcu -sv \
	-L axi_vip_v1_1_19 \
	-L smartconnect_v1_0 \
	-L clk_vip_v1_0_5 \
	-L processing_system7_vip_v1_0_21 \
	-L rst_vip_v1_0_7 \
	-L xilinx_vip \
	-L xil_defaultlib \
	-work xil_defaultlib \
	testbench.sv

source AXI_master_and_slave_bd_wrapper_elaborate.do 2>&1 | tee elaborate.log
vsim -64 -do "do {AXI_master_and_slave_bd_wrapper_simulate.do}" -l simulate.log

