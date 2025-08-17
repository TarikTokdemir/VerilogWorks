`timescale 1ns / 1ps


module tb_full_adder();

reg a_tb    ;  
reg b_tb    ;
reg cin_tb  ;
 
wire sum_tb     ;
wire cout_tb    ;
 

    full_adder full_adder_dut (
        .a     ( a_tb     ),  
        .b     ( b_tb     ),
        .cin   ( cin_tb   ),
        .sum   ( sum_tb   ),
        .cout  ( cout_tb  )
    
    
    
    );

initial begin
    #1000;
    $display ("a   b   cin   ||    sum    cout ");

    #10 ; 
    
    // 000
    a_tb = 0 ;  b_tb = 0 ;  cin_tb = 0 ; 
    #10;
    $display ("%b   %b    %b  ||   %b     %b  " , a_tb , b_tb , cin_tb , sum_tb  , cout_tb);
    
    
    // 001
    a_tb = 0 ;  b_tb = 0 ;  cin_tb = 1 ; 
    #10;
    $display ("%b   %b    %b  ||   %b     %b  " , a_tb , b_tb , cin_tb , sum_tb  , cout_tb);
    
    
    // 010
    a_tb = 0 ;  b_tb = 1 ;  cin_tb = 0 ; 
    #10;
    $display ("%b   %b    %b  ||   %b     %b  " , a_tb , b_tb , cin_tb , sum_tb  , cout_tb);
    
    
    // 011
    a_tb = 0 ;  b_tb = 1 ;  cin_tb = 1 ; 
    #10;
    $display ("%b   %b    %b  ||   %b     %b  " , a_tb , b_tb , cin_tb , sum_tb  , cout_tb);
    
    
    // 100
    a_tb = 1 ;  b_tb = 0 ;  cin_tb = 0 ; 
    #10;
    $display ("%b   %b    %b  ||   %b     %b  " , a_tb , b_tb , cin_tb , sum_tb  , cout_tb);
    
    
    // 101
    a_tb = 1 ;  b_tb = 0 ;  cin_tb = 1 ; 
    #10;
    $display ("%b   %b    %b  ||   %b     %b  " , a_tb , b_tb , cin_tb , sum_tb  , cout_tb);
    
    
    // 110
    a_tb = 1 ;  b_tb = 1 ;  cin_tb = 0 ; 
    #10;
    $display ("%b   %b    %b  ||   %b     %b  " , a_tb , b_tb , cin_tb , sum_tb  , cout_tb);
    
    // 111
    a_tb = 1 ;  b_tb = 1 ;  cin_tb = 1 ; 
    #10;
    $display ("%b   %b    %b  ||   %b     %b  " , a_tb , b_tb , cin_tb , sum_tb  , cout_tb);

    
end



endmodule
