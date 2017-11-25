`include "constants.h"

// TODO change prefix to be for this file specifically
// TODO for cur_state += 1 to work, this must also reflect the real execution order
`define FOODD_OP_WIDTH 5 // TODO this must be large enough
`define FOODD_OP_STANDBY      `FOODD_OP_WIDTH'd0
`define FOODD_OP_LOAD_X_START `FOODD_OP_WIDTH'd1
`define FOODD_OP_LOAD_X_DELAY `FOODD_OP_WIDTH'd2
`define FOODD_OP_LOAD_X_WAIT  `FOODD_OP_WIDTH'd3
`define FOODD_OP_LOAD_Y_START `FOODD_OP_WIDTH'd4
`define FOODD_OP_LOAD_Y_DELAY `FOODD_OP_WIDTH'd5
`define FOODD_OP_LOAD_Y_WAIT  `FOODD_OP_WIDTH'd6
`define FOODD_OP_DRAW_START   `FOODD_OP_WIDTH'd7
`define FOODD_OP_DRAW_DELAY   `FOODD_OP_WIDTH'd8
`define FOODD_OP_DRAW_WAIT    `FOODD_OP_WIDTH'd9

// TODO change to your module name.
module FoodDraw(
    input clock,
    input resetn,
    input start,
    output reg finished,
    
    input [`MEM_ADDR_WIDTH-1:0] id,
    
    input finished_dp,
    input [`RESULT_WIDTH-1:0] result_dp,
    output reg start_dp,
    output reg [`INSTRUCTION_WIDTH-1:0] instruction_dp
    );
    
    reg [`FOODD_OP_WIDTH-1:0] cur_state;
    
    // TODO declare any register
    reg [`X_COORD_WIDTH-1:0] x;
    reg [`Y_COORD_WIDTH-1:0] y;
    reg [`COLOUR_WIDTH-1:0] colour; // WE'RE CANADIAN
    reg plot;
    
    always @(posedge clock) begin
        if (!resetn) begin
            cur_state <= `FOODD_OP_STANDBY;
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
                
                `FOODD_OP_STANDBY: begin
                    finished = 1;
                    
                    if (start) begin
                        // TODO register initialization on start
                        
                        cur_state = cur_state + `FOODD_OP_WIDTH'd1;
                        finished = 0;
                    end
                end
                `FOODD_OP_LOAD_X_START: begin
                    start_dp = 1;
                    
                    // TODO process and replace with your instruction
                    instruction_dp = {`ADDR_FOOD_X(id), `OPCODE_MEMREAD};
                    
                    cur_state = cur_state + `FOODD_OP_WIDTH'd1;
                end
                `FOODD_OP_LOAD_X_DELAY: begin
                    start_dp = 1;
                    
                    cur_state = cur_state + `FOODD_OP_WIDTH'd1;
                end
                `FOODD_OP_LOAD_X_WAIT: begin
                    start_dp = 0;
                    
                    if (finished_dp) begin
                        // TODO do something with result_dp
                        x = result_dp;
                        
                        cur_state = cur_state + `FOODD_OP_WIDTH'd1;
                    end
                end
                `FOODD_OP_LOAD_Y_START: begin
                    start_dp = 1;
                    
                    // TODO process and replace with your instruction
                    instruction_dp = {`ADDR_FOOD_Y(id), `OPCODE_MEMREAD};
                    
                    cur_state = cur_state + `FOODD_OP_WIDTH'd1;
                end
                `FOODD_OP_LOAD_Y_DELAY: begin
                    start_dp = 1;
                    
                    cur_state = cur_state + `FOODD_OP_WIDTH'd1;
                end
                `FOODD_OP_LOAD_Y_WAIT: begin
                    start_dp = 0;
                    
                    if (finished_dp) begin
                        // TODO do something with result_dp
                        y = result_dp;
                        
                        cur_state = cur_state + `FOODD_OP_WIDTH'd1;
                    end
                end
                `FOODD_OP_DRAW_START: begin
                    start_dp = 1;
                    
                    // TODO process and replace with your instruction
                    colour = `COLOUR_FOOD;
                    instruction_dp = {1'b1, colour, y, x, `OPCODE_DRAW};
                    
                    cur_state = cur_state + `FOODD_OP_WIDTH'd1;
                end
                `FOODD_OP_DRAW_DELAY: begin
                    start_dp = 1;
                    
                    cur_state = cur_state + `FOODD_OP_WIDTH'd1;
                end
                `FOODD_OP_DRAW_WAIT: begin
                    start_dp = 0;
                    
                    if (finished_dp) begin
                        // TODO do something with result_dp
                        
                        cur_state = `FOODD_OP_STANDBY;
                    end
                end
            endcase
        end
    end

endmodule
