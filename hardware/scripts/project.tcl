# Copyright (c) 2023 Christopher R. Bowman.  All rights reserved.
# contact: <my initials>@ChrisBowman.com

# TCL script to generate the Vivado project and optionally generate a bitstream file
#

proc print_help {} {
  variable script_file
  puts "\nDescription:"
  puts "Automated generation of project or project and bitstream
  puts "Syntax:"
  puts "$script_file"
  puts "$script_file -tclargs \[--generate_bit <path>\]"
  puts "$script_file -tclargs \[--help\]\n"
  puts "Usage:"
  puts "Name                   Description"
  puts "-------------------------------------------------------------------------"
  puts "\[--project_name <name>\] Create project with the specified name. Default"
  puts "                       name is the name of the project from where this"
  puts "                       script was generated.\n"
  puts "\[--generate_bit\]       Generate the bit stream in addition to creating the project.\n"
  puts "\[--help\]               Print help information for this script"
  puts "-------------------------------------------------------------------------\n"
  exit 0
}

if { $::argc > 0 } {
  for {set i 0} {$i < $::argc} {incr i} {
    set option [string trim [lindex $::argv $i]]
    switch -regexp -- $option {
      "--generate_bit" { set generate_bit 1}
      "--help"         { print_help }
      default {
        if { [regexp {^-} $option] } {
          puts "ERROR: Unknown option '$option' specified, please type '$script_file -tclargs --help' for usage info.\n"
          return 1
        }
      }
    }
  }
}


# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  variable script_folder
  variable design_name

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports
  set DDR [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:ddrx_rtl:1.0 DDR ]

  set FIXED_IO [ create_bd_intf_port -mode Master -vlnv xilinx.com:display_processing_system7:fixedio_rtl:1.0 FIXED_IO ]


  # Create ports
  set clk [ create_bd_port -dir I -type clk -freq_hz 100000000 clk ]

  # Create instance: AXI_master_and_slave_inst, and set properties
  set IP_NAME AXI_master_and_slave
  set IP_INST AXI_master_and_slave_inst
  set myip_0 [ create_bd_cell -type module -reference ${IP_NAME} ${IP_INST} ]

  # Create instance: processing_system7_0, and set properties
  set processing_system7_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:processing_system7:5.5 processing_system7_0 ]
  source ../scripts/ps7prop_dict.tcl
  set_property -dict $ps7prop_dict $processing_system7_0

  # Create instance: ps7_0_axi_periph, and set properties
  #set ps7_0_axi_periph [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 ps7_0_axi_periph ]
  # should be using this instead, when did this become prefered?
  set ps7_0_axi_periph [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 ps7_0_axi_periph ]
  set_property -dict [ list CONFIG.NUM_MI {1} CONFIG.NUM_SI {1} ] $ps7_0_axi_periph

  # Create instance: rst_ps7_0_100M, and set properties
  set rst_ps7_0_100M [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 rst_ps7_0_100M ]

  # Create instance: axi_mem_intercon, and set properties
  set axi_mem_intercon [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 axi_mem_intercon ]
  set_property -dict [ list CONFIG.NUM_MI {1} CONFIG.NUM_SI {1} ] $axi_mem_intercon

# add vip for the master interface
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_vip:1.1 axi_master_vip_0
connect_bd_intf_net [get_bd_intf_pins axi_master_vip_0/S_AXI] [get_bd_intf_pins ${IP_INST}/m_axi]
connect_bd_intf_net [get_bd_intf_pins axi_master_vip_0/M_AXI] -boundary_type upper [get_bd_intf_pins axi_mem_intercon/S00_AXI]
connect_bd_net [get_bd_pins axi_master_vip_0/aresetn] [get_bd_pins rst_ps7_0_100M/peripheral_aresetn]
connect_bd_net [get_bd_pins axi_master_vip_0/aclk] [get_bd_pins processing_system7_0/FCLK_CLK0]

