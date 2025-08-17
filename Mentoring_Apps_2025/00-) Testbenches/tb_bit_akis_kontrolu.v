`timescale 1ns / 1ps

module tb_bit_akis_kontrolu();

reg i_clk  ;
reg i_rstn  ;
reg [2:0] i_data ;
reg i_flag ; 
wire o_ERR ;


bit_akis_kontrolu DUT (
    .i_clk  (i_clk ),
    .i_rstn  (i_rstn ),
    .i_data (i_data),
    .i_flag (i_flag),
    .o_ERR  (o_ERR ),
    .o_ERR_done(o_ERR_done)
);

always #5 i_clk = ~i_clk ;



initial begin
    i_clk = 0;
    #1000;
    // i_rst = 1 ;  negedge degilse 
    i_rstn = 0 ; 
    #20;
    i_rstn = 1 ; 
    #20 ;
    
    repeat (100) begin
        i_flag = 1 ;
        i_data = $random %8;
        #10; 
        i_flag = 0 ;
        wait(o_ERR_done);
    end
    
    $finish;
end

endmodule
