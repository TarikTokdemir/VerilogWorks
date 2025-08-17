`timescale 1ns / 1ps

module full_subtractor(
    input A , B , Bin ,
    output Difference , Borrow 
    
    );
    
    wire d1 , b1 , b2 ;
    
    half_subtractor hs0 (
        .A          (A),
        .B          (B),
        .Difference (d1),
        .Borrow     (b1)
    );
    
    half_subtractor hs1 (
        .A          (d1),
        .B          (Bin),
        .Difference (Difference),
        .Borrow     (b2)
    );
    
    assign   Borrow = b1 | b2  ;
    
endmodule