# add vip for the slave interface
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_vip:1.1 axi_slave_vip_0
connect_bd_intf_net -boundary_type upper [get_bd_intf_pins ps7_0_axi_periph/M00_AXI] [get_bd_intf_pins axi_slave_vip_0/S_AXI]
connect_bd_intf_net [get_bd_intf_pins axi_slave_vip_0/M_AXI] [get_bd_intf_pins ${IP_INST}/axi_interface]
connect_bd_net [get_bd_pins axi_slave_vip_0/aclk] [get_bd_pins processing_system7_0/FCLK_CLK0]
connect_bd_net [get_bd_pins axi_slave_vip_0/aresetn] [get_bd_pins rst_ps7_0_100M/peripheral_aresetn]

 # Create interface connections
  connect_bd_intf_net -intf_net processing_system7_0_DDR [get_bd_intf_ports DDR] [get_bd_intf_pins processing_system7_0/DDR]
  connect_bd_intf_net -intf_net processing_system7_0_FIXED_IO [get_bd_intf_ports FIXED_IO] [get_bd_intf_pins processing_system7_0/FIXED_IO]
  connect_bd_intf_net -intf_net processing_system7_0_M_AXI_GP0 [get_bd_intf_pins processing_system7_0/M_AXI_GP0] [get_bd_intf_pins ps7_0_axi_periph/S00_AXI]
  connect_bd_intf_net -intf_net processing_system7_0_S_AXI_HP0 [get_bd_intf_pins processing_system7_0/S_AXI_HP0] [get_bd_intf_pins axi_mem_intercon/M00_AXI]
#   connect_bd_intf_net -intf_net ps7_0_axi_periph_M00_AXI [get_bd_intf_pins ${IP_INST}/axi_interface] [get_bd_intf_pins ps7_0_axi_periph/M00_AXI]
#   connect_bd_intf_net -intf_net axi_mem_intercon_S00_AXI [get_bd_intf_pins ${IP_INST}/m_axi] [get_bd_intf_pins axi_mem_intercon/S00_AXI]

  # Create port connections
  connect_bd_net -net clk_0_1 [get_bd_ports clk] [get_bd_pins /clk]
  connect_bd_net -net processing_system7_0_FCLK_CLK0 [get_bd_pins ${IP_INST}/S0_axi_aclk] [get_bd_pins ${IP_INST}/m_axi_aclk] [get_bd_pins processing_system7_0/FCLK_CLK0] [get_bd_pins processing_system7_0/M_AXI_GP0_ACLK] [get_bd_pins processing_system7_0/S_AXI_HP0_ACLK] [get_bd_pins ps7_0_axi_periph/aclk] [get_bd_pins axi_mem_intercon/aclk] [get_bd_pins rst_ps7_0_100M/slowest_sync_clk]
  connect_bd_net -net processing_system7_0_FCLK_RESET0_N [get_bd_pins processing_system7_0/FCLK_RESET0_N] [get_bd_pins rst_ps7_0_100M/ext_reset_in]
  connect_bd_net -net rst_ps7_0_100M_peripheral_aresetn [get_bd_pins ${IP_INST}/S0_axi_aresetn] [get_bd_pins ${IP_INST}/m_axi_aresetn] [get_bd_pins ps7_0_axi_periph/aresetn] [get_bd_pins axi_mem_intercon/aresetn] [get_bd_pins rst_ps7_0_100M/peripheral_aresetn]

 # Create address segments
  assign_bd_address -offset 0x43C00000 -range 0x00010000 -target_address_space [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs ${IP_INST}/axi_interface/reg0] -force

  create_bd_port -dir O -from 4 -to 1 -type data ja_p
  create_bd_port -dir O -from 4 -to 1 -type data ja_n
  create_bd_port -dir O -from 4 -to 1 -type data jb_p
  create_bd_port -dir O -from 4 -to 1 -type data jb_n
  create_bd_port -dir O -from 3 -to 0 -type data led
  connect_bd_net [get_bd_ports ja_p] [get_bd_pins ${IP_INST}/ja_p]
  connect_bd_net [get_bd_ports ja_n] [get_bd_pins ${IP_INST}/ja_n]
  connect_bd_net [get_bd_ports jb_p] [get_bd_pins ${IP_INST}/jb_p]
  connect_bd_net [get_bd_ports jb_n] [get_bd_pins ${IP_INST}/jb_n]
  connect_bd_net [get_bd_ports led] [get_bd_pins ${IP_INST}/led]
  connect_bd_net [get_bd_ports clk] [get_bd_pins ${IP_INST}/clk]
  validate_bd_design
  save_bd_design

  # Restore current instance
  current_bd_instance $oldCurInst
}

