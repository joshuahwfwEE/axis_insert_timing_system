`timescale 1ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// Xilinx, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) Xilinx shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the
// possibility of the same.
// 
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of Xilinx products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
// 
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES.
//
//////////////////////////////////////////////////////////////////////////////////
// Company: Xilinx
// Engineer: Florent W.
// 
// Create Date: 29/05/2018
// Design Name: AXI4S_to_Vid_Out
// Module Name: tb_AXI4S_to_Vid_Out
// Project Name: Xilinx Video Beginner Series 7
// Target Devices: N/A (Simulation only)
// Tool Versions: 2018.1
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//update:
// Company: e-elements
// Engineer: Joshua Y.
// 
// Create Date: 01/12/2024
// Design Name: AXI4S_to_Vid_Out
// Module Name: tb_AXI4S_to_Vid_Out
// Project Name: insert_video_timing_to_axi_stream
// Target Devices: N/A (Simulation only)
// Tool Versions: 2022.2
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:

//////////////////////////////////////////////////////////////////////////////////

import axi_vip_pkg::*;
import insert_timing_sys_axi_vip_0_0_pkg::*;

module tb_insert_timing_sys(

    );

//////////////////////////////////////////////////////////////////////////////////
// Test Bench Signals
//////////////////////////////////////////////////////////////////////////////////
// Clock and Reset
bit clk_tb = 0, resetn_tb = 0;
// 
xil_axi_resp_t 	resp;

// Signals corresponding to the video output
bit vid_hblank, vid_vblank, vid_hsync, vid_vsync ;
bit [23:0] vid_data;


wire video_out_0_tdata; 
wire video_out_0_tlast; 
wire video_out_0_tready = 1;
wire video_out_0_tuser; 
wire video_out_0_tvalid;

wire vtiming_out_0_active_video;
wire vtiming_out_0_field;       
wire vtiming_out_0_hblank;      
wire vtiming_out_0_hsync;       
wire vtiming_out_0_vblank;      
wire vtiming_out_0_vsync;       

// Test Bench variables
integer counter_width = 0, counter_height = 0;
integer final_width = 0, final_height = 0;


//////////////////////////////////////////////////////////////////////////////////
// Register Space (check PG103 p15 for information)
//////////////////////////////////////////////////////////////////////////////////
//
// TPG register base address - Check the Address Editor Tab in the BD
parameter integer tpg_base_address = 12'h000;
//
// Address of some TPG registers - refer to PG103 for info
    //Control
    parameter integer TPG_CONTROL_REG       = tpg_base_address;
    // active_height
    parameter integer TPG_ACTIVE_H_REG      = tpg_base_address + 8'h10;
    // active_width
    parameter integer TPG_ACTIVE_W_REG      = tpg_base_address + 8'h18;
    // background_pattern_id
    parameter integer TPG_BG_PATTERN_ID_REG = tpg_base_address + 8'h20;
//////////////////////////////////////////////////////////////////////////////////
// VIP Configuration
integer height=1080, width=1920;
//////////////////////////////////////////////////////////////////////////////////


//// Generate the tb clock : 40 MHz    
//always #12.5ns clk_tb = ~clk_tb;
 
// Generate the clock : 74.25 MHz    
always #13.4ns clk_tb = ~clk_tb; 
 
     
// Instanciation of the Unit Under Test (UUT)
insert_timing_sys_wrapper UUT
(
    .clk_0          (clk_tb),
    .resetn_0       (resetn_tb),
    .video_out_0_tdata   (video_out_0_tdata), 
    .video_out_0_tlast   (video_out_0_tlast), 
    .video_out_0_tready  (video_out_0_tready),
    .video_out_0_tuser   (video_out_0_tuser), 
    .video_out_0_tvalid  (video_out_0_tvalid),
    
    .vtiming_out_0_active_video  (vtiming_out_0_active_video),  
    .vtiming_out_0_field         (vtiming_out_0_field),         
    .vtiming_out_0_hblank        (vtiming_out_0_hblank),        
    .vtiming_out_0_hsync         (vtiming_out_0_hsync),         
    .vtiming_out_0_vblank        (vtiming_out_0_vblank),        
    .vtiming_out_0_vsync         (vtiming_out_0_vsync)       

);

//////////////////////////////////////////////////////////////////////////////////
// Main Process. Wait to the first frame to be written and stop the simulation
// The simulation succeed if the size of the output frame is the same as configured
// in the TPG
//////////////////////////////////////////////////////////////////////////////////
//
initial begin

    //Assert the reset
    resetn_tb = 0;
    #340ns
    // Release the reset
    resetn_tb = 1;

    
end
//
//////////////////////////////////////////////////////////////////////////////////
// The following part controls the AXI VIP. 
//It follows the "Usefull Coding Guidelines and Examples" section from PG267
//////////////////////////////////////////////////////////////////////////////////
//
// Declare agent
insert_timing_sys_axi_vip_0_0_mst_t      master_agent;
//
initial begin    

    //Create an agent
    master_agent = new("master vip agent",UUT.insert_timing_sys_i.axi_vip_0.inst.IF);
    
    //Start the agent
    master_agent.start_master();
    
    //Wait for the reset to be released
    wait (resetn_tb == 1'b1);
    
    #200ns
    //Set TPG output size
    master_agent.AXI4LITE_WRITE_BURST(TPG_ACTIVE_H_REG,0,height,resp);
    master_agent.AXI4LITE_WRITE_BURST(TPG_ACTIVE_W_REG,0,width,resp);
    //Set TPG output background ID
    master_agent.AXI4LITE_WRITE_BURST(TPG_BG_PATTERN_ID_REG,0,9,resp);
    
    #200ns
    // Start the TPG in free-running mode    
    master_agent.AXI4LITE_WRITE_BURST(TPG_CONTROL_REG,0,8'h81,resp); 
      
end
//
endmodule
