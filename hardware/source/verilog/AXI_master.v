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
// Module Name: AXI_master
// Project Name: AXI_master_and_slave
// Target Devices: xc7z020clg400-1
// Tool Versions: 2020.2
//
// Description: project to drive a seven segment display
// from a memory mapped AXI lite interface.  See project
// documentation for more information
// 
// Dependencies: 
// 
//////////////////////////////////////////////////////////////////////////////////

`timescale 1 ns / 1 ps

module AXI_master #	(
		// Users to add parameters here

		// User parameters ends
		// Do not modify the parameters beyond this line

		// Base address of targeted slave
		parameter C_M_TARGET_SLAVE_BASE_ADDR	= 32'h40000000,
		// Burst Length. Supports 1, 2, 4, 8, 16, 32, 64, 128, 256 burst lengths
		parameter integer C_M_AXI_BURST_LEN	= 16,
		// Thread ID Width
		parameter integer C_M_AXI_ID_WIDTH	= 1,
		// Width of Address Bus
		parameter integer C_M_AXI_ADDR_WIDTH	= 32,
		// Width of Data Bus
		parameter integer C_M_AXI_DATA_WIDTH	= 32,
		// Width of User Write Address Bus
		parameter integer C_M_AXI_AWUSER_WIDTH	= 0,
		// Width of User Read Address Bus
		parameter integer C_M_AXI_ARUSER_WIDTH	= 0,
		// Width of User Write Data Bus
		parameter integer C_M_AXI_WUSER_WIDTH	= 0,
		// Width of User Read Data Bus
		parameter integer C_M_AXI_RUSER_WIDTH	= 0,
		// Width of User Response Bus
		parameter integer C_M_AXI_BUSER_WIDTH	= 0
	)
	(
		// Global Clock Signal.
		input wire  M_AXI_ACLK,
		// Global Reset Singal. This Signal is Active Low
		input wire  M_AXI_ARESETN,
		// Master Interface Write Address ID
		output wire [C_M_AXI_ID_WIDTH-1 : 0] M_AXI_AWID,
		// Master Interface Write Address
		output wire [C_M_AXI_ADDR_WIDTH-1 : 0] M_AXI_AWADDR,
		// Burst length. The burst length gives the exact number of transfers in a burst
		output wire [7 : 0] M_AXI_AWLEN,
		// Burst size. This signal indicates the size of each transfer in the burst
		output wire [2 : 0] M_AXI_AWSIZE,
		// Burst type. The burst type and the size information, 
    // determine how the address for each transfer within the burst is calculated.
		output wire [1 : 0] M_AXI_AWBURST,
		// Lock type. Provides additional information about the
    // atomic characteristics of the transfer.
		output wire  M_AXI_AWLOCK,
		// Memory type. This signal indicates how transactions
    // are required to progress through a system.
		output wire [3 : 0] M_AXI_AWCACHE,
		// Protection type. This signal indicates the privilege
    // and security level of the transaction, and whether
    // the transaction is a data access or an instruction access.
		output wire [2 : 0] M_AXI_AWPROT,
		// Quality of Service, QoS identifier sent for each write transaction.
		output wire [3 : 0] M_AXI_AWQOS,
		// Optional User-defined signal in the write address channel.
		output wire [C_M_AXI_AWUSER_WIDTH-1 : 0] M_AXI_AWUSER,
		// Write address valid. This signal indicates that
    // the channel is signaling valid write address and control information.
		output wire  M_AXI_AWVALID,
		// Write address ready. This signal indicates that
    // the slave is ready to accept an address and associated control signals
		input wire  M_AXI_AWREADY,
		// Master Interface Write Data.
		output wire [C_M_AXI_DATA_WIDTH-1 : 0] M_AXI_WDATA,
		// Write strobes. This signal indicates which byte
    // lanes hold valid data. There is one write strobe
    // bit for each eight bits of the write data bus.
		output wire [C_M_AXI_DATA_WIDTH/8-1 : 0] M_AXI_WSTRB,
		// Write last. This signal indicates the last transfer in a write burst.
		output wire  M_AXI_WLAST,
		// Optional User-defined signal in the write data channel.
		output wire [C_M_AXI_WUSER_WIDTH-1 : 0] M_AXI_WUSER,
		// Write valid. This signal indicates that valid write
    // data and strobes are available
		output wire  M_AXI_WVALID,
		// Write ready. This signal indicates that the slave
    // can accept the write data.
		input wire  M_AXI_WREADY,
		// Master Interface Write Response.
		input wire [C_M_AXI_ID_WIDTH-1 : 0] M_AXI_BID,
		// Write response. This signal indicates the status of the write transaction.
		input wire [1 : 0] M_AXI_BRESP,
		// Optional User-defined signal in the write response channel
		input wire [C_M_AXI_BUSER_WIDTH-1 : 0] M_AXI_BUSER,
		// Write response valid. This signal indicates that the
    // channel is signaling a valid write response.
		input wire  M_AXI_BVALID,
		// Response ready. This signal indicates that the master
    // can accept a write response.
		output wire  M_AXI_BREADY,
		// Master Interface Read Address.
		output wire [C_M_AXI_ID_WIDTH-1 : 0] M_AXI_ARID,
		// Read address. This signal indicates the initial
    // address of a read burst transaction.
		output wire [C_M_AXI_ADDR_WIDTH-1 : 0] M_AXI_ARADDR,
		// Burst length. The burst length gives the exact number of transfers in a burst
		output wire [7 : 0] M_AXI_ARLEN,
		// Burst size. This signal indicates the size of each transfer in the burst
		output wire [2 : 0] M_AXI_ARSIZE,
		// Burst type. The burst type and the size information, 
    // determine how the address for each transfer within the burst is calculated.
		output wire [1 : 0] M_AXI_ARBURST,
		// Lock type. Provides additional information about the
    // atomic characteristics of the transfer.
		output wire  M_AXI_ARLOCK,
		// Memory type. This signal indicates how transactions
    // are required to progress through a system.
		output wire [3 : 0] M_AXI_ARCACHE,
		// Protection type. This signal indicates the privilege
    // and security level of the transaction, and whether
    // the transaction is a data access or an instruction access.
		output wire [2 : 0] M_AXI_ARPROT,
		// Quality of Service, QoS identifier sent for each read transaction
		output wire [3 : 0] M_AXI_ARQOS,
		// Optional User-defined signal in the read address channel.
		output wire [C_M_AXI_ARUSER_WIDTH-1 : 0] M_AXI_ARUSER,
		// Write address valid. This signal indicates that
    // the channel is signaling valid read address and control information
		output wire  M_AXI_ARVALID,
		// Read address ready. This signal indicates that
    // the slave is ready to accept an address and associated control signals
		input wire  M_AXI_ARREADY,
		// Read ID tag. This signal is the identification tag
    // for the read data group of signals generated by the slave.
		input wire [C_M_AXI_ID_WIDTH-1 : 0] M_AXI_RID,
		// Master Read Data
		input wire [C_M_AXI_DATA_WIDTH-1 : 0] M_AXI_RDATA,
		// Read response. This signal indicates the status of the read transfer
		input wire [1 : 0] M_AXI_RRESP,
		// Read last. This signal indicates the last transfer in a read burst
		input wire  M_AXI_RLAST,
		// Optional User-defined signal in the read address channel.
		input wire [C_M_AXI_RUSER_WIDTH-1 : 0] M_AXI_RUSER,
		// Read valid. This signal indicates that the channel
    // is signaling the required read data.
		input wire  M_AXI_RVALID,
		// Read ready. This signal indicates that the master can
    // accept the read data and response information.
		output wire  M_AXI_RREADY,
		
		(* mark_debug = "true", keep = "true" *)input wire read_request,
		(* mark_debug = "true", keep = "true" *)input wire [31:0] read_address,
		(* mark_debug = "true", keep = "true" *)output reg [31:0] value_read,
		(* mark_debug = "true", keep = "true" *)output wire data_available
	);


	// AXI4 signals
	//AXI4 internal temp signals
	(* mark_debug = "true", keep = "true" *)reg [C_M_AXI_ADDR_WIDTH-1 : 0] 	axi_awaddr;
	(* mark_debug = "true", keep = "true" *)reg  	axi_awvalid;
	(* mark_debug = "true", keep = "true" *)reg [C_M_AXI_DATA_WIDTH-1 : 0] 	axi_wdata;
	(* mark_debug = "true", keep = "true" *)reg  	axi_wlast;
	(* mark_debug = "true", keep = "true" *)reg  	axi_wvalid;
	(* mark_debug = "true", keep = "true" *)reg  	axi_bready;
	(* mark_debug = "true", keep = "true" *)reg [C_M_AXI_ADDR_WIDTH-1 : 0] 	axi_araddr;
	(* mark_debug = "true", keep = "true" *)reg  	axi_arvalid;
	(* mark_debug = "true", keep = "true" *)reg  	axi_rready;


	// I/O Connections assignments

	//I/O Connections. Write Address (AW)
	assign M_AXI_AWID	 = 'b0;
	assign M_AXI_AWADDR	 = 'b0;			// No writes so tie off write address
	assign M_AXI_AWLEN	 = 'b0;			// No writes so tie off
	assign M_AXI_AWSIZE	 = 'b0;			// No writes so tie off
	//INCR burst type is usually used, except for keyhole bursts
	assign M_AXI_AWBURST = 2'b01;
	assign M_AXI_AWLOCK	 = 1'b0;
	//Update value to 4'b0011 if coherent accesses to be used via the Zynq ACP port. Not Allocated, Modifiable, not Bufferable. Not Bufferable since this example is meant to test memory, not intermediate cache. 
	assign M_AXI_AWCACHE = 4'b0010;
	assign M_AXI_AWPROT	 = 3'h0;
	assign M_AXI_AWQOS	 = 4'h0;
	assign M_AXI_AWUSER	 = 'b1;
	assign M_AXI_AWVALID = 1'b0;		// Not doing any writing so write address is never valid
	//Write Data(W)
	assign M_AXI_WDATA	 = 'b0;			// No writes so tie off
	//All bursts are complete and aligned in this example
	assign M_AXI_WSTRB	 = {(C_M_AXI_DATA_WIDTH/8){1'b1}};
	assign M_AXI_WLAST	 = 1'b0;		// Not doing any writing
	assign M_AXI_WUSER	 = 'b0;
	assign M_AXI_WVALID	 = 1'b0;		// Not doing any writing so write data is never valid
	//Write Response (B)
	assign M_AXI_BREADY	 = 1'b0;		// Not doing any writing
	//Read Address (AR)
	assign M_AXI_ARID	 = 'b0;			// Just doing a single read and waiting for response so contant id
	assign M_AXI_ARADDR	 = axi_araddr;
	//Burst LENgth is number of transaction beats, minus 1
	assign M_AXI_ARLEN	 = 'b0;			// REVIEW THIS
	//Size should be C_M_AXI_DATA_WIDTH, in 2^n bytes, otherwise narrow bursts are used
	assign M_AXI_ARSIZE	 = 'b0;			// REVIEW THIS
	//INCR burst type is usually used, except for keyhole bursts
	assign M_AXI_ARBURST = 2'b01;
	assign M_AXI_ARLOCK	 = 1'b0;
	//Update value to 4'b0011 if coherent accesses to be used via the Zynq ACP port. Not Allocated, Modifiable, not Bufferable. Not Bufferable since this example is meant to test memory, not intermediate cache. 
	assign M_AXI_ARCACHE = 4'b0010;
	assign M_AXI_ARPROT	 = 3'h0;
	assign M_AXI_ARQOS	 = 4'h0;
	assign M_AXI_ARUSER	 = 'b1;
	//Read and Read Response (R)
	assign M_AXI_RREADY	= axi_rready;

	always @(posedge M_AXI_ACLK)                        
	  begin                                             
		if (M_AXI_ARESETN == 0)                                  
		  begin                                                                                    
			axi_araddr <= 'b0;                               
		  end                                                                                      
		else                        
		  begin                        
			axi_araddr <= read_address;                               
		  end
	  end
		                  
	always @(posedge M_AXI_ACLK)                        
	  begin                                             
		if (M_AXI_ARESETN == 0)                                  
		  begin                                                                                    
			axi_arvalid <= 1'b0;                               
		  end                                                                                      
		else                        
		  begin                        
			axi_arvalid <= read_request || (axi_arvalid && !M_AXI_ARREADY);                               
		  end
	  end

	always @(posedge M_AXI_ACLK)                        
	  begin                                             
	    if (M_AXI_ARESETN == 0)                                  
	      begin                                                                                    
	        axi_rready <= 1'b0;
	      end                                                                                      
	    else                        
	      begin                        
			axi_rready <= M_AXI_RVALID;	// Ack every valid cycle as we always receive data                  
		  end
	  end
	  
	assign data_available = (M_AXI_RVALID && axi_rready);
	always @(posedge M_AXI_ACLK)                        
	  begin                                             
		if (M_AXI_ARESETN == 0)                                  
		  begin                                                                                    
			value_read <= 'b0;                               
		  end                                                                                      
		else                        
		  begin                        
			value_read <= 'b0;                               
     		if (data_available)                                  
	      	  begin                                                                                    
		    	value_read <= M_AXI_RDATA;                               
		      end                                                                                      
		    else                        
	      	  begin                                                                                    
		    	value_read <= value_read;                               
		      end                                                                                      
		  end
	  end
// ila ila_0 (.clk(M_AXI_ACLK));

	endmodule
