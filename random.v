module random_16 (clock, resetn, data);

    input clock;
    input resetn;
    
    output reg [15:0] data;
    
    reg [15:0] data_next;
    
    always @* begin
        data_next[4] = data[4]^data[1];
        data_next[3] = data[3]^data[0];
        data_next[2] = data[2]^data_next[4];
        data_next[1] = data[1]^data_next[3];
        data_next[0] = data[0]^data_next[2];
    end

endmodule;