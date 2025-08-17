`timescale 1ns / 1ps
module LFSR #(
    parameter DW_LFSR = 6  // data genisligi 

) (
    input                   i_clk_lfsr  ,
    input                   i_en_lfsr   ,
    input                   i_rst_lfsr  , 
    input [DW_LFSR-1 : 0]   i_data_lfsr , 
    output [DW_LFSR-1 : 0]  o_rnd_lfsr  
    );
    
reg [DW_LFSR-1 : 0] rnd ;

assign o_rnd_lfsr = rnd ; 

always @(posedge i_clk_lfsr ) begin
    if (i_rst_lfsr) begin
        rnd <= i_data_lfsr ; 
    end
    else begin
        rnd <= {rnd[DW_LFSR-2:0] , rnd[4] ^ rnd[1]} ;
    end
end
    
endmodule
