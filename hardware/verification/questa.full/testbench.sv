// AXI_master_and_slave_bd_wrapper.AXI_master_and_slave_bd_i.axi_master_vip_0.inst
// AXI_master_and_slave_bd_wrapper.AXI_master_and_slave_bd_i.axi_slave_vip_0.inst
// axi_vip_1_exdes_basic_mst_passive__pt_mst__slv_comb

// XilinxAXIVIP: Found at Path: AXI_master_and_slave_bd_wrapper.AXI_master_and_slave_bd_i.axi_master_vip_0.inst
// XilinxAXIVIP: Found at Path: AXI_master_and_slave_bd_wrapper.AXI_master_and_slave_bd_i.axi_slave_vip_0.inst
// XilinxCLKVIP: Found at Path: AXI_master_and_slave_bd_wrapper.AXI_master_and_slave_bd_i.clk_vip_0.inst
// XilinxRSTVIP: Found at Path: AXI_master_and_slave_bd_wrapper.AXI_master_and_slave_bd_i.rst_vip_0.inst

`timescale 1ns / 1ps

import axi_vip_pkg::*;
import AXI_master_and_slave_bd_axi_master_vip_0_0_pkg::*;
import AXI_master_and_slave_bd_axi_slave_vip_0_0_pkg::*;

module testbench (
);
     
  // event to stop simulation
//   event                                   done_event;
//     typedef enum {
//     EXDES_PASSTHROUGH,
//     EXDES_PASSTHROUGH_MASTER,
//     EXDES_PASSTHROUGH_SLAVE
//   } exdes_passthrough_t;
// 
//   exdes_passthrough_t                     exdes_state = EXDES_PASSTHROUGH;

  xil_axi_uint							  error_cnt =0;

  // Comparison count to check how many comparsion happened
  xil_axi_uint                            comparison_cnt = 0;


  //----------------------------------------------------------------------------------------------
  // the following monitor transactions are for simple scoreboards doing self-checking
  // two Scoreboards are built here
  // one scoreboard checks master vip against passthrough VIP (scoreboard 1)
  // the other one checks passthrough VIP against slave VIP (scoreboard 2)
  // monitor transaction from master VIP
  //----------------------------------------------------------------------------------------------
  axi_monitor_transaction                 mst_monitor_transaction;
  // monitor transaction queue for master VIP 
  axi_monitor_transaction                 master_moniter_transaction_queue[$];
  // size of master_moniter_transaction_queue
  xil_axi_uint                           master_moniter_transaction_queue_size =0;
  //scoreboard transaction from master monitor transaction queue
  axi_monitor_transaction                 mst_scb_transaction;
  // monitor transaction for slave VIP
  axi_monitor_transaction                 slv_monitor_transaction;
  // monitor transaction queue for slave VIP
  axi_monitor_transaction                 slave_moniter_transaction_queue[$];
  // size of slave_moniter_transaction_queue
  xil_axi_uint                            slave_moniter_transaction_queue_size =0;
  // scoreboard transaction from slave monitor transaction queue
  axi_monitor_transaction                 slv_scb_transaction;

 // axi_vip_1_mst_stimulus mst();
 //axi_vip_1_passthrough_mem_stimulus slv();

  // instantiate board design
  AXI_master_and_slave_bd_wrapper DUT();

// `include "axi_vip_1_passthrough_mst_stimulus.svh"
// `include "axi_vip_1_slv_basic_stimulus.svh"

