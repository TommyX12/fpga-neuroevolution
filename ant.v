`include "constants.h"

`define ANT_COLOUR 3'b010;

`define OP_WIDTH 5
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
    
    reg [`OP_WIDTH-1:0] next_state;
    reg [`OP_WIDTH-1:0] cur_state;
    
    reg draw_finished;
    
    always @(*) begin
        case (cur_state)
            `OP_STANDBY: begin
                next_state <= start ? `OP_LOAD_START : `OP_STANDBY;
            end
            `OP_LOAD_X_START: begin
                next_state <= `OP_LOAD_X_DELAY;
            end
            `OP_LOAD_X_DELAY: begin
                next_state <= `OP_LOAD_X_WAIT;
            end
            `OP_LOAD_X_WAIT: begin
                next_state <= finished_dp : `OP_LOAD_Y_START : `OP_LOAD_X_WAIT;
            end
            `OP_LOAD_Y_START: begin
                next_state <= `OP_LOAD_Y_DELAY;
            end
            `OP_LOAD_Y_DELAY: begin
                next_state <= `OP_LOAD_Y_WAIT;
            end
            `OP_LOAD_Y_WAIT: begin
                next_state <= finished_dp : `OP_DRAW_START : `OP_LOAD_Y_WAIT;
            end
            `OP_DRAW_START: begin
                next_state <= `OP_DRAW_DELAY;
            end
            `OP_DRAW_DELAY: begin
                next_state <= `OP_DRAW_WAIT;
            end
            `OP_DRAW_WAIT: begin
                if (finished_dp) begin
                    next_state <= draw_finished : `OP_STANDBY : `OP_DRAW_START;
                end
                else begin
                    next_state <= next_state;
                end
            end
        endcase
    end
    
    always @(posedge clock) begin
        if (!resetn) begin
            cur_state <= `OP_LOAD_START;
        end
        cur_state <= next_state;
    end
    
    always @(posedge clock) begin
        if (!resetn) begin
            finished <= 0;
            start_dp <= 0;
            instruction_dp <= 0;
            
            draw_finished <= 0;
        end
        else begin
            case (cur_state)
                
                `OP_STANDBY: begin
                    finished = 1;
                end
                `OP_LOAD_X_START: begin
                    start_dp = 1;
                    instruction_dp = {4'd2, 12'd0, x_address};
                end
                `OP_LOAD_X_DELAY: begin
                    start_dp = 1;
                end
                `OP_LOAD_X_WAIT: begin
                    start_dp = 0;
                end
                `OP_LOAD_Y_START: begin
                    x = result_dp;
                    
                    start_dp = 1;
                    instruction_dp = {4'd2, 12'd0, y_address};
                end
                `OP_LOAD_Y_DELAY: begin
                    start_dp = 1;
                end
                `OP_LOAD_Y_WAIT: begin
                    start_dp = 0;
                end
                `OP_DRAW_START: begin
                    y = result_dp;
                    
                    start_dp = 1;
                    instruction_dp = {4'd1, 9'd0, 1'b1, 3'b011, y, x};
                end
                `OP_DRAW_DELAY: begin
                    start_dp = 1;
                end
                `OP_DRAW_WAIT: begin
                    start_dp = 0;
                end
            endcase
            if (start) begin
                finished = 0;
            end
        end
    end

endmodule
