`timescale 1ns / 1ps
module tb_ASANSOR();
reg     i_clk ;
reg     i_rst ;
reg  [1:0]   i_btn ;
wire [1:0]   o_led ;



    ASANSOR  DUT (
        .i_clk  (i_clk) , 
        .i_rst  (i_rst) , 
        .i_btn  (i_btn) , 
        .o_led  (o_led) 
    );
    
  
initial begin
    i_clk = 0 ;
    forever #5 i_clk = ~i_clk ; 
end

initial begin
    #1000 ;
    i_rst = 1 ; 
    #10;
    i_rst = 0 ; 
    #10 ; 
    
    i_btn = 'b11 ; 
    #100;
    
    
    repeat (10) begin
        i_btn = $random %4 ;
        #20;
    end
    $finish  ; 
end

endmodule
