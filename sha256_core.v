//////////////////////////////////////////////////////////////////////////////////

// Engineer:  Farooq Niaz 
// 
// Create Date: 11/06/2024 12:18:54 PM
// Design Name: SHA256
// Module Name: sha256_core.v
// Project Name: SHA256
// Target Devices: 
// Tool Versions: 

// Description: This is the internal core with wide interfaces. 
//              Core functions (Ch, Maj, Σ0, Σ1, σ0, σ1) are as per definition given in FIPS 180-4.
//           	It Updates state values for each round.


 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////

//======================================================================
//
// sha256_core.v
// -------------
// Verilog 2001 implementation of the SHA-256 hash function.
// This is the internal core with wide interfaces.
//
//
//======================================================================

//`default_nettype none

module sha256_core	(
					output wire 		found,	
					
					//modified to save io
					input wire [511:0]	message,
					input wire [6:0]	round,
					input wire			rotate_W, 
					input wire [31 : 0] K,
					input wire 			start,
					input wire			round_enable,
					input wire			enable_last_addition,
					input wire			idle_rst,		
					input wire          clk_fast,
					input wire          rst
					);






  //----------------------------------------------------------------
  // Internal constant and parameter definitions.
  //----------------------------------------------------------------

reg [31:0] A = 32'h6a09e667;
reg [31:0] B = 32'hbb67ae85;
reg [31:0] C = 32'h3c6ef372;
reg [31:0] D = 32'ha54ff53a;
reg [31:0] E = 32'h510e527f;
reg [31:0] F = 32'h9b05688c;
reg [31:0] G = 32'h1f83d9ab;
reg [31:0] H = 32'h5be0cd19;
//---------------------------------------------


//--------------------------------------------

reg		[31:0]	W	[0:15]    ;	


// Declare loop variable outside the always block
integer i;
wire [31:0] Wt;


always @(posedge clk_fast) begin
    if (rst) 
        // Reset all elements of W to 0
        for (i = 0; i < 16; i = i + 1) 
		begin
            W[i] <= 0;
        end
	else if (rotate_W == 1)
		begin
			// Shift values in W
			for (i = 0; i < 15; i = i + 1) 
			begin
				W[i] <= W[i + 1];
			end
			W[15] <= Wt;
		end
	else if (start) 
			begin
				W[15] <= message[511:480];
				W[14] <= message[479:448];
				W[13] <= message[447:416];
				W[12] <= message[415:384];
				W[11] <= message[383:352];
				W[10] <= message[351:320];
				W[9] <= message[319:288];
				W[8] <= message[287:256];
				W[7] <= message[255:224];
				W[6] <= message[223:192];
				W[5] <= message[191:160];
				W[4] <= message[159:128];
				W[3] <= message[127:96];
				W[2] <= message[95:64];
				W[1] <= message[63:32];
				W[0] <= message[31:0];
			end
	
end
//--------------	-------------------------------

// Helper functions for ROTR (circular right rotate) and SHR (right shift)
		function [31:0] ROTR(input [31:0] x, input integer n);
			ROTR = (x >> n) | (x << (32 - n));
		endfunction
		
		function [31:0] SHR(input [31:0] x, input integer n);
			SHR = x >> n;
		endfunction


// Calculate σ⁰ and σ¹ based on given formulas
wire [31:0] sigma_0 = ROTR(W[1], 7)		^ ROTR(W[1], 18) ^ SHR(W[1], 3);
wire [31:0] sigma_1 = ROTR(W[14], 17)	^ ROTR(W[14], 19) ^ SHR(W[14], 10);

// Calculate W(i) using the given formula
reg [31:0] W_H = 0;
wire [31:0] W0_sigma0 = W[0] + sigma_0;
wire [31:0] W9_sigma1 = W[9] + sigma_1;

assign Wt = W0_sigma0 + W9_sigma1;


always@(posedge clk_fast)
		if (round_enable ==0)
			W_H <= W[0]+H;
		else
			W_H <= W[0]+G;
	
	
	
wire [31:0] Choice				= (E & F) ^ (~E & G);		//Choice Function "Ch"
wire [31:0] Summation1			= ROTR(E , 6) ^ ROTR(E , 11) ^ ROTR(E , 25);		
wire [31:0] Majority			= (A & B)^ (A & C) ^ (B & C);
wire [31:0] Summation0			= ROTR(A , 2) ^ ROTR(A , 13) ^ ROTR(A , 22);

wire [31:0] Choice_Summation1	= Choice + Summation1 ;			
wire [31:0] Majority_Summation0 = Majority + Summation0;					
wire [31:0] K_Ch_Summation1 = K + Choice_Summation1 ;



wire [31:0] K_Ch_Summation1_W_H = K_Ch_Summation1 + W_H;

always@ (posedge clk_fast)
	if (idle_rst)
	begin
		A <= 32'h6a09e667;
		B <= 32'hbb67ae85;
		C <= 32'h3c6ef372;
		D <= 32'ha54ff53a;
		E <= 32'h510e527f;
		F <= 32'h9b05688c;
		G <= 32'h1f83d9ab;
		H <= 32'h5be0cd19;
	end
	else if (round_enable)
	begin
		A <= K_Ch_Summation1_W_H + Majority_Summation0;
		B <= A;
		C <= B;
		D <= C;
		E <= D + K_Ch_Summation1_W_H;
		F <= E;
		G <= F;
		H <= G;
	end
	else if (enable_last_addition)
	begin
		A <= A + 32'h6a09e667;
		B <= B + 32'hbb67ae85;
		C <= C + 32'h3c6ef372;
		D <= D + 32'ha54ff53a;
		E <= E + 32'h510e527f;
		F <= F + 32'h9b05688c;
		G <= G + 32'h1f83d9ab;
		H <= H + 32'h5be0cd19;
	end

assign found = ((H == 32'h6a09e667) && (round == 6'd64)) ? 1 : 0 ;

endmodule	