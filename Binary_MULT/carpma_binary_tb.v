`timescale 1ns / 1ps


module carpma_binary_tb();
reg clk_i_fix_multi            ;
reg rstn_i_fix_multi           ;
reg en_i_fix_multi             ;
reg [23:0] data_in_from_fp_R   ;
reg [23:0] data_in_from_fp_G   ;
reg [23:0] data_in_from_fp_B   ;
wire [23:0] result_o_R          ;
wire [23:0] result_o_G          ;
wire [23:0] result_o_B          ;
wire multiplication_done        ;

carpma_binary #(
    .RED_CONSTANT  (32'b00111110_10011001_00001001_01101100),
    .GREEN_CONSTANT(32'b00111111_00010110_01000101_10100010),
    .BLUE_CONSTANT (32'b00111101_11101001_01111000_11010101)
) carpma_binary_uut (
    .clk_i_fix_multi    ( clk_i_fix_multi       ) , 
    .rstn_i_fix_multi   ( rstn_i_fix_multi      ) , 
    .en_i_fix_multi     ( en_i_fix_multi        ) , 
    .data_in_from_fp_R  ( data_in_from_fp_R     ) ,
    .data_in_from_fp_G  ( data_in_from_fp_G     ) ,
    .data_in_from_fp_B  ( data_in_from_fp_B     ) ,
    .result_o_R         ( result_o_R            ) ,
    .result_o_G         ( result_o_G            ) ,
    .result_o_B         ( result_o_B            ) ,
    .multiplication_done_o(multiplication_done)
);

always #5 clk_i_fix_multi = ~clk_i_fix_multi;

    initial begin
        clk_i_fix_multi = 0;
        rstn_i_fix_multi = 0;
        en_i_fix_multi = 0;
        

        #20 ;
        rstn_i_fix_multi = 1;
        en_i_fix_multi = 1 ;
                                                // 170 sayýsýnýn 1,010_1010_0000_0000_0000_0000
        data_in_from_fp_R = 24'b1001_0110_0000_0000_0000_0000; // 1.171875 // -0.828125
        data_in_from_fp_G = 24'b1010_0000_0000_0000_0000_0000; // 1.25 // -0.75
        data_in_from_fp_B = 24'b1010_1010_0000_0000_0000_0000; // 1.328125
        
        

        wait(multiplication_done);
        en_i_fix_multi = 0;
        #10;
        $display("Red Result   : %h", data_in_from_fp_R );
        $display("Green Result : %h", data_in_from_fp_G );
        $display("Blue Result  : %h", data_in_from_fp_B );

        $finish;
    end









endmodule
