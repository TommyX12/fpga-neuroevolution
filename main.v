// Part 2 skeleton



`include "constants.h"

`define OP_WIDTH 5
`define OP_DRAW_BACKGROUND_START `OP_WIDTH'd0
`define OP_DRAW_BACKGROUND_DELAY `OP_WIDTH'd1
`define OP_DRAW_BACKGROUND_WAIT  `OP_WIDTH'd2
`define OP_ANT_DRAW_START        `OP_WIDTH'd3
`define OP_ANT_DRAW_DELAY        `OP_WIDTH'd4
`define OP_ANT_DRAW_WAIT         `OP_WIDTH'd5


module main(
        CLOCK_50,						//	On Board 50 MHz
        // Your inputs and outputs here
        KEY,
        SW,
        // The ports below are for the VGA output.  Do not change.
        VGA_CLK,   						//	VGA Clock
        VGA_HS,							//	VGA H_SYNC
        VGA_VS,							//	VGA V_SYNC
        VGA_BLANK_N,						//	VGA BLANK
        VGA_SYNC_N,						//	VGA SYNC
        VGA_R,   						//	VGA Red[9:0]
        VGA_G,	 						//	VGA Green[9:0]
        VGA_B   						//	VGA Blue[9:0]
    );

    input			CLOCK_50;				//	50 MHz
    input   [9:0]   SW;
    input   [3:0]   KEY;

    // Declare your inputs and outputs here
    // Do not change the following outputs
    output			VGA_CLK;   				//	VGA Clock
    output			VGA_HS;					//	VGA H_SYNC
    output			VGA_VS;					//	VGA V_SYNC
    output			VGA_BLANK_N;				//	VGA BLANK
    output			VGA_SYNC_N;				//	VGA SYNC
    output	[9:0]	VGA_R;   				//	VGA Red[9:0]
    output	[9:0]	VGA_G;	 				//	VGA Green[9:0]
    output	[9:0]	VGA_B;   				//	VGA Blue[9:0]
    
    wire resetn;
    assign resetn = KEY[0];
    
    // Create the colour, x, y and writeEn wires that are inputs to the controller.
    wire [`COLOUR_WIDTH:0] colour;
    wire [`X_COORD_WIDTH:0] x;
    wire [`Y_COORD_WIDTH:0] y;
    wire writeEn;

    // Create an Instance of a VGA controller - there can be only one!
    // Define the number of colours as well as the initial background
    // image file (.MIF) for the controller.
    vga_adapter VGA(
            .resetn(resetn),
            .clock(CLOCK_50),
            .colour(colour),
            .x(x),
            .y(y),
            .plot(writeEn),
            // Signals for the DAC to drive the monitor.
            .VGA_R(VGA_R),
            .VGA_G(VGA_G),
            .VGA_B(VGA_B),
            .VGA_HS(VGA_HS),
            .VGA_VS(VGA_VS),
            .VGA_BLANK(VGA_BLANK_N),
            .VGA_SYNC(VGA_SYNC_N),
            .VGA_CLK(VGA_CLK));
        defparam VGA.RESOLUTION = "160x120";
        defparam VGA.MONOCHROME = "FALSE";
        defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
        defparam VGA.BACKGROUND_IMAGE = "black.mif";
            
    // Put your code here. Your code should produce signals x,y,colour and writeEn/plot
    // for the VGA controller, in addition to any other functionality your design may require.
    
    reg draw_background_start;
    wire draw_background_finished;
    
    reg ant_draw_start;
    wire ant_draw_finished;
    
    wire clock;
    assign clock = CLOCK_50;
    
    wire finished_dp;
    wire [`RESULT_WIDTH-1:0] result_dp;
    wire start_dp;
    wire [`INSTRUCTION_WIDTH-1:0] instruction_dp;
    
    wire [`MEM_DATA_WIDTH-1:0] mem_output;
    wire [`MEM_ADDR_WIDTH-1:0] mem_address;
    wire [`MEM_DATA_WIDTH-1:0] mem_data;
    wire mem_write;
    
    localparam ports = 2; // number of subroutines
    
    wire [`INSTRUCTION_WIDTH*ports-1:0] instruction;
    wire [ports-1:0] start;
    wire [`RESULT_WIDTH*ports-1:0] result;
    wire [ports-1:0] finished;
    
    DatapathRouter datapath_router(
        
        .clock(clock),
        .resetn(resetn),
        
        .instruction(instruction),
        .start(start),
        .result(result),
        .finished(finished),
        
        .instruction_dp(instruction_dp),
        .start_dp(start_dp),
        .result_dp(result_dp),
        .finished_dp(finished_dp)
        
        );
        defparam
            datapath_router.ports = 2;
        
    DrawBackground draw_background(
        .start(draw_background_start),
        .clock(clock),
        .resetn(resetn),
        .finished(draw_background_finished),

        .finished_dp(finished[0]),
        .result_dp(result[`RESULT_WIDTH-1:0]),
        .start_dp(start[0]),
        .instruction_dp(instruction[`INSTRUCTION_WIDTH-1:0])
    );
    
    AntDraw ant_draw(
        .clock(clock),
        .resetn(resetn),
        .start(ant_draw_start),
        .finished(ant_draw_finished),
        
        .x_address(16'd5),
        .y_address(16'd10),
        
        .finished_dp(finished[1]),
        .result_dp(result[`RESULT_WIDTH*2-1:`RESULT_WIDTH]),
        .start_dp(start[1]),
        .instruction_dp(instruction[`INSTRUCTION_WIDTH*2-1:`INSTRUCTION_WIDTH])
        );
    
    ram12x16 ram(
        .address(mem_address),
        .clock(clock),
        .data(mem_data),
        .wren(mem_write),
        .q(mem_output)
    );
    
    Datapath datapath(
        .start(start_dp),
        .clock(clock),
        .resetn(resetn),
        .instruction(instruction_dp),
        .result(result_dp),
        
        .x(x),
        .y(y),
        .colour(colour),
        .plot(writeEn),
        .finished(finished_dp),
        
        .mem_output(mem_output),
        .mem_address(mem_address),
        .mem_data(mem_data),
        .mem_write(mem_write)
    );
    
    reg [`OP_WIDTH-1:0] next_state;
    reg [`OP_WIDTH-1:0] cur_state;
    
    always @(*) begin
		  case (cur_state)
				`OP_DRAW_BACKGROUND_START: begin
					 next_state <= `OP_DRAW_BACKGROUND_DELAY;
				end
				`OP_DRAW_BACKGROUND_DELAY: begin
					 next_state <= `OP_DRAW_BACKGROUND_WAIT;
				end
				`OP_DRAW_BACKGROUND_WAIT: begin
					 next_state <= draw_background_finished ? `OP_DRAW_BACKGROUND_START : next_state;
				end
		  endcase
    end
    
    always @(posedge clock) begin
        if (!resetn) begin
            cur_state <= `OP_DRAW_BACKGROUND_START;
        end
        cur_state <= next_state;
    end
    
    always @(posedge clock) begin
        if (!resetn) begin
            draw_background_start = 0;
        end
        else begin
            case (cur_state)
                `OP_DRAW_BACKGROUND_START: begin
                    draw_background_start <= 1;
                end
                `OP_DRAW_BACKGROUND_DELAY: begin
                    draw_background_start <= 1;
                end
                `OP_DRAW_BACKGROUND_WAIT: begin
                    draw_background_start <= 0;
                end
            endcase
        end
    end

endmodule
