`include "constants.h"

// TODO change prefix to be for this file specifically
`define BG_OP_WIDTH 5 // TODO this must be large enough
`define BG_OP_STANDBY     `BG_OP_WIDTH'd0
`define BG_OP_DEBUG_START `BG_OP_WIDTH'd1
`define BG_OP_DEBUG_DELAY `BG_OP_WIDTH'd2
`define BG_OP_DEBUG_WAIT  `BG_OP_WIDTH'd3
`define BG_OP_DRAW_START  `BG_OP_WIDTH'd4
`define BG_OP_DRAW_DELAY  `BG_OP_WIDTH'd5
`define BG_OP_DRAW_WAIT   `BG_OP_WIDTH'd6

module DrawBackground(
    input start,
    input clock,
    input resetn,
    output reg finished,
    
    input [5:0] debug,
    input [`NN_DATA_WIDTH * (`NN_WEIGHTS_SIZE) - 1 : 0] neural_net_weights,

    input finished_dp,
    input [`RESULT_WIDTH-1:0] result_dp,
    output reg start_dp,
    output reg [`INSTRUCTION_WIDTH-1:0] instruction_dp
    );
    
    reg [`BG_OP_WIDTH-1:0] cur_state;
    
    // TODO declare any register
    reg [`X_COORD_WIDTH-1:0] x;
    reg [`Y_COORD_WIDTH-1:0] y;
    reg [`COLOUR_WIDTH-1:0] colour; // WE'RE CANADIAN
    reg plot;
    reg [31:0] counter;
    
    always @(posedge clock) begin
        if (!resetn) begin
            cur_state <= `BG_OP_STANDBY;
            finished <= 1;
            
            start_dp <= 0;
            instruction_dp <= 0;
            
            // TODO reset any register
            x <= `X_COORD_WIDTH'd0;
            y <= `Y_COORD_WIDTH'd0;
            colour <= `COLOUR_WIDTH'd0;
            plot <= 0;
        end
        else begin
            // TODO make sure everything use blocking assignment
            case (cur_state)
                `BG_OP_STANDBY: begin
                    finished = 1;
                    
                    // usually do nothing
                    
                    if (start) begin
                        // TODO register initialization on start
                        x = `X_COORD_WIDTH'd0;
                        y = `Y_COORD_WIDTH'd0;
                        counter = 0;
                        
                        // cur_state = cur_state + `BG_OP_WIDTH'd1; // this jumps to the next instruction in sequence
                        cur_state = `BG_OP_DRAW_START;
                        finished = 0;
                    end
                end
                // `BG_OP_DEBUG_START: begin
                    // // dispatch instruction
                    // start_dp = 1;
                    
                    // // TODO process and replace with your instruction
                    // instruction_dp = {debug, `OPCODE_NNMEMREAD};
                    // // it is best to maintain the same instruction until result comes back.
                    
                    // cur_state = cur_state + `BG_OP_WIDTH'd1;
                // end
                // `BG_OP_DEBUG_DELAY: begin
                    // start_dp = 1; // outbound start signals has to maintain 1 in the delay state.
                    
                    // cur_state = cur_state + `BG_OP_WIDTH'd1;
                // end
                // `BG_OP_DEBUG_WAIT: begin
                    // start_dp = 0; // outbound start signals has to be 0 in the wait state.
                    
                    // if (finished_dp) begin
                        // // TODO do something with result_dp
                        // counter = counter + 1;
                        
                        // cur_state = cur_state + `BG_OP_WIDTH'd1;
                    // end
                // end
                `BG_OP_DRAW_START: begin
                    // dispatch instruction
                    start_dp = 1;
                    
                    // TODO process and replace with your instruction
                    // colour = neural_net_weights[counter] ? 3'b001 : `COLOUR_BG;
                    colour = `COLOUR_BG;
                    plot = 1;
                    instruction_dp = {plot, colour, y, x, `OPCODE_DRAW};
                    // it is best to maintain the same instruction until result comes back.
                    
                    cur_state = cur_state + `BG_OP_WIDTH'd1;
                end
                `BG_OP_DRAW_DELAY: begin
                    start_dp = 1; // outbound start signals has to maintain 1 in the delay state.
                    
                    cur_state = cur_state + `BG_OP_WIDTH'd1;
                end
                `BG_OP_DRAW_WAIT: begin
                    start_dp = 0; // outbound start signals has to be 0 in the wait state.
                    
                    if (finished_dp) begin
                        // TODO do something with result_dp
                        if (x == `SCREEN_WIDTH - 1) begin
                            x = `X_COORD_WIDTH'd0;
                            if (y == `SCREEN_HEIGHT - 1) begin
                                y = `Y_COORD_WIDTH'd0;
                                finished = 1;
                            end
                            else begin
                                y = y + 1;
                            end
                        end
                        else begin
                            x = x + 1;
                        end
                        
                        if (finished) begin
                            cur_state = `BG_OP_STANDBY;
                        end
                        else begin
                            // cur_state = `BG_OP_DEBUG_START;
                            cur_state = `BG_OP_DRAW_START;
                        end
                    end
                end
            endcase
        end
    end

endmodule
