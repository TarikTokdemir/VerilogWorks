`timescale 1ns / 1ps

module Mux_2x1(
    input I1 , I0 ,
    input sel ,
    
    output Y
    
    );
    
    assign  Y  = (I0 & ~sel) | (I1 & sel) ; 
    
endmodule
