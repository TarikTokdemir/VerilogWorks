`timescale 1ns / 1ps

module partial_fa(
    input   wire a , b , cin ,
    output  wire s , p , g 
    
    );
    
    assign s = a ^ b ^ cin ;
    assign p = a  | b ; 
    assign g = a  & b ; 
    
endmodule
