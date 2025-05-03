# this compiles only the DUT which shouldn't change much, it's far more
# likely to iterate on the testbench code or to have multiple
# testbenches so compiling that is split out

vivado_path="/eda/xilinx/2024.2/Vivado/2024.2"
implementation_path="../../implementation/AXI_master_and_slave"
vip_hdl="${vivado_path}/data/xilinx_vip/hdl"
vip_include="${vivado_path}/data/xilinx_vip/include"
vivado_ip_path="${vivado_path}/data/ip"

vlib questa_lib/work
vlib questa_lib/msim

vlib questa_lib/msim/xilinx_vip
vlib questa_lib/msim/xpm
vlib questa_lib/msim/xil_defaultlib
vlib questa_lib/msim/clk_vip_v1_0_5
vlib questa_lib/msim/rst_vip_v1_0_7
vlib questa_lib/msim/axi_infrastructure_v1_1_0
vlib questa_lib/msim/axi_vip_v1_1_19

vmap xilinx_vip questa_lib/msim/xilinx_vip
vmap xpm questa_lib/msim/xpm
vmap xil_defaultlib questa_lib/msim/xil_defaultlib
vmap clk_vip_v1_0_5 questa_lib/msim/clk_vip_v1_0_5
vmap rst_vip_v1_0_7 questa_lib/msim/rst_vip_v1_0_7
vmap axi_infrastructure_v1_1_0 questa_lib/msim/axi_infrastructure_v1_1_0
vmap axi_vip_v1_1_19 questa_lib/msim/axi_vip_v1_1_19

vlog -64 -incr -mfcu -sv \
	-L axi_vip_v1_1_19 \
	-L smartconnect_v1_0 \
	-L clk_vip_v1_0_5 \
	-L processing_system7_vip_v1_0_21 \
	-L rst_vip_v1_0_7 \
	-L xilinx_vip \
	-work xilinx_vip  \
	"+incdir+${vivado_path}/data/xilinx_vip/include" \
	"${vip_hdl}/axi4stream_vip_axi4streampc.sv" \
	"${vip_hdl}/axi_vip_axi4pc.sv" \
	"${vip_hdl}/xil_common_vip_pkg.sv" \
	"${vip_hdl}/axi4stream_vip_pkg.sv" \
	"${vip_hdl}/axi_vip_pkg.sv" \
	"${vip_hdl}/axi4stream_vip_if.sv" \
	"${vip_hdl}/axi_vip_if.sv" \
	"${vip_hdl}/clk_vip_if.sv" \
	"${vip_hdl}/rst_vip_if.sv"

vlog -64 -incr -mfcu -sv \
	-L axi_vip_v1_1_19 \
	-L smartconnect_v1_0 \
	-L clk_vip_v1_0_5 \
	-L processing_system7_vip_v1_0_21 \
	-L rst_vip_v1_0_7 \
	-L xilinx_vip \
	-work xpm  \
	"+incdir+${implementation_path}/AXI_master_and_slave.gen/sources_1/bd/AXI_master_and_slave_bd/ipshared/ec67/hdl" \
	"+incdir+${implementation_path}/AXI_master_and_slave.gen/sources_1/bd/AXI_master_and_slave_bd/ipshared/86fe/hdl" \
	"+incdir+${implementation_path}/AXI_master_and_slave.gen/sources_1/bd/AXI_master_and_slave_bd/ipshared/f0b6/hdl/verilog" \
	"+incdir+${implementation_path}/AXI_master_and_slave.gen/sources_1/bd/AXI_master_and_slave_bd/ipshared/0127/hdl/verilog" \
	"+incdir+${vivado_path}/data/xilinx_vip/include" \
	"${vivado_path}/data/ip/xpm/xpm_fifo/hdl/xpm_fifo.sv" \
	"${vivado_path}/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \
	"${vivado_path}/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv"

