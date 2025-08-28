`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

// Engineer:  Farooq Niaz 
// 
// Create Date: 11/04/2024 11:52:20 PM
// Design Name: 
// Module Name: SHA_TOP
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Top-level module integrating 512 bits input block, Constant memory (K_mem).
//           	and Core function (sha256_core). It provides clean I/O interface 
//              for start/reset/data input and digest output.

// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module SHA_TOP	(
				output wire         ready,
				output wire 		found_all,                    
				output wire         digest_valid,
				input wire          start,
				input wire          clk,
				input wire          rst
				);
//-------------------------------------------------------------------
//Defining total No. of cores
localparam TOTAL_CORES = 2;         
//-------------------------------------------------------------------
wire clk_fast;

assign clk_fast = clk;
//-------------------------------------------------------------------
//FSM Module instatiation
//One FSM control machine will control all the cores

wire [6:0] round;
wire [31:0] K;
wire W_sel;
wire round_enable;
wire idle_rst;
wire rotate_W;
wire enable_last_addition;

FSM	Controller	(
				.round			(round),
				.digest_valid	(digest_valid),
				.ready			(ready),
				.round_enable	(round_enable),
				.idle_rst		(idle_rst),
				.rotate_W		(rotate_W),
				.enable_last_addition	(enable_last_addition),
				
				.start			(start),
				.clk_fsm		(clk_fast),
				.rst_fsm		(rst)

			);

//----------------------------------------------------------------------
wire [TOTAL_CORES-1:0] found; 			    // Array for each instance's 'found' (digest_dummy)

    genvar i;
    generate
        for (i = 0; i < TOTAL_CORES; i = i + 1) begin : gen_sha256_instances
            sha256_core u_sha256 (
                .found			(found[i]),
                .message		({32'h18,{14{32'h0}},32'h61626380}+i),
				.round			(round),
				.rotate_W		(rotate_W),
				.K				(K),	
				.start			(start),
				.round_enable	(round_enable),
				.enable_last_addition(enable_last_addition),
				.idle_rst		(idle_rst),
				.clk_fast		(clk_fast),
                .rst			(rst)
            );
        end
    endgenerate
//---------------------------------------------------------
sha256_k_constants K_values (
							.round(round[5:0]),
							.K(K)
							);

//----------------------------------------------------------
assign found_all = |found & digest_valid;


endmodule
