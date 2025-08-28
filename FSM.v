`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

// Engineer: Farooq Niaz 
// 
// Create Date: 11/06/2024 12:18:54 PM
// Design Name: SHA256 FSM
// Module Name: FSM
// Project Name: SHA256

// Description: This module implements the finite state machine (FSM) for controlling
//              the SHA256 hash computation process, managing various stages 
//              in the pipeline such as initial state, rotation, and final result.
// 
// Dependencies: Requires `sha256_core` for W_H calculations.
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////

module FSM (
    output reg  [6:0] round = 0,          // Counter for the SHA256 rounds (0-63)
    output reg        digest_valid = 0,   // Indicates when the digest is valid
    output reg        ready = 0,          // Signals that the FSM is ready for a new input
    output reg        round_enable = 0,   // Enables the round counter
    output reg        idle_rst = 0,       // Resets the round counter in idle state
    output reg        rotate_W = 0,       // Enables the W rotation for each round
    output reg        enable_last_addition = 0, // Enables the final addition of H registers
    input wire        start,              // Start signal to begin the hashing process
    input wire        clk_fsm,            // FSM clock signal
    input wire        rst_fsm             // Reset signal for FSM
);

    // ----------STATE MACHINE----------------------
    // Declaring state machine states
    localparam IDLE              = 0;    // Idle state, FSM waits for the start signal
    localparam NOOP              = 1;    // NOOP state for pipeline adjustment
    localparam ROTATE_W_1_to_64  = 2;    // State to perform W rotation for rounds 1 to 64
    localparam LAST_ADDITION_H   = 3;    // State for final addition of H registers
    localparam RESULT            = 4;    // State to indicate final digest is ready

    // State machine registers
    reg [2:0] STATE = IDLE;              // Current state of the FSM
    reg [2:0] NEXT_STATE = IDLE;         // Next state of the FSM

    // FSM sequential logic: Update current state based on clock and reset
    always @(posedge clk_fsm) 
    if (rst_fsm)
        STATE <= IDLE;
    else
        STATE <= NEXT_STATE;

    // FSM combinational logic: Define transitions between states
    always @ (*) 
    begin
        NEXT_STATE <= STATE; // Default next state is current state
        case(STATE)
            IDLE:               if (start)            NEXT_STATE <= NOOP; else NEXT_STATE <= IDLE;
            NOOP:                                      NEXT_STATE <= ROTATE_W_1_to_64;
            ROTATE_W_1_to_64:   if (round == 7'd63)    NEXT_STATE <= LAST_ADDITION_H; else NEXT_STATE <= ROTATE_W_1_to_64;
            LAST_ADDITION_H:                           NEXT_STATE <= RESULT;
            RESULT:                                    ; // Remains in RESULT state until reset
        endcase
    end

    // FSM output logic: Define outputs for each state
    always @ (posedge clk_fsm) 
    begin
        // Reset all control signals at each clock cycle
        digest_valid        <= 0;
        ready               <= 0;
        idle_rst            <= 0;
        round_enable        <= 0;
        rotate_W            <= 0;
        enable_last_addition <= 0;

        // Set specific outputs based on the next state
        case(NEXT_STATE)
            IDLE:               begin round_enable <= 0; ready <= 1; idle_rst <= 1; end
            NOOP:               begin round_enable <= 0; rotate_W <= 1; end
            ROTATE_W_1_to_64:   begin round_enable <= 1; rotate_W <= 1; end
            LAST_ADDITION_H:    enable_last_addition <= 1;
            RESULT:             begin round_enable <= 0; ready <= 1; digest_valid <= 1; end
        endcase
    end

    // -------------------------------------------------
    // Round counter: Counts the rounds from 0 to 63 during ROTATE_W_1_to_64 state
    always @(posedge clk_fsm)
    if (idle_rst)
        round <= 0;                // Reset round counter in IDLE state
    else if (round_enable)
        round <= round + 1;        // Increment round counter during ROTATE_W_1_to_64
    
endmodule