`timescale 1ns / 1ps

module Square_parametic #( 
parameter  WIDTH = 8 
)( 
input wire [WIDTH-1:0] X, 
output wire [(2*WIDTH)-1:0] Y 

); 

multiplier_parametic #(.WIDTH(WIDTH)) multiplier_inst ( 
    .A (X), 
    .B (X), 
    .P (Y) 
); 
    
    
endmodule