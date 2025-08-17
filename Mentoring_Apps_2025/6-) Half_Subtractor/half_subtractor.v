`timescale 1ns / 1ps

module half_subtractor(
    input wire A , B ,
    
    output wire Difference,
    output wire Borrow  
    );
    
    assign Difference = A ^ B  ; 
    assign Borrow     = ~A & B ; 
    
endmodule
