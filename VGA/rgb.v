`timescale 1ns / 1ps
module rgb #( 
    parameter DATA_WIDTH  = 8              
    )(
    input   wire    [DATA_WIDTH-1:0] rgb_i_data,   
    input   wire    rgb_i_video_on,       
    output  wire    [11:0] rgb_o
);
    assign rgb_o = (rgb_i_video_on) ? {rgb_i_data[7:4], rgb_i_data[7:4], rgb_i_data[7:4]} : 12'b0;
endmodule