vlog -64 -incr -mfcu \
	-work xil_defaultlib  \
	"+incdir+${implementation_path}/AXI_master_and_slave.gen/sources_1/bd/AXI_master_and_slave_bd/ipshared/ec67/hdl" \
	"+incdir+${implementation_path}/AXI_master_and_slave.gen/sources_1/bd/AXI_master_and_slave_bd/ipshared/86fe/hdl" \
	"+incdir+${implementation_path}/AXI_master_and_slave.gen/sources_1/bd/AXI_master_and_slave_bd/ipshared/f0b6/hdl/verilog" \
	"+incdir+${implementation_path}/AXI_master_and_slave.gen/sources_1/bd/AXI_master_and_slave_bd/ipshared/0127/hdl/verilog" \
	"+incdir+${vivado_path}/data/xilinx_vip/include" \
	"${implementation_path}/AXI_master_and_slave.srcs/sources_1/imports/verilog/AXI_master.v" \
	"${implementation_path}/AXI_master_and_slave.srcs/sources_1/imports/verilog/AXI_slave.v" \
	"${implementation_path}/AXI_master_and_slave.srcs/sources_1/imports/verilog/AXI_master_and_slave.v" \
	"${implementation_path}/AXI_master_and_slave.gen/sources_1/bd/AXI_master_and_slave_bd/ip/AXI_master_and_slave_bd_AXI_master_and_slave_inst_0/sim/AXI_master_and_slave_bd_AXI_master_and_slave_inst_0.v" \
	"${implementation_path}/AXI_master_and_slave.gen/sources_1/bd/AXI_master_and_slave_bd/ip/AXI_master_and_slave_bd_processing_system7_0_0/AXI_master_and_slave_bd_processing_system7_0_0_sim_netlist.v" \
	"${implementation_path}/AXI_master_and_slave.gen/sources_1/bd/AXI_master_and_slave_bd/ip/AXI_master_and_slave_bd_ps7_0_axi_periph_0/AXI_master_and_slave_bd_ps7_0_axi_periph_0_sim_netlist.v" \
	"${implementation_path}/AXI_master_and_slave.gen/sources_1/bd/AXI_master_and_slave_bd/ip/AXI_master_and_slave_bd_rst_ps7_0_100M_0/AXI_master_and_slave_bd_rst_ps7_0_100M_0_sim_netlist.v" \
	"${implementation_path}/AXI_master_and_slave.gen/sources_1/bd/AXI_master_and_slave_bd/ip/AXI_master_and_slave_bd_axi_mem_intercon_0/AXI_master_and_slave_bd_axi_mem_intercon_0_sim_netlist.v"

vlog -64 -incr -mfcu -sv \
	-L axi_vip_v1_1_19 \
	-L smartconnect_v1_0 \
	-L clk_vip_v1_0_5 \
	-L processing_system7_vip_v1_0_21 \
	-L rst_vip_v1_0_7 \
	-L xilinx_vip \
	-work clk_vip_v1_0_5  \
	"+incdir+${implementation_path}/AXI_master_and_slave.gen/sources_1/bd/AXI_master_and_slave_bd/ipshared/ec67/hdl" \
	"+incdir+${implementation_path}/AXI_master_and_slave.gen/sources_1/bd/AXI_master_and_slave_bd/ipshared/86fe/hdl" \
	"+incdir+${implementation_path}/AXI_master_and_slave.gen/sources_1/bd/AXI_master_and_slave_bd/ipshared/f0b6/hdl/verilog" \
	"+incdir+${implementation_path}/AXI_master_and_slave.gen/sources_1/bd/AXI_master_and_slave_bd/ipshared/0127/hdl/verilog" \
	"+incdir+${vivado_path}/data/xilinx_vip/include" \
	"${implementation_path}/AXI_master_and_slave.gen/sources_1/bd/AXI_master_and_slave_bd/ipshared/b422/hdl/clk_vip_v1_0_vl_rfs.sv"

vlog -64 -incr -mfcu -sv \
	-L axi_vip_v1_1_19 \
	-L smartconnect_v1_0 \
	-L clk_vip_v1_0_5 \
	-L processing_system7_vip_v1_0_21 \
	-L rst_vip_v1_0_7 \
	-L xilinx_vip \
	-work xil_defaultlib  \
	"+incdir+${implementation_path}/AXI_master_and_slave.gen/sources_1/bd/AXI_master_and_slave_bd/ipshared/ec67/hdl" \
	"+incdir+${implementation_path}/AXI_master_and_slave.gen/sources_1/bd/AXI_master_and_slave_bd/ipshared/86fe/hdl" \
	"+incdir+${implementation_path}/AXI_master_and_slave.gen/sources_1/bd/AXI_master_and_slave_bd/ipshared/f0b6/hdl/verilog" \
	"+incdir+${implementation_path}/AXI_master_and_slave.gen/sources_1/bd/AXI_master_and_slave_bd/ipshared/0127/hdl/verilog" \
	"+incdir+${vivado_path}/data/xilinx_vip/include" \
	"${implementation_path}/AXI_master_and_slave.gen/sources_1/bd/AXI_master_and_slave_bd/ip/AXI_master_and_slave_bd_clk_vip_0_0/sim/AXI_master_and_slave_bd_clk_vip_0_0.sv"

