module Random16 (clock, resetn, out);

    input clock;
    input resetn;
    
    reg [15:0] data;
    output [15:0] out;
    assign out = {
        data[3:0],
        data[11:4],
        data[15:12]
    };
    
    wire f1 = data[0] ^ data[11];
    wire f2 = data[0] ^ data[13];
    wire f3 = data[0] ^ data[14];
    wire feedback = (((data[15] ^ data[13]) ^ data[12]) ^ data[10]);
    
    always @(posedge clock) begin
        if(!resetn) begin
            data <= data | 16'b1000000000001101;
        end
        else begin
            data = {feedback, data[15:1]};
            data[10] = f1;
            data[11] = f2;
            data[12] = f3;
        end
    end

endmodule
