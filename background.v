`include "constants.h"

module draw_background(
   input start,
   input clock,
   input resetn,
   output reg drawing,
   output reg [`X_COORD_WIDTH-1:0] x,
   output reg [`Y_COORD_WIDTH-1:0] y,
   output reg [`COLOUR_WIDTH-1:0] colour, // WE'RE CANADIAN
   output reg plot,
	output reg finished
   );
	
	reg [`X_COORD_WIDTH-1:0] frag_x;
	reg [`Y_COORD_WIDTH-1:0] frag_y;
	
    always @(posedge clock) begin
        if (!resetn) begin
            frag_x <= `X_COORD_WIDTH'b0;
            frag_y <= `Y_COORD_WIDTH'b0;

				plot <= 0;
				finished <= 0;
        end
        else begin
				// setup registers on the first cycle
            if (finished && start) begin
                frag_x <= `X_COORD_WIDTH'b0;
                frag_y <= `Y_COORD_WIDTH'b0;
					 
					 plot <= 1;
					 finished <= 0;
            end
				// update positions as long as we are not finished drawing
            else if (!finished) begin
                if (frag_x == `SCREEN_WIDTH - 1) begin
                    frag_x <= `X_COORD_WIDTH'b0;
                    if (frag_y == `SCREEN_HEIGHT - 1) begin
                        frag_y <= `Y_COORD_WIDTH'b0;
                        finished <= 1;
                    end
                    else begin
                        frag_y <= frag_y + 1;
                    end
                end
                else begin
                    frag_x <= frag_x + 1;
                end
            end
            else if (finished) begin
                plot <= 0;
            end
        end
    end

endmodule