set DESIGN_NAME AXI_master_and_slave
set_param board.repoPaths ../boards
create_project ${DESIGN_NAME} ${DESIGN_NAME} -part xc7z020clg400-1
config_ip_cache -disable_cache
set_property board_part digilentinc.com:arty-z7-20:part0:1.1 [current_project]
import_files -fileset constrs_1 -norecurse ../source/constraints/Arty-Z7-20-Master.xdc
import_files -fileset sources_1 -norecurse "../source/verilog/AXI_master_and_slave.v ../source/verilog/AXI_slave.v ../source/verilog/AXI_master.v"
update_compile_order -fileset sources_1

set BD_NAME ${DESIGN_NAME}_bd
create_bd_design "${BD_NAME}"
create_root_design  ""

make_wrapper -files [get_files ./${DESIGN_NAME}/${DESIGN_NAME}.srcs/sources_1/bd/${BD_NAME}/${BD_NAME}.bd] -top
add_files -norecurse ./${DESIGN_NAME}/${DESIGN_NAME}.gen/sources_1/bd/${BD_NAME}/hdl/${BD_NAME}_wrapper.v
update_compile_order -fileset sources_1

# Disabling source management mode.  This is to allow the top design properties to be set without GUI intervention.
set_property source_mgmt_mode None [current_project]
set_property top ${BD_NAME}_wrapper [current_fileset]
# Re-enabling previously disabled source management mode.
set_property source_mgmt_mode All [current_project]
update_compile_order -fileset sources_1

save_bd_design

# Do a synthesis so that we can add an ila
reset_run synth_1
launch_runs synth_1 -jobs 4
wait_on_run synth_1
open_run synth_1 -name synth_1

# create an ila and add a crap ton of signals to it
# I think this can only be done on a synthesized design.
# the alternative is to add the ila to the RTL and make connections there
create_debug_core u_ila_0 ila
set_property -dict [list \
    C_DATA_DEPTH 1024 \
    C_TRIGIN_EN false \
    C_TRIGOUT_EN false \
    C_ADV_TRIGGER false \
    C_INPUT_PIPE_STAGES 0 \
    C_EN_STRG_QUAL false \
    ALL_PROBE_SAME_MU true \
    ALL_PROBE_SAME_MU_CNT 1 \
] [get_debug_cores u_ila_0]

#connect up the ila clock to the AXI clock
connect_debug_port u_ila_0/clk [get_nets [list AXI_master_and_slave_bd_i/processing_system7_0/FCLK_CLK0 ]]

# add a crap ton of signals to the ila
set probe_list {}
# add a crap ton of signals to the ila
set probe_list {}
set base_path "AXI_master_and_slave_bd_i/AXI_master_and_slave_inst/inst"
set signal_list [list S0_axi_araddr S0_axi_arready S0_axi_arvalid S0_axi_awready S0_axi_awvalid S0_axi_rready S0_axi_rvalid S0_axi_wready S0_axi_wvalid S0_axi_wdata S0_axi_rdata]
foreach signal $signal_list {
	lappend probe_list "${base_path}/${signal}"
}
set base_path "AXI_master_and_slave_bd_i/AXI_master_and_slave_inst/inst/AXI_slave_inst"
set signal_list [list read_request data_available read_address value_read slv_reg0 slv_reg1 slv_reg2 slv_reg3 slv_reg_wren axi_wready S_AXI_WVALID axi_awready S_AXI_AWVALID]
foreach signal $signal_list {
	lappend probe_list "${base_path}/${signal}"
}
set ila u_ila_0
set probe_num 0
foreach net $probe_list {
    puts "attempting to add to ${ila} at probe${probe_num} net: ${net} "
    if {[llength [get_nets -quiet ${net}]] == 1} {
        set width 1
        set variable_list "${net}"
    } elseif {[llength [get_nets -quiet ${net}\[0\]]] != 0} {
        set width [get_property BUS_WIDTH [get_nets -quiet ${net}\[0\]]]
        set variable_list ""
        for {set bit_num 0} {$bit_num < $width} {incr bit_num} {
            append variable_list "${net}\[$bit_num\] "
        }
#         puts "  adding $variable_list"
    } else {
        puts "$net not found, not adding to ila"
        continue
    }
    if {$probe_num != 0} {
        # This is fucking stupid, when the ila is created it has one probe port on it
        # Which means you have to use that and then start creating each extra probe port
        # What's the fucking purpose of that.  Oh and it also doesn't get deleted if
        # you do delete_debug_port ila/probe0.  Whose bright idea was that?
        create_debug_port ${ila} probe
    }
    set_property port_width $width [get_debug_ports ${ila}/probe${probe_num}]
    set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports ${ila}/probe${probe_num}]
    connect_debug_port ${ila}/probe${probe_num} [get_nets $variable_list]
    set probe_num [expr $probe_num + 1]
}

