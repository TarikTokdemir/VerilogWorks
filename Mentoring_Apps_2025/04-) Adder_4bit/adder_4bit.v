`timescale 1ns / 1ps

module adder_4bit(
    
    input wire [3:0] A , B ,
    input wire [0:0] Cin ,
    
    output wire     Cout ,
    output wire [3:0] Sum   
    );
    
    wire c0 , c1 , c2 ; 
    
    full_adder FA0 (
        .a      (A[0]   ),  
        .b      (B[0]   ),
        .cin    (Cin    ),
        .sum    (Sum[0] ),
        .cout   (c0     )
    );
    
    full_adder FA1 (
        .a      (A[1]   ),  
        .b      (B[1]   ),
        .cin    (c0     ),
        .sum    (Sum[1] ),
        .cout   (c1     )
    );
    
    full_adder FA2 (
        .a      (A[2]   ),  
        .b      (B[2]   ),
        .cin    (c1     ),
        .sum    (Sum[2] ),
        .cout   (c2     )
    );
    
    full_adder FA3 (
        .a      (A[3]   ),  
        .b      (B[3]   ),
        .cin    (c2     ),
        .sum    (Sum[3] ),
        .cout   (Cout   )
    );
    
endmodule
