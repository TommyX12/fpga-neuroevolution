
`include "constants.h"


module NeuralNet(
    input_data,
    weights,
    output_data
    );
    
    parameter data_width = `NN_DATA_WIDTH;
    parameter input_size = `NN_INPUT_SIZE;
    parameter hidden_size = `NN_HIDDEN_SIZE;
    parameter output_size = `NN_OUTPUT_SIZE;
    
    input [data_width * input_size - 1 : 0] input_data;
    input [data_width * (`NN_GET_WEIGHTS_SIZE(input_size, hidden_size, output_size)) - 1 : 0] weights;
    output [data_width * output_size - 1 : 0] output_data;
    
    wire [data_width * hidden_size - 1 : 0] hidden_output;
    
    Neuron #(
        .data_width(data_width),
        .input_size(input_size)
    )
    hidden_layer[hidden_size - 1 : 0] 
    (
        .input_data(input_data),
        .weights(weights[data_width * (`NN_GET_WEIGHTS_SIZE_1(input_size, hidden_size, output_size)) - 1 : 0]),
        .output_data(hidden_output)
    );
    
    Neuron #(
        .data_width(data_width),
        .input_size(hidden_size)
    )
    output_layer[output_size - 1 : 0] 
    (
        .input_data(hidden_output),
        .weights(weights[data_width * (`NN_GET_WEIGHTS_SIZE(input_size, hidden_size, output_size)) - 1 : data_width * (`NN_GET_WEIGHTS_SIZE_1(input_size, hidden_size, output_size))]),
        .output_data(output_data)
    );
    
endmodule


module Neuron(
    input_data,
    weights,
    output_data
    );
    
    parameter data_width = `NN_DATA_WIDTH;
    parameter input_size;
    
    input [data_width * input_size - 1 : 0] input_data;
    input [data_width * (input_size + 1) - 1 : 0] weights;
    output [data_width - 1 : 0] output_data;
    
    wire [data_width * input_size - 1 : 0] product;
    wire [data_width * input_size - 1 : 0] sum;
    genvar i;
    generate
        for (i = 0; i < input_size; i = i + 1) begin : gen_product
            assign product[data_width * i +: data_width] =
                (
                    {{(`NN_DATA_WIDTH){1'd0}}, input_data[data_width * i +: data_width]}
                    *
                    {{(`NN_DATA_WIDTH){1'd0}}, weights[data_width * i +: data_width]}
                )
                >> (`NN_DATA_WIDTH / 2);
        end
    endgenerate
    
    assign sum[data_width - 1 : 0] = product[data_width - 1 : 0];
    generate
        for (i = 1; i < input_size; i = i + 1) begin : gen_sum
            assign sum[data_width * i +: data_width] =
                product[data_width * i +: data_width]
                +
                sum[data_width * (i - 1) +: data_width];
        end
    endgenerate
    
    assign output_data = sum[data_width * input_size - 1 : data_width * (input_size - 1)]
        >= weights[data_width * input_size +: data_width] ? 
        (`NN_DATA_WIDTH'd1 << (`NN_DATA_WIDTH / 2)) : `NN_DATA_WIDTH'd0;
    
endmodule
