`timescale 1ns / 1ps

module tb_LFSR();
parameter DW_LFSR = 6 ;


reg i_clk_lfsr  ; 
reg i_rst_lfsr  ;
reg [DW_LFSR-1:0] i_data_lfsr ;
wire [DW_LFSR-1:0] o_rnd_lfsr ; 

    LFSR #(
        .DW_LFSR (DW_LFSR) 
    )  DUT ( 
    .i_clk_lfsr  (i_clk_lfsr  ),
    .i_rst_lfsr  (i_rst_lfsr  ),
    .i_data_lfsr (i_data_lfsr ),
    .o_rnd_lfsr  (o_rnd_lfsr  )
    
    );
initial begin
    i_clk_lfsr = 0 ;
    forever #5 i_clk_lfsr = ~i_clk_lfsr ;
end

initial begin
    i_rst_lfsr  = 1 ;
    i_data_lfsr = 6'b101010 ;
    
    #10 ; 
    
    i_rst_lfsr  = 0 ;
    #1000;
    
    $finish ; 
end

endmodule
