module Random16 (clock, resetn, data);

    input clock;
    input resetn;
    
    output reg [15:0] data;
    
    wire feedback = ((data[15] ^ data[13] ) ^ data[12]) ^ data[10];
    
    always @(posedge clock) begin
        if(!resetn)
            data <= 16'b1000000000001101;
        else
            data = {feedback, data[14:0]};
            data[
    end

endmodule;