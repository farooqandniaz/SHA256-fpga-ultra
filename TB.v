`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

// Engineer:  Farooq Niaz 
// 
// Create Date: 11/06/2024 12:18:54 PM
// Design Name: SHA256
// Module Name: TB.v
// Project Name: SHA256 

// Description:  Drives clock/reset/start signals. Observes output digest and round activity.
 

// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module SHA_TOP_tb;

    // Inputs
    reg start = 0;
    reg clk = 0;
    reg rst = 0;

    // Outputs
    wire ready;
    wire found_all;
    wire digest_valid;

    // Clock period for 100 MHz (10 ns period)
    localparam CLOCK_PERIOD = 10;

    // Instantiate the Unit Under Test (UUT)
    SHA_TOP uut (
        .ready(ready),
        .found_all(found_all),
        .digest_valid(digest_valid),
        .start(start),
        .clk(clk),
        .rst(rst)
    );

    // Clock generation
    always #(CLOCK_PERIOD / 2) clk = ~clk; // Toggle clock every half period (5 ns for 100 MHz)

    // Initial block for stimulus
    initial begin
        // Initialize inputs
        clk = 0;
        rst = 1;
        start = 0;

        // Reset the design
        #20 rst = 0;    // Deassert reset after 20 ns
        #20 rst = 1;    // Assert reset briefly
        #20 rst = 0;    // Deassert reset

        // Apply the start signal
        #40 start = 1;  // Start signal asserted
 //       #20 start = 0;  // Start signal deasserted after 20 ns

        // Wait for the SHA_TOP to finish processing
        wait (digest_valid); // Wait until digest_valid goes high

        // Display the results
        $display("Digest valid: %b, Ready: %b, Found all: %b", digest_valid, ready, found_all);

        // Finish simulation
//        #100 $stop;
    end

endmodule