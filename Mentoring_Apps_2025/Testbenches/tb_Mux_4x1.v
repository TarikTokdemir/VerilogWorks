`timescale 1ns / 1ps

module tb_Mux_4x1();

reg [3:0] I_tb      ;
reg [1:0] sel_tb    ;
wire Y_tb           ;


    Mux_4x1   DUT (
        .I      (I_tb  ),
        .sel    (sel_tb),
        .Y      (Y_tb  )
    );
    
    
    
initial begin
    repeat (10) begin
        #5;
        I_tb    = $random ;
        sel_tb  = $random ;
        
        
        #5;
        $display ("I = %b    ,  sel = %b    =>   Y = %b" , I_tb , sel_tb , Y_tb  );
    end


end
endmodule
