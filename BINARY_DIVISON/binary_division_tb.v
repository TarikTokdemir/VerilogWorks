`timescale 1ns / 1ps

module binary_division_tb;

parameter DATA_WIDTH = 8;

reg clk_i_div;
reg rstn_i_div;
reg en_i_div;
reg [DATA_WIDTH-1:0] B; // divisor
reg [DATA_WIDTH*2-1:0] Q;

wire [DATA_WIDTH-1:0] result_o;
wire div_done_o;

binary_division #(DATA_WIDTH) uut (
    .clk_i_div(clk_i_div),
    .rstn_i_div(rstn_i_div),
    .en_i_div(en_i_div),
    .B(B),
    .Q(Q),
    .result_o(result_o),
    .div_done_o(div_done_o)
);

always #5 clk_i_div = ~clk_i_div; 

initial begin
    clk_i_div   = 0;
    rstn_i_div  = 1;
    en_i_div    = 0;
    B           = 0;
    Q           = 0;
    en_i_div = 1;

    #10;
    rstn_i_div = 0;
    #10;
    
    en_i_div = 0 ; 
    B = 8'd4;
    Q = 8'd100;
    wait(div_done_o);

    #30 ; 
    en_i_div = 1 ; 
    B = 8'd15;
    Q = 8'd150;
    wait(div_done_o);
    en_i_div = 0 ;
    
    #20 ;
    en_i_div = 1 ; 
    B = 8'd10;
    Q = 8'd255;
    wait(div_done_o);
    en_i_div = 0 ; 
    
    $finish;
end

endmodule