//////////////////////////////////////////////////////////////////////////////////
// Copyright (C) 2023 Christopher R. Bowman
// All rights reserved
//
// Company: ChrisBowman.com
// Engineer: Christopher R. Bowman
// Contact: <my initials>@ChrisBowman.com
//
// Creation Date: 01/028/2023 15:28:11 PM
// Design Name: 
// Module Name: AXI_master_and_slave
// Project Name: AXI_master_and_slave
// Target Devices: xc7z020clg400-1
// Tool Versions: 2022.2
//
// Dependencies: 
// 
//////////////////////////////////////////////////////////////////////////////////

`timescale 1 ns / 1 ps

module AXI_master_and_slave #
(
    // Parameters of Axi Slave Bus Interface axi_S0
    parameter integer C_S0_axi_DATA_WIDTH	= 32,
    parameter integer C_S0_axi_ADDR_WIDTH	= 4,

	// Parameters of Axi Master Bus Interface M_AXI
	parameter C_M_AXI_TARGET_SLAVE_BASE_ADDR	= 32'h40000000,
	parameter integer C_M_AXI_BURST_LEN	= 16,
	parameter integer C_M_AXI_ID_WIDTH	= 1,
	parameter integer C_M_AXI_ADDR_WIDTH	= 32,
	parameter integer C_M_AXI_DATA_WIDTH	= 32,
	parameter integer C_M_AXI_AWUSER_WIDTH	= 0,
	parameter integer C_M_AXI_ARUSER_WIDTH	= 0,
	parameter integer C_M_AXI_WUSER_WIDTH	= 0,
	parameter integer C_M_AXI_RUSER_WIDTH	= 0,
	parameter integer C_M_AXI_BUSER_WIDTH	= 0
)
(
    //(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME clk, ASSOCIATED_BUSIF none, CLK_DOMAIN my_clk" *)
    (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME clk, ASSOCIATED_BUSIF none" *)
    (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 clk CLK" *)

    input  wire       clk,
    output wire [4:1] ja_p,
    output wire [4:1] ja_n,
    output wire [4:1] jb_p,
    output wire [4:1] jb_n,
    output wire [3:0] led,

    // Ports of Axi Slave Bus Interface axi_S0
  //(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME axi_interface_CLK , ASSOCIATED_BUSIF axi_interface, ASSOCIATED_RESET S0_axi_aresetn, FREQ_HZ 100000000, FREQ_TOLERANCE_HZ 0, PHASE 0.0, CLK_DOMAIN design_1_processing_system7_0_0_FCLK_CLK0, INSERT_VIP 0" *)
  (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME axi_interface_CLK , ASSOCIATED_BUSIF axi_interface, ASSOCIATED_RESET S0_axi_aresetn, FREQ_HZ 100000000, FREQ_TOLERANCE_HZ 0, PHASE 0.0, INSERT_VIP 0" *)
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 axi_interface_CLK CLK" *)
    input  wire                              S0_axi_aclk,
  (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME axi_interface_RST, POLARITY ACTIVE_LOW, INSERT_VIP 0" *)
  (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 axi_interface_RST RST" *)
    input  wire                              S0_axi_aresetn,
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_interface AWADDR" *)
    input  wire     [C_S0_axi_ADDR_WIDTH-1:0]S0_axi_awaddr,
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_interface AWPROT" *)
    input  wire                         [2:0]S0_axi_awprot,
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_interface AWVALID" *)
    input  wire                              S0_axi_awvalid,
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_interface AWREADY" *)
    output wire                              S0_axi_awready,
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_interface WDATA" *)
    input  wire     [C_S0_axi_DATA_WIDTH-1:0]S0_axi_wdata,
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_interface WSTRB" *)
    input  wire [(C_S0_axi_DATA_WIDTH/8)-1:0]S0_axi_wstrb,
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_interface WVALID" *)
    input  wire                              S0_axi_wvalid,
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_interface WREADY" *)
    output wire                              S0_axi_wready,
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_interface BRESP" *)
    output wire                         [1:0]S0_axi_bresp,
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_interface BVALID" *)
    output wire                              S0_axi_bvalid,
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_interface BREADY" *)
    input  wire                              S0_axi_bready,
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_interface ARADDR" *)
    input  wire     [C_S0_axi_ADDR_WIDTH-1:0]S0_axi_araddr,
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_interface ARPROT" *)
    input  wire                         [2:0]S0_axi_arprot,
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_interface ARVALID" *)
    input  wire                              S0_axi_arvalid,
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_interface ARREADY" *)
    output wire                              S0_axi_arready,
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_interface RDATA" *)
    output wire     [C_S0_axi_DATA_WIDTH-1:0]S0_axi_rdata,
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_interface RRESP" *)
    output wire                         [1:0]S0_axi_rresp,
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_interface RVALID" *)
    output wire                              S0_axi_rvalid,
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_interface RREADY" *)
    input  wire                              S0_axi_rready,

	// Ports of Axi Master Bus Interface M_AXI
	input wire  m_axi_init_axi_txn,
	output wire  m_axi_txn_done,
	output wire  m_axi_error,
	input wire  m_axi_aclk,
	input wire  m_axi_aresetn,
	output wire [C_M_AXI_ID_WIDTH-1 : 0] m_axi_awid,
	output wire [C_M_AXI_ADDR_WIDTH-1 : 0] m_axi_awaddr,
	output wire [7 : 0] m_axi_awlen,
	output wire [2 : 0] m_axi_awsize,
	output wire [1 : 0] m_axi_awburst,
	output wire  m_axi_awlock,
	output wire [3 : 0] m_axi_awcache,
	output wire [2 : 0] m_axi_awprot,
	output wire [3 : 0] m_axi_awqos,
	output wire [C_M_AXI_AWUSER_WIDTH-1 : 0] m_axi_awuser,
	output wire  m_axi_awvalid,
	input wire  m_axi_awready,
	output wire [C_M_AXI_DATA_WIDTH-1 : 0] m_axi_wdata,
	output wire [C_M_AXI_DATA_WIDTH/8-1 : 0] m_axi_wstrb,
	output wire  m_axi_wlast,
	output wire [C_M_AXI_WUSER_WIDTH-1 : 0] m_axi_wuser,
	output wire  m_axi_wvalid,
	input wire  m_axi_wready,
	input wire [C_M_AXI_ID_WIDTH-1 : 0] m_axi_bid,
	input wire [1 : 0] m_axi_bresp,
	input wire [C_M_AXI_BUSER_WIDTH-1 : 0] m_axi_buser,
	input wire  m_axi_bvalid,
	output wire  m_axi_bready,
	output wire [C_M_AXI_ID_WIDTH-1 : 0] m_axi_arid,
	output wire [C_M_AXI_ADDR_WIDTH-1 : 0] m_axi_araddr,
	output wire [7 : 0] m_axi_arlen,
	output wire [2 : 0] m_axi_arsize,
	output wire [1 : 0] m_axi_arburst,
	output wire  m_axi_arlock,
	output wire [3 : 0] m_axi_arcache,
	output wire [2 : 0] m_axi_arprot,
	output wire [3 : 0] m_axi_arqos,
	output wire [C_M_AXI_ARUSER_WIDTH-1 : 0] m_axi_aruser,
	output wire  m_axi_arvalid,
	input wire  m_axi_arready,
	input wire [C_M_AXI_ID_WIDTH-1 : 0] m_axi_rid,
	input wire [C_M_AXI_DATA_WIDTH-1 : 0] m_axi_rdata,
	input wire [1 : 0] m_axi_rresp,
	input wire  m_axi_rlast,
	input wire [C_M_AXI_RUSER_WIDTH-1 : 0] m_axi_ruser,
	input wire  m_axi_rvalid,
	output wire  m_axi_rready

);

	wire read_request;
	wire [31:0] read_address;
	wire [31:0] value_read;
	wire data_available;

	assign m_axi_txn_done = 1'b0;
	assign m_axi_error = 1'b0;

// AXI_slave of Axi Bus Interface axi_S0
AXI_slave # ( 
    .C_S_AXI_DATA_WIDTH(C_S0_axi_DATA_WIDTH),
    .C_S_AXI_ADDR_WIDTH(C_S0_axi_ADDR_WIDTH)
) AXI_slave_inst (
    .clk(clk),
    .ja_p(ja_p),
    .ja_n(ja_n),
    .jb_p(jb_p),
    .jb_n(jb_n),
    .led(led),
    .S_AXI_ACLK(S0_axi_aclk),
    .S_AXI_ARESETN(S0_axi_aresetn),
    .S_AXI_AWADDR(S0_axi_awaddr),
    .S_AXI_AWPROT(S0_axi_awprot),
    .S_AXI_AWVALID(S0_axi_awvalid),
    .S_AXI_AWREADY(S0_axi_awready),
    .S_AXI_WDATA(S0_axi_wdata),
    .S_AXI_WSTRB(S0_axi_wstrb),
    .S_AXI_WVALID(S0_axi_wvalid),
    .S_AXI_WREADY(S0_axi_wready),
    .S_AXI_BRESP(S0_axi_bresp),
    .S_AXI_BVALID(S0_axi_bvalid),
    .S_AXI_BREADY(S0_axi_bready),
    .S_AXI_ARADDR(S0_axi_araddr),
    .S_AXI_ARPROT(S0_axi_arprot),
    .S_AXI_ARVALID(S0_axi_arvalid),
    .S_AXI_ARREADY(S0_axi_arready),
    .S_AXI_RDATA(S0_axi_rdata),
    .S_AXI_RRESP(S0_axi_rresp),
    .S_AXI_RVALID(S0_axi_rvalid),
    .S_AXI_RREADY(S0_axi_rready),
	.read_request(read_request),
	.read_address(read_address),
 	.value_read(value_read),
	.data_available(data_available)
);

// Instantiation of Axi Bus Interface M_AXI
AXI_master # ( 
	.C_M_TARGET_SLAVE_BASE_ADDR(C_M_AXI_TARGET_SLAVE_BASE_ADDR),
	.C_M_AXI_BURST_LEN(C_M_AXI_BURST_LEN),
	.C_M_AXI_ID_WIDTH(C_M_AXI_ID_WIDTH),
	.C_M_AXI_ADDR_WIDTH(C_M_AXI_ADDR_WIDTH),
	.C_M_AXI_DATA_WIDTH(C_M_AXI_DATA_WIDTH),
	.C_M_AXI_AWUSER_WIDTH(C_M_AXI_AWUSER_WIDTH),
	.C_M_AXI_ARUSER_WIDTH(C_M_AXI_ARUSER_WIDTH),
	.C_M_AXI_WUSER_WIDTH(C_M_AXI_WUSER_WIDTH),
	.C_M_AXI_RUSER_WIDTH(C_M_AXI_RUSER_WIDTH),
	.C_M_AXI_BUSER_WIDTH(C_M_AXI_BUSER_WIDTH)
) AXI_master_inst (
	.M_AXI_ACLK(m_axi_aclk),
	.M_AXI_ARESETN(m_axi_aresetn),
	.M_AXI_AWID(m_axi_awid),
	.M_AXI_AWADDR(m_axi_awaddr),
	.M_AXI_AWLEN(m_axi_awlen),
	.M_AXI_AWSIZE(m_axi_awsize),
	.M_AXI_AWBURST(m_axi_awburst),
	.M_AXI_AWLOCK(m_axi_awlock),
	.M_AXI_AWCACHE(m_axi_awcache),
	.M_AXI_AWPROT(m_axi_awprot),
	.M_AXI_AWQOS(m_axi_awqos),
	.M_AXI_AWUSER(m_axi_awuser),
	.M_AXI_AWVALID(m_axi_awvalid),
	.M_AXI_AWREADY(m_axi_awready),
	.M_AXI_WDATA(m_axi_wdata),
	.M_AXI_WSTRB(m_axi_wstrb),
	.M_AXI_WLAST(m_axi_wlast),
	.M_AXI_WUSER(m_axi_wuser),
	.M_AXI_WVALID(m_axi_wvalid),
	.M_AXI_WREADY(m_axi_wready),
	.M_AXI_BID(m_axi_bid),
	.M_AXI_BRESP(m_axi_bresp),
	.M_AXI_BUSER(m_axi_buser),
	.M_AXI_BVALID(m_axi_bvalid),
	.M_AXI_BREADY(m_axi_bready),
	.M_AXI_ARID(m_axi_arid),
	.M_AXI_ARADDR(m_axi_araddr),
	.M_AXI_ARLEN(m_axi_arlen),
	.M_AXI_ARSIZE(m_axi_arsize),
	.M_AXI_ARBURST(m_axi_arburst),
	.M_AXI_ARLOCK(m_axi_arlock),
	.M_AXI_ARCACHE(m_axi_arcache),
	.M_AXI_ARPROT(m_axi_arprot),
	.M_AXI_ARQOS(m_axi_arqos),
	.M_AXI_ARUSER(m_axi_aruser),
	.M_AXI_ARVALID(m_axi_arvalid),
	.M_AXI_ARREADY(m_axi_arready),
	.M_AXI_RID(m_axi_rid),
	.M_AXI_RDATA(m_axi_rdata),
	.M_AXI_RRESP(m_axi_rresp),
	.M_AXI_RLAST(m_axi_rlast),
	.M_AXI_RUSER(m_axi_ruser),
	.M_AXI_RVALID(m_axi_rvalid),
	.M_AXI_RREADY(m_axi_rready),
	.read_request(read_request),
	.read_address(read_address),
	.value_read(value_read),
	.data_available(data_available)
);

endmodule
