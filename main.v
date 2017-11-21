// Part 2 skeleton

`define OP_CODE_WIDTH 2
`define S_WIDTH 3
`define X_COORD_WIDTH 8
`define Y_COORD_WIDTH 7
`define COLOR_WIDTH   3
`define DELAY_WIDTH   20

`define OP_LOAD       `OP_CODE_WIDTH'd0
`define OP_RUN_SHADER `OP_CODE_WIDTH'd1
`define OP_DRAW       `OP_CODE_WIDTH'd2

`define SCREEN_WIDTH  `X_COORD_WIDTH'd32
`define SCREEN_HEIGHT `Y_COORD_WIDTH'd32

// `define SCREEN_WIDTH  `X_COORD_WIDTH'd160
// `define SCREEN_HEIGHT `Y_COORD_WIDTH'd120

`define BLOCK_WIDTH  `X_COORD_WIDTH'd4
`define BLOCK_HEIGHT `Y_COORD_WIDTH'd4

module main
	(
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
	wire [`COLOR_WIDTH:0] colour;
    wire [`X_COORD_WIDTH:0] x;
    wire [`Y_COORD_WIDTH:0] y;
    wire [`X_COORD_WIDTH:0] x_in;
    wire [`Y_COORD_WIDTH:0] y_in;
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
			/* Signals for the DAC to drive the monitor. */
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
    
    control c(
        .resetn(resetn),
        
        .clock(CLOCK_50),
        .delay(`DELAY_WIDTH'd833333), // 60 fps
        
        .x(x_in),
        .y(y_in)
    );
    
    display d(
        .resetn(resetn),
        
        .clock(CLOCK_50),
        
        .black(0),
        
        .x_in(x_in),
        .y_in(y_in),
        
        .color_in(SW[9:7]),
        
        .x_out(x),
        .y_out(y),
        .color_out(colour),
        .plot_out(writeEn)
    );
    
endmodule

module control(
    input resetn,
    
    input clock,
    input [`DELAY_WIDTH-1:0] delay,
    
    output reg [`X_COORD_WIDTH-1:0] x,
    output reg [`Y_COORD_WIDTH-1:0] y
    );
    
    reg [`X_COORD_WIDTH-1:0] dx;
    reg [`Y_COORD_WIDTH-1:0] dy;
    
    reg [`DELAY_WIDTH-1:0] fps_counter;
    
    always @(posedge clock) begin
        if (!resetn) begin
            x <= `X_COORD_WIDTH'd0;
            y <= `Y_COORD_WIDTH'd0;
            dx <= `X_COORD_WIDTH'd1;
            dy <= `Y_COORD_WIDTH'd1;
            fps_counter <= `DELAY_WIDTH'd1;
        end
        else begin
            if (!fps_counter) begin
                x = x + dx;
                y = y + dy;
                if (x < `X_COORD_WIDTH'd0) begin
                    dx = -dx;
                end
                else if (x >= `SCREEN_WIDTH - `BLOCK_WIDTH) begin
                    dx = -dx;
                end
                if (y < `Y_COORD_WIDTH'd0) begin
                    dy = -dy;
                end
                else if (y >= `SCREEN_HEIGHT - `BLOCK_HEIGHT) begin
                    dy = -dy;
                end
            end
            
            fps_counter = fps_counter + 1;
            if (fps_counter >= delay) begin
                fps_counter = 0;
            end
        end
    end
    
endmodule

module display(
    input resetn,
    
    input clock,
    
    input black,
    
    input [`X_COORD_WIDTH-1:0] x_in,
    input [`Y_COORD_WIDTH-1:0] y_in,
    
    input [`COLOR_WIDTH-1:0] color_in,
    
    output [`X_COORD_WIDTH-1:0] x_out,
    output [`Y_COORD_WIDTH-1:0] y_out,
    output [`COLOR_WIDTH-1:0] color_out,
    output plot_out
    );
    
    wire [`X_COORD_WIDTH-1:0] frag_x;
    wire [`Y_COORD_WIDTH-1:0] frag_y;
    wire [`OP_CODE_WIDTH-1:0] op_code;
    
    display_control dc(
        .resetn(resetn),
        
        .clock(clock),
        
        .frag_x(frag_x),
        .frag_y(frag_y),
        
        .op_code(op_code)
    );
    
    datapath d(
        .clock(clock),
        .resetn(resetn),
        
        .x_in(x_in),
        .y_in(y_in),
        
        .width_in(`BLOCK_WIDTH),
        .height_in(`BLOCK_HEIGHT),
        
        .color_in(color_in),
        
        .black(black),
        
        .frag_x(frag_x),
        .frag_y(frag_y),
        
        .op_code(op_code),
        
        .x_out(x_out),
        .y_out(y_out),
        .color_out(color_out),
        .plot_out(plot_out)
    );
    
endmodule

module display_control(
    input resetn,
    
    input clock,
    
    output reg [`X_COORD_WIDTH-1:0] frag_x,
    output reg [`Y_COORD_WIDTH-1:0] frag_y,
    
    output reg [`OP_CODE_WIDTH-1:0] op_code
    );
    
    reg paused;
    
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

module datapath(
    input clock,
    input resetn,
    
    input [`X_COORD_WIDTH-1:0] x_in,
    input [`Y_COORD_WIDTH-1:0] y_in,
    
    input [`X_COORD_WIDTH-1:0] width_in,
    input [`Y_COORD_WIDTH-1:0] height_in,
    
    input [`COLOR_WIDTH-1:0] color_in,
    
    input black,
    
    input [`X_COORD_WIDTH-1:0] frag_x,
    input [`Y_COORD_WIDTH-1:0] frag_y,
    
    input [`OP_CODE_WIDTH-1:0] op_code,
    
    output reg [`X_COORD_WIDTH-1:0] x_out,
    output reg [`Y_COORD_WIDTH-1:0] y_out,
    output reg [`COLOR_WIDTH-1:0] color_out,
    output reg plot_out
    );
    
    reg [`X_COORD_WIDTH-1:0] x;
    reg [`Y_COORD_WIDTH-1:0] y;
    
    reg [`X_COORD_WIDTH-1:0] width;
    reg [`Y_COORD_WIDTH-1:0] height;
    
    reg [`COLOR_WIDTH-1:0] color;
    
    wire [`COLOR_WIDTH-1:0] shader_color;
    wire shader_plot;
    
    block_shader bs(
        .x_in(x),
        .y_in(y),
        
        .width_in(width),
        .height_in(height),
        
        .color_in(color),
        
        .frag_x(frag_x),
        .frag_y(frag_y),
        
        .color_out(shader_color),
        .plot_out(shader_plot)
    );
    
    always @(posedge clock) begin
        if (!resetn) begin
            x      <= `X_COORD_WIDTH'd0;
            y      <= `Y_COORD_WIDTH'd0;
            width  <= `X_COORD_WIDTH'd0;
            height <= `Y_COORD_WIDTH'd0;
            color  <= `COLOR_WIDTH'd0;
            
            x_out     <= `X_COORD_WIDTH'd0;
            y_out     <= `Y_COORD_WIDTH'd0;
            color_out <= `COLOR_WIDTH'd0;
            plot_out  <= 0;
        end
        else begin
            case (op_code)
                `OP_LOAD: begin
                    x      <= x_in;
                    y      <= y_in;
                    width  <= width_in;
                    height <= height_in;
                    color  <= color_in;
                end
                `OP_RUN_SHADER: begin
                end
                `OP_DRAW: begin
                    x_out <= frag_x;
                    y_out <= frag_y;
                    if (black) begin
                        color_out <= `COLOR_WIDTH'd0;
                        plot_out  <= 1;
                    end
                    else begin
                        color_out <= shader_color;
                        plot_out  <= shader_plot;
                    end
                end
            endcase
        end
    end
    
endmodule

module block_shader (
    input [`X_COORD_WIDTH-1:0] x_in,
    input [`Y_COORD_WIDTH-1:0] y_in,
    
    input [`X_COORD_WIDTH-1:0] width_in,
    input [`Y_COORD_WIDTH-1:0] height_in,
    
    input [`COLOR_WIDTH-1:0] color_in,
    
    input [`X_COORD_WIDTH-1:0] frag_x,
    input [`Y_COORD_WIDTH-1:0] frag_y,
    
    output reg [`COLOR_WIDTH-1:0] color_out,
    output reg plot_out
    );
    
    always @(*) begin
        if (
            frag_x >= x_in
            && frag_x < x_in + width_in
            && frag_y >= y_in
            && frag_y < y_in + height_in
            ) begin
                
            color_out <= color_in;
            plot_out <= 1;
        end
        else begin
            color_out <= `COLOR_WIDTH'd0;
            plot_out <= 1;
        end
    end
    
endmodule
