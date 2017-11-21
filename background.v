`define SCREEN_WIDTH  `X_COORD_WIDTH'd160
`define SCREEN_HEIGHT `Y_COORD_WIDTH'd120

module draw_background(
	input start,
	input clock,
	output drawing,
	output x,
	output y,
	output colour,	// WE'RE CANADIAN
	output plot
	);
	
    always @(posedge clock) begin
        if (!resetn) begin
            frag_x <= `X_COORD_WIDTH'b0;
            frag_y <= `Y_COORD_WIDTH'b0;
            
            paused <= 0;
            
            op_code <= `OP_LOAD;
        end
        else begin
            if (paused) begin
                op_code <= `OP_LOAD;
                paused <= 0;
            end
            else if (op_code == `OP_LOAD) begin
                frag_x <= `X_COORD_WIDTH'b0;
                frag_y <= `Y_COORD_WIDTH'b0;
                
                op_code <= `OP_RUN_SHADER;
            end
            else if (op_code == `OP_RUN_SHADER) begin
                op_code <= `OP_DRAW;
                if (frag_x == `SCREEN_WIDTH - 1) begin
                    frag_x <= `X_COORD_WIDTH'b0;
                    if (frag_y == `SCREEN_HEIGHT - 1) begin
                        frag_y <= `Y_COORD_WIDTH'b0;
                        paused <= 1;
                    end
                    else begin
                        frag_y <= frag_y + 1;
                    end
                end
                else begin
                    frag_x <= frag_x + 1;
                end
            end
            else if (op_code == `OP_DRAW) begin
                op_code <= `OP_RUN_SHADER;
            end
        end
    end

endmodule
