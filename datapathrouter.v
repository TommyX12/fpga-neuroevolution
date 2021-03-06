
`include "constants.h"

`define THREADS_WIDTH 16
// might need to be smaller than 32 or else comparisons in for loop might not work

module DatapathRouter(
    
    clock,
    resetn,
    
    instruction,
    start,
    result,
    finished,
    
    instruction_dp,
    start_dp,
    result_dp,
    finished_dp
    
    );
    
    parameter [`THREADS_WIDTH-1:0] ports;
    
    input clock;
    input resetn;
    
    input [`INSTRUCTION_WIDTH*ports-1:0] instruction;
    input [ports-1:0] start;
    output reg [`RESULT_WIDTH*ports-1:0] result;
    output reg [ports-1:0] finished;
    
    output reg [`INSTRUCTION_WIDTH-1:0] instruction_dp;
    output reg start_dp;
    input [`RESULT_WIDTH-1:0] result_dp;
    input finished_dp;
    
    
    reg [ports-1:0] ptr_mask;
    reg [`THREADS_WIDTH-1:0] ptr;
    reg waiting;
    reg delay;
    
    always @(posedge clock) begin
        if (!resetn) begin
            result <= {(`RESULT_WIDTH*ports){1'd0}};
            finished <= ~{(ports){1'd0}};
            
            instruction_dp = `INSTRUCTION_WIDTH'd0;
            start_dp = 0;
            
            ptr_mask = {{(ports - 1){1'd0}}, 1'd1};
            ptr <= `THREADS_WIDTH'd0;
            waiting <= 0;
            delay <= 0;
        end
        else begin
            finished = finished & ~(start);
            if (delay) begin
                delay = 0;
                start_dp = 1;
                waiting = 1;
            end
            else if (waiting) begin
                start_dp = 0;
                if (finished_dp) begin
                    // receive
                    // result = result & ~(
                        // ({{(`RESULT_WIDTH*(ports - 1)){1'd0}}, {(`RESULT_WIDTH){1'd1}}})
                        // << (`RESULT_WIDTH * ptr)
                    // );
                    // result = result | (
                        // (
                        // ({{(`RESULT_WIDTH*(ports - 1)){1'd0}}, {(`RESULT_WIDTH){1'd1}}})
                        // & result_dp
                        // )
                        // << (`RESULT_WIDTH * ptr)
                    // );
                    result[ptr * `RESULT_WIDTH +: `RESULT_WIDTH] = result_dp;
                    finished = finished | ptr_mask;
                    
                    waiting = 0;
                end
            end
            else begin // find new ones to check
                repeat (ports) begin
					if (~(start_dp)) begin
                        if (ptr == ports - `THREADS_WIDTH'd1) begin
                            ptr = `THREADS_WIDTH'd0;
                            ptr_mask = {{(ports - 1){1'd0}}, 1'd1};
                        end
                        else begin
                            ptr = ptr + `THREADS_WIDTH'd1;
                            ptr_mask = ptr_mask << 1;
                        end
                        if (ptr_mask & ~(finished)) begin
                            // send
                            // instruction_dp = (instruction >> (`INSTRUCTION_WIDTH * ptr));
                            instruction_dp = instruction[ptr * `RESULT_WIDTH +: `RESULT_WIDTH];
                            start_dp = 1;
                            
                            delay = 1;
                        end
                    end
                end
            end
        end
    end
    
endmodule
