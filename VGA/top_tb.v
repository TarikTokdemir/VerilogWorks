`timescale 1ns / 1ps

module top_tb;
    reg clk;
    reg rst;
    reg en_i_top;
    reg en_vga_top ; 
    wire [11:0] VGA_RGB;
    wire VGA_HS;
    wire VGA_VS;

always #5 clk = ~clk;

top uut (
    .clk_i_top      (clk),
    .rstn_i_top     (rst),
    .en_i_top       (en_i_top),
    .en_vga_top     (en_vga_top),
    .VGA_RGB        (VGA_RGB),
    .VGA_HS         (VGA_HS),
    .VGA_VS         (VGA_VS)
);

initial begin
    #20 ; 
    clk = 0;
    rst = 1;
    en_i_top = 0;
    en_vga_top = 0 ;
    #1000 ;
    rst = 0;
    
    #1000;
    en_i_top = 1;

    wait(uut.write_done) ;
    #10;
    $finish;
end
endmodule