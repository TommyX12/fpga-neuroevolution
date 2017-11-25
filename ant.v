`include "constants.h"

// TODO change prefix to be for this file specifically
`define ANTD_OP_WIDTH 5 // TODO this must be large enough
`define ANTD_OP_STANDBY      `ANTD_OP_WIDTH'd0
`define ANTD_OP_LOAD_X_START `ANTD_OP_WIDTH'd1
`define ANTD_OP_LOAD_X_DELAY `ANTD_OP_WIDTH'd2
`define ANTD_OP_LOAD_X_WAIT  `ANTD_OP_WIDTH'd3
`define ANTD_OP_LOAD_Y_START `ANTD_OP_WIDTH'd4
`define ANTD_OP_LOAD_Y_DELAY `ANTD_OP_WIDTH'd5
`define ANTD_OP_LOAD_Y_WAIT  `ANTD_OP_WIDTH'd6
`define ANTD_OP_DRAW_START   `ANTD_OP_WIDTH'd7
`define ANTD_OP_DRAW_DELAY   `ANTD_OP_WIDTH'd8
`define ANTD_OP_DRAW_WAIT    `ANTD_OP_WIDTH'd9

module AntDraw(
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
    
    reg [`ANTD_OP_WIDTH-1:0] cur_state;
    
    // TODO declare any register
    reg [`X_COORD_WIDTH-1:0] x;
    reg [`Y_COORD_WIDTH-1:0] y;
    reg [`COLOUR_WIDTH-1:0] colour; // WE'RE CANADIAN
    reg plot;
    
    always @(posedge clock) begin
        if (!resetn) begin
            cur_state <= `ANTD_OP_STANDBY;
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
                
                `ANTD_OP_STANDBY: begin
                    finished = 1;
                    
                    if (start) begin
                        // TODO register initialization on start
                        
                        cur_state = cur_state + `ANTD_OP_WIDTH'd1;
                        finished = 0;
                    end
                end
                `ANTD_OP_LOAD_X_START: begin
                    start_dp = 1;
                    
                    // TODO process and replace with your instruction
                    instruction_dp = {`ADDR_ANT_X(id), `OPCODE_MEMREAD};
                    
                    cur_state = cur_state + `ANTD_OP_WIDTH'd1;
                end
                `ANTD_OP_LOAD_X_DELAY: begin
                    start_dp = 1;
                    
                    cur_state = cur_state + `ANTD_OP_WIDTH'd1;
                end
                `ANTD_OP_LOAD_X_WAIT: begin
                    start_dp = 0;
                    
                    if (finished_dp) begin
                        // TODO do something with result_dp
                        x = result_dp;
                        
                        cur_state = cur_state + `ANTD_OP_WIDTH'd1;
                    end
                end
                `ANTD_OP_LOAD_Y_START: begin
                    start_dp = 1;
                    
                    // TODO process and replace with your instruction
                    instruction_dp = {`ADDR_ANT_Y(id), `OPCODE_MEMREAD};
                    
                    cur_state = cur_state + `ANTD_OP_WIDTH'd1;
                end
                `ANTD_OP_LOAD_Y_DELAY: begin
                    start_dp = 1;
                    
                    cur_state = cur_state + `ANTD_OP_WIDTH'd1;
                end
                `ANTD_OP_LOAD_Y_WAIT: begin
                    start_dp = 0;
                    
                    if (finished_dp) begin
                        // TODO do something with result_dp
                        y = result_dp;
                        
                        cur_state = cur_state + `ANTD_OP_WIDTH'd1;
                    end
                end
                `ANTD_OP_DRAW_START: begin
                    start_dp = 1;
                    
                    // TODO process and replace with your instruction
                    colour = `COLOUR_ANT;
                    instruction_dp = {1'b1, colour, y, x, `OPCODE_DRAW};
                    
                    cur_state = cur_state + `ANTD_OP_WIDTH'd1;
                end
                `ANTD_OP_DRAW_DELAY: begin
                    start_dp = 1;
                    
                    cur_state = cur_state + `ANTD_OP_WIDTH'd1;
                end
                `ANTD_OP_DRAW_WAIT: begin
                    start_dp = 0;
                    
                    if (finished_dp) begin
                        // TODO do something with result_dp
                        
                        cur_state = `ANTD_OP_STANDBY;
                    end
                end
            endcase
        end
    end

endmodule

// TODO change prefix to be for this file specifically
`define ANTU_OP_WIDTH 5 // TODO this must be large enough
`define ANTU_OP_STANDBY     `ANTU_OP_WIDTH'd0
`define ANTU_OP_UPDATE      `ANTU_OP_WIDTH'd1
`define ANTU_OP_SET_X_START `ANTU_OP_WIDTH'd2
`define ANTU_OP_SET_X_DELAY `ANTU_OP_WIDTH'd3
`define ANTU_OP_SET_X_WAIT  `ANTU_OP_WIDTH'd4
`define ANTU_OP_SET_Y_START `ANTU_OP_WIDTH'd5
`define ANTU_OP_SET_Y_DELAY `ANTU_OP_WIDTH'd6
`define ANTU_OP_SET_Y_WAIT  `ANTU_OP_WIDTH'd7

