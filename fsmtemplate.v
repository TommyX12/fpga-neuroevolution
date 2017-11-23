// template for an FSM


`include "constants.h"

`define OP_WIDTH 5 // TODO this must be large enough
`define OP_STANDBY          `OP_WIDTH'd0
`define OP_SUBROUTINE_START `OP_WIDTH'd1
`define OP_SUBROUTINE_DELAY `OP_WIDTH'd2
`define OP_SUBROUTINE_WAIT  `OP_WIDTH'd3

module fsm(
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
                    
                    // usually do nothing
                    
                    if (start) begin
                        // TODO register initialization on start
                        
                        cur_state = cur_state + 1; // this jumps to the next instruction in sequence
                        finished = 0;
                    end
                end
                `OP_SUBROUTINE_START: begin
                    // dispatch instruction
                    start_dp = 1;
                    
                    // TODO process and replace with your instruction
                    instruction_dp = {4'd0, 28'd0};
                    // it is best to maintain the same instruction until result comes back.
                    
                    cur_state = cur_state + 1;
                end
                `OP_SUBROUTINE_DELAY: begin
                    start_dp = 1; // outbound start signals has to maintain 1 in the delay state.
                    
                    cur_state = cur_state + 1;
                end
                `OP_SUBROUTINE_WAIT: begin
                    start_dp = 0; // outbound start signals has to be 0 in the wait state.
                    
                    if (finished_dp) begin
                        // TODO do something with result_dp
                        
                        cur_state = `OP_STANDBY;
                    end
                end
            endcase
        end
    end

endmodule
