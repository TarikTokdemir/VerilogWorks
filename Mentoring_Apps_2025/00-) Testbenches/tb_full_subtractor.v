`timescale 1ns / 1ps

module tb_full_subtractor( );
reg A_tb            ;         
reg B_tb            ;
reg Bin_tb          ;
wire Difference_tb ;
wire Borrow_tb     ;

    full_subtractor DUT (
        .A          (A_tb          ),
        .B          (B_tb          ),
        .Bin        (Bin_tb         ),
        .Difference (Difference_tb ),
        .Borrow     (Borrow_tb     )   
    );
    
    initial begin
         repeat (10) begin
            #5 ;
            A_tb        = $random %2 ; 
            B_tb        = $random %2 ; 
            Bin_tb      = $random %2 ; 
            
            $monitor ("%d     %d     %d   |||  %d  %d"   ,
                       A_tb , B_tb , Bin_tb    ,Difference_tb  ,  Borrow_tb );
            #5;
         end
    end

endmodule