module AntUpdate(
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
    
    reg [`ANTU_OP_WIDTH-1:0] cur_state;
    
    // TODO declare any register
    reg [`X_COORD_WIDTH-1:0] x;
    reg [`Y_COORD_WIDTH-1:0] y;
    
    reg [`X_COORD_WIDTH-1:0] dx;
    reg [`Y_COORD_WIDTH-1:0] dy;
    
    always @(posedge clock) begin
        if (!resetn) begin
            cur_state <= `ANTU_OP_STANDBY;
            finished <= 1;
            
            start_dp <= 0;
            instruction_dp <= 0;
            
            // TODO reset any register
            x <= `X_COORD_WIDTH'd0;
            y <= `Y_COORD_WIDTH'd0;
            
            dx <= `X_COORD_WIDTH'd1;
            dy <= `Y_COORD_WIDTH'd1;
        end
        else begin
            // TODO make sure everything use blocking assignment
            case (cur_state)
                
                `ANTU_OP_STANDBY: begin
                    finished = 1;
                    
                    if (start) begin
                        // TODO register initialization on start
                        
                        cur_state = cur_state + `ANTU_OP_WIDTH'd1;
                        finished = 0;
                    end
                end
                `ANTU_OP_UPDATE: begin
                    // TODO process and replace with your instruction
                    x = x + dx;
                    y = y + dy;
                    if (x < `X_COORD_WIDTH'd0) begin
                        dx = -dx;
                    end
                    else if (x >= `SCREEN_WIDTH - `BLOCK_WIDTH) begin
                        dx = -dx;
                    end
                    if (y < `Y_COORD_WIDTH'd0) begin
                        dy = -dy;
                    end
                    else if (y >= `SCREEN_HEIGHT - `BLOCK_HEIGHT) begin
                        dy = -dy;
                    end
                    
                    cur_state = cur_state + `ANTU_OP_WIDTH'd1;
                end
                `ANTU_OP_SET_X_START: begin
                    start_dp = 1;
                    
                    // TODO process and replace with your instruction
                    instruction_dp = {x, `ADDR_ANT_X(id), `OPCODE_MEMWRITE};
                    
                    cur_state = cur_state + `ANTU_OP_WIDTH'd1;
                end
                `ANTU_OP_SET_X_DELAY: begin
                    start_dp = 1;
                    
                    cur_state = cur_state + `ANTU_OP_WIDTH'd1;
                end
                `ANTU_OP_SET_X_WAIT: begin
                    start_dp = 0;
                    
                    if (finished_dp) begin
                        // TODO do something with result_dp
                        
                        cur_state = cur_state + `ANTU_OP_WIDTH'd1;
                    end
                end
                `ANTU_OP_SET_Y_START: begin
                    start_dp = 1;
                    
                    // TODO process and replace with your instruction
                    instruction_dp = {y, `ADDR_ANT_Y(id), `OPCODE_MEMWRITE};
                    
                    cur_state = cur_state + `ANTU_OP_WIDTH'd1;
                end
                `ANTU_OP_SET_Y_DELAY: begin
                    start_dp = 1;
                    
                    cur_state = cur_state + `ANTU_OP_WIDTH'd1;
                end
                `ANTU_OP_SET_Y_WAIT: begin
                    start_dp = 0;
                    
                    if (finished_dp) begin
                        // TODO do something with result_dp
                        
                        cur_state = `ANTU_OP_STANDBY;
                    end
                end
            endcase
        end
    end

endmodule
