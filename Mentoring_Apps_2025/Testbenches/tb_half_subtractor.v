`timescale 1ns / 1ps


module tb_half_subtractor();

reg A_tb    ;
reg B_tb    ;     
wire     Difference_tb  ;
wire     Barrow_tb      ;

    half_subtractor DUT (
    .A          (A_tb         ),       
    .B          (B_tb         ),
    .Difference (Difference_tb),
    .Barrow     (Barrow_tb    )
     
    );


integer i ; // reg [31:0] i = X
initial begin
    #100;

    for (i=0 ; i<20 ; i=i+1 ) begin
        #5;
        A_tb   = $random %2 ; 
        B_tb   = $random %2 ; 
        
        #5;
        $display ("%d %d   |   %d   %d " , A_tb , B_tb  , Difference_tb  , Barrow_tb);
    
    end
end
endmodule