// Setup the reset VIP and force it to perform a reset
	initial begin
		testbench.DUT.AXI_master_and_slave_bd_i.rst_vip_0.inst.IF.set_initial_reset(1'b1);
		testbench.DUT.AXI_master_and_slave_bd_i.rst_vip_0.inst.set_master_mode();
		#10ns;
		testbench.DUT.AXI_master_and_slave_bd_i.rst_vip_0.inst.IF.assert_reset();
		#10ns;
		testbench.DUT.AXI_master_and_slave_bd_i.rst_vip_0.inst.IF.deassert_reset();
	end

// Setup the clock VIP and force it to drive the clock
	initial begin
		testbench.DUT.AXI_master_and_slave_bd_i.clk_vip_0.inst.set_master_mode();
		testbench.DUT.AXI_master_and_slave_bd_i.clk_vip_0.inst.IF.start_clock();
		testbench.DUT.AXI_master_and_slave_bd_i.clk_vip_0.inst.IF.set_initial_value(1'b0);
		testbench.DUT.AXI_master_and_slave_bd_i.clk_vip_0.inst.IF.set_clk_frq(.user_frequency(100_000_000));
	end

// Setup the VIP That test the slave interface and the master interface
	AXI_master_and_slave_bd_axi_master_vip_0_0_passthrough_mem_t AXI_master_and_slave_bd_axi_master_vip_0_0_passthrough;
	AXI_master_and_slave_bd_axi_slave_vip_0_0_passthrough_t AXI_master_and_slave_bd_axi_slave_vip_0_0_passthrough;
    axi_transaction transaction;
	initial begin : START_AXI_master_and_slave_bd_axi_slave_vip_0_0_SLAVE
		testbench.DUT.AXI_master_and_slave_bd_i.axi_master_vip_0.inst.set_slave_mode();
		testbench.DUT.AXI_master_and_slave_bd_i.axi_slave_vip_0.inst.set_master_mode();
		testbench.DUT.AXI_master_and_slave_bd_i.axi_master_vip_0.inst.set_fatal_to_warnings();
		testbench.DUT.AXI_master_and_slave_bd_i.axi_slave_vip_0.inst.set_fatal_to_warnings();
		AXI_master_and_slave_bd_axi_master_vip_0_0_passthrough = new("Master interface test", testbench.DUT.AXI_master_and_slave_bd_i.axi_master_vip_0.inst.IF);
		AXI_master_and_slave_bd_axi_slave_vip_0_0_passthrough = new("Slave interface test", testbench.DUT.AXI_master_and_slave_bd_i.axi_slave_vip_0.inst.IF);
		AXI_master_and_slave_bd_axi_master_vip_0_0_passthrough.start_slave(); //passthrough in run time slave mode
		AXI_master_and_slave_bd_axi_slave_vip_0_0_passthrough.start_master(); //passthrough in run time master mode
	#50ns;
		transaction = AXI_master_and_slave_bd_axi_slave_vip_0_0_passthrough.mst_rd_driver.create_transaction("read");
		transaction.set_read_cmd(32'hEC00_0000, XIL_AXI_BURST_TYPE_INCR, 0, 4, XIL_AXI_SIZE_4BYTE);
		transaction.set_prot(0);
		transaction.set_lock(XIL_AXI_ALOCK_NOLOCK);
		transaction.set_cache(0);
		transaction.set_region(0);
		transaction.set_qos(0);
		transaction.set_data_block(32'hffffffff);
		AXI_master_and_slave_bd_axi_slave_vip_0_0_passthrough.mst_rd_driver.send(transaction);   
		transaction.set_read_cmd(32'hEC00_0004, XIL_AXI_BURST_TYPE_INCR, 0, 4, XIL_AXI_SIZE_4BYTE);
		AXI_master_and_slave_bd_axi_slave_vip_0_0_passthrough.mst_rd_driver.send(transaction);   
		transaction.set_read_cmd(32'hEC00_0008, XIL_AXI_BURST_TYPE_INCR, 0, 4, XIL_AXI_SIZE_4BYTE);
		AXI_master_and_slave_bd_axi_slave_vip_0_0_passthrough.mst_rd_driver.send(transaction);   
		transaction.set_read_cmd(32'hEC00_000c, XIL_AXI_BURST_TYPE_INCR, 0, 4, XIL_AXI_SIZE_4BYTE);
		AXI_master_and_slave_bd_axi_slave_vip_0_0_passthrough.mst_rd_driver.send(transaction);   
	#400ns;
		transaction = AXI_master_and_slave_bd_axi_slave_vip_0_0_passthrough.mst_wr_driver.create_transaction("write");
		transaction.set_write_cmd(32'hEC00_0000, XIL_AXI_BURST_TYPE_INCR, 0, 4, XIL_AXI_SIZE_4BYTE);
		transaction.set_prot(0);
		transaction.set_lock(XIL_AXI_ALOCK_NOLOCK);
		transaction.set_cache(0);
		transaction.set_region(0);
		transaction.set_qos(0);
		transaction.set_data_block(32'hffffffff);
		AXI_master_and_slave_bd_axi_slave_vip_0_0_passthrough.mst_wr_driver.send(transaction);   
		transaction.set_write_cmd(32'hEC00_0004, XIL_AXI_BURST_TYPE_INCR, 0, 4, XIL_AXI_SIZE_4BYTE);
		AXI_master_and_slave_bd_axi_slave_vip_0_0_passthrough.mst_wr_driver.send(transaction);   
		transaction.set_write_cmd(32'hEC00_0008, XIL_AXI_BURST_TYPE_INCR, 0, 4, XIL_AXI_SIZE_4BYTE);
		AXI_master_and_slave_bd_axi_slave_vip_0_0_passthrough.mst_wr_driver.send(transaction);   
		transaction.set_write_cmd(32'hEC00_000C, XIL_AXI_BURST_TYPE_INCR, 0, 4, XIL_AXI_SIZE_4BYTE);
		AXI_master_and_slave_bd_axi_slave_vip_0_0_passthrough.mst_wr_driver.send(transaction);   
	end
	
/*
  // master vip monitors all the transaction from interface and put then into transaction queue
  initial begin
    #2ps;
    mst_monitor_transaction = new("master monitor transaction");
    forever begin
      testbench.DUT.AXI_master_and_slave_bd_i.axi_master_vip_0.inst.mst_agent.monitor.item_collected_port.get(mst_monitor_transaction);
      if(mst_monitor_transaction.get_cmd_type() == XIL_AXI_READ) begin
        monitor_rd_data_method_one(mst_monitor_transaction);
        monitor_rd_data_method_two(mst_monitor_transaction);
      end  
      master_moniter_transaction_queue.push_back(mst_monitor_transaction);
      master_moniter_transaction_queue_size++;
    end  
  end 

  // slave vip monitors all the transaction from interface and put then into transaction queue 
  initial begin
    #2ps;
    slv_monitor_transaction = new("slave monitor transaction");
    forever begin
      testbench.DUT.AXI_master_and_slave_bd_i.axi_slave_vip_0.inst.slv_agent.monitor.item_collected_port.get(slv_monitor_transaction);
      slave_moniter_transaction_queue.push_back(slv_monitor_transaction);
      slave_moniter_transaction_queue_size++;
    end
  end

  
  //----------------------------------------------------------------------------------------------
  //comparing transaction from passthrough in master side with transaction from Slave VIP 
  // if they are match, SUCCESS. else, ERROR
  //----------------------------------------------------------------------------------------------
  initial begin
    forever begin
      wait (slave_moniter_transaction_queue_size>0 ) begin
        slv_scb_transaction = slave_moniter_transaction_queue.pop_front;
        slave_moniter_transaction_queue_size--;
        wait( master_moniter_transaction_queue_size>0) begin
          mst_scb_transaction = master_moniter_transaction_queue.pop_front;
          master_moniter_transaction_queue_size--;
          if (slv_scb_transaction.do_compare(mst_scb_transaction) == 0) begin
            $display("ERROR: Slave VIP against Master VIP scoreboard Compare failed");
            error_cnt++;
          end else begin
            $display("SUCCESS: Slave VIP against Master VIP scoreboard Compare passed");
          end
          comparison_cnt++;
        end  
      end 
    end
  end
 
*/
  
  /*************************************************************************************************
  * There are two ways to get read data. One is to get it through the read driver of master agent
  * (refer to driver_rd_data_method_one, driver_rd_data_method_two in *mst_stimulus.sv file).
  * The other is to get it through the monitor of VIP,  
  * To get data from monitor, follow these steps:
  * step 1: Get the monitor transaction from item_collected_port. In this example, it comes 
  * from the master agent.
  * step 2: If the cmd type is XIL_AXI_READ in the monitor transaction, use get_data_beat,
  * get_data_block to get the read data. If the cmd type is XIL_AXI_WRITE in the monitor
  * transaction, use get_data_beat, get_data_block to get the write data
  *
  * monitor_rd_data_method_one shows how to get a data beat through the monitor transaction
  * monitor_rd_data_method_two shows how to get data block through the monitor transaction
  * 
  * Note on API get_data_beat: get_data_beat returns the value of the specified beat. 
  * It always returns 1024 bits. It aligns the signification bytes to the lower 
  * bytes and sets the unused bytes to zeros.
  * This is NOT always the RDATA representation. If the data width is 32-bit and 
  * the transaction is sub-size burst (1B in this example), only the last byte of 
  * get_data_beat is valid. This is very different from the Physical Bus.
  * 
  * get_data_bit             Physical Bus
  * 1024  ...      0          32        0
  * ----------------         -----------
  * |             X|         |        X| 
  * |             X|         |      X  |
  * |             X|         |    X    |
  * |             X|         | X       |
  * ----------------         -----------
  *
  * Note on API get_data_block: get_data_block returns 4K bytes of the payload
  * for the transaction. This is NOT always the RDATA representation.  If the data
  * width is 32-bit and the transaction is sub-size burst (1B in this example),
  * It will align the signification bytes to the lower bytes and set the unused 
  * bytes to zeros.
  *
  *   get_data_block          Physical Bus
  *   32    ...      0         32        0
  * 0 ----------------         -----------
  *   | D   C   B   A|         |        A| 
  *   | 0   0   0   0|         |      B  |
  *   | 0   0   0   0|         |    C    |
  *   | 0   0   0   0|         | D       |
  *   | 0   0   0   0|         -----------
  *   | 0   0   0   0|         
  * 1k----------------         
  *
  *************************************************************************************************/
  task monitor_rd_data_method_one(input axi_monitor_transaction updated);
    xil_axi_data_beat                       mtestDataBeat[];
    mtestDataBeat = new[updated.get_len()+1];
    for( xil_axi_uint beat=0; beat<updated.get_len()+1; beat++) begin
      mtestDataBeat[beat] = updated.get_data_beat(beat);
    //  $display(" Read data from Monitor: beat index %d, Data beat %h", beat, mtestDataBeat[beat]);
    end  
  endtask

  task monitor_rd_data_method_two(input axi_monitor_transaction updated);
    bit[8*4096-1:0]                         data_block;
    data_block = updated.get_data_block();
  //  $display(" Read data from Monitor: Block Data %h ", data_block);
  endtask


endmodule
