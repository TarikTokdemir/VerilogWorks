`timescale 1ns / 1ps


module carpma_binary_tb();
reg clk_i_fix_multi            ;
reg rstn_i_fix_multi           ;
reg en_i_fix_multi             ;
reg  [9:0] data_i_mult_R   ;
reg  [9:0] data_i_mult_G   ;
reg  [9:0] data_i_mult_B   ;
wire [9:0] result_o_R          ;
wire [9:0] result_o_G          ;
wire [9:0] result_o_B          ;
wire mult_done        ;

carpma_8bit #(
    .RED_CONSTANT  (32'b00111110_10011001_00001001_01101100),
    .GREEN_CONSTANT(32'b00111111_00010110_01000101_10100010),
    .BLUE_CONSTANT (32'b00111101_11101001_01111000_11010101)
) carpma_binary_uut (
    .clk_i_fix_multi    ( clk_i_fix_multi       ) , 
    .rstn_i_fix_multi   ( rstn_i_fix_multi      ) , 
    .en_i_fix_multi     ( en_i_fix_multi        ) , 
    .data_i_mult_R  ( data_i_mult_R     ) ,
    .data_i_mult_G  ( data_i_mult_G     ) ,
    .data_i_mult_B  ( data_i_mult_B     ) ,
    .result_o_R         ( result_o_R            ) ,
    .result_o_G         ( result_o_G            ) ,
    .result_o_B         ( result_o_B            ) ,
    .mult_done_o        (mult_done)
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
        data_i_mult_R = 10'b1_0010_11000; // 1.171875 // -0.828125
        data_i_mult_G = 10'b1_0100_00000; // 1.25 // -0.75
        data_i_mult_B = 10'b1_0101_01000; // 1.328125
        
        

        wait(mult_done);
        en_i_fix_multi = 0;
        #10;
        $display("Red Result   : %h", data_i_mult_R);
        $display("Green Result : %h", data_i_mult_G);
        $display("Blue Result  : %h", data_i_mult_B);

        $finish;
    end









endmodule