# save and add the ila constraints
file mkdir master_and_slave/master_and_slave.srcs/constrs_1/new
close [ open master_and_slave/master_and_slave.srcs/constrs_1/new/my_new_xdc.xdc w ]
add_files -fileset constrs_1 master_and_slave/master_and_slave.srcs/constrs_1/new/my_new_xdc.xdc
set_property target_constrs_file master_and_slave/master_and_slave.srcs/constrs_1/new/my_new_xdc.xdc [current_fileset -constrset]
save_constraints -force

# default is to just generate the project but if you add -tclargs --generate_bit
# the lanch the implementation step al the way to bitstream generation
if {$generate_bit==1} {
  launch_runs impl_1 -to_step write_bitstream -jobs 4
  wait_on_run impl_1
  set githash [exec git rev-parse --short=8 HEAD]
  puts "git hash: $githash"
#  set_property BITSTREAM.CONFIG.USERID $githash [current_design]
#  set_property BITSTREAM.CONFIG.USR_ACCESS TIMESTAMP [current_design]
#  current_design rtl_1
#  write_bitstream [current_design]
#  puts "bitstream timestamp: [get_property REGISTER.USR_ACCESS [lindex [get_hw_devices 0]]]"
}
start_gui
break
exit

open_hw_manager
connect_hw_server -allow_non_jtag
open_hw_target
current_hw_device [get_hw_devices xc7z020_1]
refresh_hw_device [lindex [get_hw_devices xc7z020_1] 0]
set_property PROBES.FILE {AXI_master_and_slave/AXI_master_and_slave.runs/impl_1/AXI_master_and_slave_bd_wrapper.ltx} [get_hw_devices xc7z020_1]
set_property FULL_PROBES.FILE {/AXI_master_and_slave/AXI_master_and_slave.runs/impl_1/AXI_master_and_slave_bd_wrapper.ltx} [get_hw_devices xc7z020_1]
set_property PROGRAM.FILE {AXI_master_and_slave/AXI_master_and_slave.runs/impl_1/AXI_master_and_slave_bd_wrapper.bit} [get_hw_devices xc7z020_1]
program_hw_devices [get_hw_devices xc7z020_1]
refresh_hw_device [lindex [get_hw_devices xc7z020_1] 0]
display_hw_ila_data [ get_hw_ila_data hw_ila_data_1 -of_objects [get_hw_ilas -of_objects [get_hw_devices xc7z020_1] -filter {CELL_NAME=~"u_ila_0"}]]
set_property TRIGGER_COMPARE_VALUE eq1'bR [get_hw_probes AXI_master_and_slave_bd_i/AXI_master_and_slave_inst/inst/S0_axi_wvalid -of_objects [get_hw_ilas -of_objects [get_hw_devices xc7z020_1] -filter {CELL_NAME=~"u_ila_0"}]]
run_hw_ila [get_hw_ilas -of_objects [get_hw_devices xc7z020_1] -filter {CELL_NAME=~"u_ila_0"}]