vlog -64 -incr -mfcu -sv \
	-L axi_vip_v1_1_19 \
	-L smartconnect_v1_0 \
	-L clk_vip_v1_0_5 \
	-L processing_system7_vip_v1_0_21 \
	-L rst_vip_v1_0_7 \
	-L xilinx_vip \
	-work rst_vip_v1_0_7  \
	"+incdir+${implementation_path}/AXI_master_and_slave.gen/sources_1/bd/AXI_master_and_slave_bd/ipshared/ec67/hdl" \
	"+incdir+${implementation_path}/AXI_master_and_slave.gen/sources_1/bd/AXI_master_and_slave_bd/ipshared/86fe/hdl" \
	"+incdir+${implementation_path}/AXI_master_and_slave.gen/sources_1/bd/AXI_master_and_slave_bd/ipshared/f0b6/hdl/verilog" \
	"+incdir+${implementation_path}/AXI_master_and_slave.gen/sources_1/bd/AXI_master_and_slave_bd/ipshared/0127/hdl/verilog" \
	"+incdir+${vivado_path}/data/xilinx_vip/include" \
	"${implementation_path}/AXI_master_and_slave.gen/sources_1/bd/AXI_master_and_slave_bd/ipshared/0b27/hdl/rst_vip_v1_0_vl_rfs.sv"

vlog -64 -incr -mfcu -sv \
	-L axi_vip_v1_1_19 \
	-L smartconnect_v1_0 \
	-L clk_vip_v1_0_5 \
	-L processing_system7_vip_v1_0_21 \
	-L rst_vip_v1_0_7 \
	-L xilinx_vip \
	-work xil_defaultlib  \
	"+incdir+${implementation_path}/AXI_master_and_slave.gen/sources_1/bd/AXI_master_and_slave_bd/ipshared/ec67/hdl" \
	"+incdir+${implementation_path}/AXI_master_and_slave.gen/sources_1/bd/AXI_master_and_slave_bd/ipshared/86fe/hdl" \
	"+incdir+${implementation_path}/AXI_master_and_slave.gen/sources_1/bd/AXI_master_and_slave_bd/ipshared/f0b6/hdl/verilog" \
	"+incdir+${implementation_path}/AXI_master_and_slave.gen/sources_1/bd/AXI_master_and_slave_bd/ipshared/0127/hdl/verilog" \
	"+incdir+${vivado_path}/data/xilinx_vip/include" \
	"${implementation_path}/AXI_master_and_slave.gen/sources_1/bd/AXI_master_and_slave_bd/ip/AXI_master_and_slave_bd_rst_vip_0_0/sim/AXI_master_and_slave_bd_rst_vip_0_0.sv"

vlog -64 -incr -mfcu -work axi_infrastructure_v1_1_0  \
	"+incdir+${implementation_path}/AXI_master_and_slave.gen/sources_1/bd/AXI_master_and_slave_bd/ipshared/ec67/hdl" \
	"+incdir+${implementation_path}/AXI_master_and_slave.gen/sources_1/bd/AXI_master_and_slave_bd/ipshared/86fe/hdl" \
	"+incdir+${implementation_path}/AXI_master_and_slave.gen/sources_1/bd/AXI_master_and_slave_bd/ipshared/f0b6/hdl/verilog" \
	"+incdir+${implementation_path}/AXI_master_and_slave.gen/sources_1/bd/AXI_master_and_slave_bd/ipshared/0127/hdl/verilog" \
	"+incdir+${vivado_path}/data/xilinx_vip/include" \
	"${implementation_path}/AXI_master_and_slave.gen/sources_1/bd/AXI_master_and_slave_bd/ipshared/ec67/hdl/axi_infrastructure_v1_1_vl_rfs.v"

