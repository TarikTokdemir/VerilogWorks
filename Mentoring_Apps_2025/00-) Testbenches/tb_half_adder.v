`timescale 1ns / 1ps

module tb_half_adder();


reg a_tb        ;       
reg b_tb        ;
            
wire sum_tb      ;
wire carry_tb    ;
   


half_adder half_adder_dut (

.a      (a_tb       ),   
.b      (b_tb       ),
.sum    (sum_tb     ),
.carry  (carry_tb   )

);

initial begin
    #1000 ; 
    // Sifirlama 
    a_tb = 1'b0 ; 
    b_tb = 1'd0 ; 
    
    #10;  
    
    $display ("a  b  ||  sum  carry");
    
    // 00
    a_tb = 0 ; b_tb = 0 ; #10 ; 
    $display ("%b  %b  ||  %b   %b " , a_tb , b_tb , sum_tb , carry_tb);
    
    // 01
    a_tb = 0 ; b_tb = 1 ; #10 ; 
    $display ("%b  %b  ||  %b   %b " , a_tb , b_tb , sum_tb , carry_tb);
    
    
    // 10
    a_tb = 1 ; b_tb = 0 ; #10 ; 
    $display ("%b  %b  ||  %b   %b " , a_tb , b_tb , sum_tb , carry_tb);
    
    // 11
    a_tb = 1 ; b_tb = 1 ; #10 ; 
    $display ("%b  %b  ||  %b   %b " , a_tb , b_tb , sum_tb , carry_tb);
    
    $finish ;

end


endmodule
