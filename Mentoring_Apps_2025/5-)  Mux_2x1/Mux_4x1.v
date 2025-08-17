`timescale 1ns / 1ps

module Mux_4x1(
    input wire [3:0] I , 
    input wire [1:0] sel , 
    output wire Y 
    );
    
    wire y0 , y1 ; 
    Mux_2x1 mux0 (
        .I0     (I[0]   ),
        .I1     (I[1]   ),
        .sel    (sel[0] ),
        .Y      (y0)
    );
    
    Mux_2x1 mux1 (
        .I0     (I[2]   ),
        .I1     (I[3]   ),
        .sel    (sel[0] ),
        .Y      (y1     )
    );
    
    Mux_2x1 mux2 (
        .I0     (y0     ),
        .I1     (y1     ),
        .sel    (sel[1] ),
        .Y      (Y      )
    );
    
endmodule
