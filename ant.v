`include "constants.h"

`define ANT_COLOUR 3'b010;

`define OP_WIDTH 5 // TODO this must be large enough
`define OP_STANDBY      `OP_WIDTH'd0
`define OP_LOAD_X_START `OP_WIDTH'd1
`define OP_LOAD_X_DELAY `OP_WIDTH'd2
`define OP_LOAD_X_WAIT  `OP_WIDTH'd3
`define OP_LOAD_Y_START `OP_WIDTH'd4
`define OP_LOAD_Y_DELAY `OP_WIDTH'd5
`define OP_LOAD_Y_WAIT  `OP_WIDTH'd6
`define OP_DRAW_START   `OP_WIDTH'd7
`define OP_DRAW_DELAY   `OP_WIDTH'd8
`define OP_DRAW_WAIT    `OP_WIDTH'd9

module AntDraw(
    input clock,
    input resetn,
    input start,
    output reg finished,
    
    input [`MEM_ADDR_WIDTH-1:0] x_address,
    input [`MEM_ADDR_WIDTH-1:0] y_address,
    
    input finished_dp,
    input [`RESULT_WIDTH-1:0] result_dp,
    output reg start_dp,
    output reg [`INSTRUCTION_WIDTH-1:0] instruction_dp
    );
    
    reg [`OP_WIDTH-1:0] cur_state;
    
    // TODO declare any register
    
    always @(posedge clock) begin
        if (!resetn) begin
            cur_state <= `OP_STANDBY;
            finished <= 1;
            
            start_dp <= 0;
            instruction_dp <= 0;
            
            // TODO reset any register
        end
        else begin
            // TODO make sure everything use blocking assignment
            case (cur_state)
                
                `OP_STANDBY: begin
                    finished = 1;
                    
                    if (start) begin
                        // TODO register initialization on start
                        
                        cur_state = cur_state + 1;
                        finished = 0;
                    end
                end
                `OP_LOAD_X_START: begin
                    start_dp = 1;
                    
                    // TODO process and replace with your instruction
                    instruction_dp = {4'd2, 12'd0, x_address};
                    
                    cur_state = cur_state + 1;
                end
                `OP_LOAD_X_DELAY: begin
                    start_dp = 1;
                    
                    cur_state = cur_state + 1;
                end
                `OP_LOAD_X_WAIT: begin
                    start_dp = 0;
                    
                    if (finished_dp) begin
                        // TODO do something with result_dp
                        x = result_dp;
                        
                        cur_state = cur_state + 1;
                    end
                end
                `OP_LOAD_Y_START: begin
                    start_dp = 1;
                    
                    // TODO process and replace with your instruction
                    instruction_dp = {4'd2, 12'd0, y_address};
                    
                    cur_state = cur_state + 1;
                end
                `OP_LOAD_Y_DELAY: begin
                    start_dp = 1;
                    
                    cur_state = cur_state + 1;
                end
                `OP_LOAD_Y_WAIT: begin
                    start_dp = 0;
                    
                    if (finished_dp) begin
                        // TODO do something with result_dp
                        y = result_dp;
                        
                        cur_state = cur_state + 1;
                    end
                end
                `OP_DRAW_START: begin
                    start_dp = 1;
                    
                    // TODO process and replace with your instruction
                    instruction_dp = {4'd1, 9'd0, 1'b1, 3'b011, y, x};
                    
                    cur_state = cur_state + 1;
                end
                `OP_DRAW_DELAY: begin
                    start_dp = 1;
                    
                    cur_state = cur_state + 1;
                end
                `OP_DRAW_WAIT: begin
                    start_dp = 0;
                    
                    if (finished_dp) begin
                        // TODO do something with result_dp
                        
                        cur_state = `OP_STANDBY;
                    end
                end
            endcase
        end
    end

endmodule