vlog -64 -incr -mfcu -sv \
	-L axi_vip_v1_1_19 \
	-L smartconnect_v1_0 \
	-L clk_vip_v1_0_5 \
	-L processing_system7_vip_v1_0_21 \
	-L rst_vip_v1_0_7 \
	-L xilinx_vip \
	-work xil_defaultlib  \
	"+incdir+${implementation_path}/AXI_master_and_slave.gen/sources_1/bd/AXI_master_and_slave_bd/ipshared/ec67/hdl" \
	"+incdir+${implementation_path}/AXI_master_and_slave.gen/sources_1/bd/AXI_master_and_slave_bd/ipshared/86fe/hdl" \
	"+incdir+${implementation_path}/AXI_master_and_slave.gen/sources_1/bd/AXI_master_and_slave_bd/ipshared/f0b6/hdl/verilog" \
	"+incdir+${implementation_path}/AXI_master_and_slave.gen/sources_1/bd/AXI_master_and_slave_bd/ipshared/0127/hdl/verilog" \
	"+incdir+${vivado_path}/data/xilinx_vip/include" \
	"${implementation_path}/AXI_master_and_slave.gen/sources_1/bd/AXI_master_and_slave_bd/ip/AXI_master_and_slave_bd_axi_master_vip_0_0/sim/AXI_master_and_slave_bd_axi_master_vip_0_0.sv" \
	"${implementation_path}/AXI_master_and_slave.gen/sources_1/bd/AXI_master_and_slave_bd/ip/AXI_master_and_slave_bd_axi_master_vip_0_0/sim/AXI_master_and_slave_bd_axi_master_vip_0_0_pkg.sv" \
	"${implementation_path}/AXI_master_and_slave.gen/sources_1/bd/AXI_master_and_slave_bd/ip/AXI_master_and_slave_bd_axi_slave_vip_0_0/sim//AXI_master_and_slave_bd_axi_slave_vip_0_0.sv" \
	"${implementation_path}/AXI_master_and_slave.gen/sources_1/bd/AXI_master_and_slave_bd/ip/AXI_master_and_slave_bd_axi_slave_vip_0_0/sim/AXI_master_and_slave_bd_axi_slave_vip_0_0_pkg.sv" \

vlog -64 -incr -mfcu -sv \
	-L axi_vip_v1_1_19 \
	-L smartconnect_v1_0 \
	-L clk_vip_v1_0_5 \
	-L processing_system7_vip_v1_0_21 \
	-L rst_vip_v1_0_7 \
	-L xilinx_vip \
	-work axi_vip_v1_1_19  \
	"+incdir+${implementation_path}/AXI_master_and_slave.gen/sources_1/bd/AXI_master_and_slave_bd/ipshared/ec67/hdl" \
	"+incdir+${implementation_path}/AXI_master_and_slave.gen/sources_1/bd/AXI_master_and_slave_bd/ipshared/86fe/hdl" \
	"+incdir+${implementation_path}/AXI_master_and_slave.gen/sources_1/bd/AXI_master_and_slave_bd/ipshared/f0b6/hdl/verilog" \
	"+incdir+${implementation_path}/AXI_master_and_slave.gen/sources_1/bd/AXI_master_and_slave_bd/ipshared/0127/hdl/verilog" \
	"+incdir+${vivado_path}/data/xilinx_vip/include" \
	"${implementation_path}/AXI_master_and_slave.gen/sources_1/bd/AXI_master_and_slave_bd/ipshared/8c45/hdl/axi_vip_v1_1_vl_rfs.sv"

vlog -64 -incr -mfcu \
	-work xil_defaultlib  \
	"+incdir+${implementation_path}/AXI_master_and_slave.gen/sources_1/bd/AXI_master_and_slave_bd/ipshared/ec67/hdl" \
	"+incdir+${implementation_path}/AXI_master_and_slave.gen/sources_1/bd/AXI_master_and_slave_bd/ipshared/86fe/hdl" \
	"+incdir+${implementation_path}/AXI_master_and_slave.gen/sources_1/bd/AXI_master_and_slave_bd/ipshared/f0b6/hdl/verilog" \
	"+incdir+${implementation_path}/AXI_master_and_slave.gen/sources_1/bd/AXI_master_and_slave_bd/ipshared/0127/hdl/verilog" \
	"+incdir+${vivado_path}/data/xilinx_vip/include" \
	"${implementation_path}/AXI_master_and_slave.gen/sources_1/bd/AXI_master_and_slave_bd/sim/AXI_master_and_slave_bd.v" \
	"${implementation_path}/AXI_master_and_slave.gen/sources_1/bd/AXI_master_and_slave_bd/hdl/AXI_master_and_slave_bd_wrapper.v"

# compile glbl module
vlog -work xil_defaultlib "glbl.v"
