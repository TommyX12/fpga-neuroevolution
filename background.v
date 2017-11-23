`include "constants.h"

`define OP_WIDTH 5 // TODO this must be large enough
`define OP_STANDBY    `OP_WIDTH'd0
`define OP_DRAW_START `OP_WIDTH'd1
`define OP_DRAW_DELAY `OP_WIDTH'd2
`define OP_DRAW_WAIT  `OP_WIDTH'd3

module DrawBackground(
    input start,
    input clock,
    input resetn,
    output reg finished,

    input finished_dp,
    input [`RESULT_WIDTH-1:0] result_dp,
    output reg start_dp,
    output reg [`INSTRUCTION_WIDTH-1:0] instruction_dp
    );
    
    reg [`OP_WIDTH-1:0] cur_state;
    
    // TODO declare any register
    reg [`X_COORD_WIDTH-1:0] x;
    reg [`Y_COORD_WIDTH-1:0] y;
    reg [`COLOUR_WIDTH-1:0] colour; // WE'RE CANADIAN
    reg plot;
    
    always @(posedge clock) begin
        if (!resetn) begin
            cur_state <= `OP_STANDBY;
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
                `OP_STANDBY: begin
                    finished = 1;
                    
                    // usually do nothing
                    
                    if (start) begin
                        // TODO register initialization on start
                        x <= `X_COORD_WIDTH'd0;
                        y <= `Y_COORD_WIDTH'd0;
                        
                        cur_state = cur_state + 1; // this jumps to the next instruction in sequence
                        finished = 0;
                    end
                end
                `OP_DRAW_START: begin
                    // dispatch instruction
                    start_dp = 1;
                    
                    // TODO process and replace with your instruction
                    colour = `COLOUR_WIDTH'b010;
                    plot = 1;
                    instruction_dp = {4'd1, 9'd0, plot, colour, y, x};
                    // it is best to maintain the same instruction until result comes back.
                    
                    cur_state = cur_state + 1;
                end
                `OP_DRAW_DELAY: begin
                    start_dp = 1; // outbound start signals has to maintain 1 in the delay state.
                    
                    cur_state = cur_state + 1;
                end
                `OP_DRAW_WAIT: begin
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
                            cur_state = `OP_STANDBY;
                        end
                        else begin
                            cur_state = `OP_DRAW_START;
                        end
                    end
                end
            endcase
        end
    end

endmodule
