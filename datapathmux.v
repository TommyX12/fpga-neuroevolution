
`include "constants.h"

module DatapathMux4(
    
    input clock,
    input resetn,
    
    input [`INSTRUCTION_WIDTH*4-1:0] instruction,
    input [4-1:0] start,
    output reg [`RESULT_WIDTH*4-1:0] result,
    output reg [4-1:0] finished,
    
    output reg [`INSTRUCTION_WIDTH-1:0] instruction_dp,
    output reg start_dp,
    input [`RESULT_WIDTH-1:0] result_dp,
    input finished_dp
    
    );
    
    reg [4-1:0] mask;
    
    wire 
    
    always @(posedge clock) begin
        if (!resetn) begin
            result <= `RESULT_WIDTH*4'd0;
            finished <= ~(4'd0);
            mask <= ~(4'd0);
        end
        else begin
            finished = finished & ~(start);
        end
    end
    
endmodule
