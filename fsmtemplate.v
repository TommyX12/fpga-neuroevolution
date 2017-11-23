// template for an FSM


`include "constants.h"

`define OP_WIDTH 5
`define OP_STANDBY `OP_WIDTH'd0
`define OP_LOAD_START `OP_WIDTH'd1
`define OP_LOAD_DELAY `OP_WIDTH'd2
`define OP_LOAD_WAIT `OP_WIDTH'd3

module fsm(
    input start,
    input clock,
    input resetn,
    
    output reg finished
    );

    reg [`OP_WIDTH-1:0] next_state;
    reg [`OP_WIDTH-1:0] cur_state;
    
    always @(*) begin
        case (cur_state)
            `OP_STANDBY: begin
                next_state <= start ? `OP_LOAD_START : `OP_STANDBY;
            end
            `OP_LOAD_START: begin
                next_state <= `OP_LOAD_DELAY;
            end
            `OP_LOAD_DELAY: begin
                next_state <= `OP_LOAD_WAIT;
            end
            `OP_LOAD_WAIT: begin
                next_state <= `OP_STANDBY;
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
            finished <= 1;
            
            // reset stuff
        end
        else begin
            // make sure everything use blocking assignment
            case (cur_state)
                `OP_STANDBY: begin
                    finished = 1;
                    
                    // do nothing
                end
                `OP_LOAD_START: begin
                    // do something
                end
                `OP_LOAD_DELAY: begin
                    // do something
                    // note that outbound start signals has to
                    // maintain 1 in the delay state.
                end
                `OP_LOAD_WAIT: begin
                    // do something
                    // note that outbound start signals has to
                    // be 0 in the wait state.
                end
            endcase
            if (start) begin
                finished = 0;
            end
        end
    end

endmodule
