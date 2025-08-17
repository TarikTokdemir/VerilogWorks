`timescale 1ns / 1ps

module tb_adder_4bit ;

reg [3:0]   A_tb        ;    // 0 - 15 
reg [3:0]   B_tb        ;
reg         Cin_tb      ;
                        
wire        Cout_tb     ;
wire [3:0]  Sum_tb      ;


    adder_4bit DUT(
        .A      (A_tb       ),  
        .B      (B_tb       ),
        .Cin    (Cin_tb     ),
        .Cout   (Cout_tb    ),
        .Sum    (Sum_tb     )
    );

initial begin
    #1000;
    $display ("A  ,  B   ,  Cin   , Cout  ,  Sum");

    repeat (10) begin
        #5 ;
        A_tb    = $random  %16;  // 32 bit deger uretir 0-15 
        B_tb    = $random  %16;  // seed 
        Cin_tb  = $random  %2 ; // 0 veya 1 
        #5 ; 
        $display ("A= %4b  , B= %4b  , Cin = %b , Cout= %4b , Sum= %4b",
                    A_tb   , B_tb    , Cin_tb   , Cout_tb   , Sum_tb  );
    end
end



endmodule
