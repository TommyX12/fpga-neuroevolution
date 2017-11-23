// template for an FSM


`include "constants.h"

`define OP_WIDTH 5
`define OP_LOAD_START `OP_WIDTH'd0
`define OP_LOAD_DELAY `OP_WIDTH'd1
`define OP_LOAD_WAIT `OP_WIDTH'd2

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
            `OP_LOAD_START: begin
                next_state <= `OP_LOAD_DELAY;
            end
            `OP_LOAD_DELAY: begin
                next_state <= `OP_LOAD_WAIT;
            end
            `OP_LOAD_WAIT: begin
                next_state <= `OP_LOAD_START;
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
            // reset stuff
        end
        else begin
            case (cur_state)
                `OP_LOAD_START: begin
                    // do something
                end
                `OP_LOAD_DELAY: begin
                    // do something
                end
                `OP_LOAD_WAIT: begin
                    // do something
                end
            endcase
        end
    end

endmodule
