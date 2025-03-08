`timescale 1ns / 1ps
//ONLY NEGATIVE WORKS . WHY IT IS idk
//must chance to real significant in simulation (fixed 1 bit,23 bit) 

module booth_mult_tb();

// Create Date: 04.03.2025 20:55:55


    parameter MANTISSA_WIDTH = 23;

    reg clk_i_fix_multi;
    reg rstn_i_fix_multi;
    reg en_i_fix_multi;

    reg [MANTISSA_WIDTH:0] data_i_from_upper_Red;// sanýrým fraction kýsýmlar gelecek buraya 
    reg [MANTISSA_WIDTH:0] data_i_from_upper_Green;
    reg [MANTISSA_WIDTH:0] data_i_from_upper_Blue;

    wire [MANTISSA_WIDTH*2+2-1:0] fixed_multiplication_result_Red_o;
    wire [MANTISSA_WIDTH*2+2-1:0] fixed_multiplication_result_Green_o;
    wire [MANTISSA_WIDTH*2+2-1:0] fixed_multiplication_result_Blue_o;
    wire fixed_multiplication_done_o;

//reg [MANTISSA_WIDTH:0] mantissa_red  = 24'b10011001_00001001_01101100; 
//reg [MANTISSA_WIDTH:0] complement_red   = ((~(24'b10011001_00001001_01101100))+1); 
//reg [MANTISSA_WIDTH:0] mantissa_gree = 24'b10010110_01000101_10100010; 
//reg [MANTISSA_WIDTH:0] complement_green = ((~(24'b10010110_01000101_10100010))+1); 
//reg [MANTISSA_WIDTH:0] data_i       = 24'b10010110_00000000_00000000; 
//reg [MANTISSA_WIDTH*2+2:0]carpim_sonucu = mantissa_red*data_i;
//reg [MANTISSA_WIDTH*2+1:0] sonuc_fixed_goster_R ;
//reg [MANTISSA_WIDTH*2+1:0] sonuc_fixed_goster_G ;
//reg [MANTISSA_WIDTH*2+1:0] sonuc_fixed_goster_B ;
    booth_mult uut (
        .clk_i_fix_multi(clk_i_fix_multi),
        .rstn_i_fix_multi(rstn_i_fix_multi),
        .en_i_fix_multi(en_i_fix_multi),
        .data_i_from_upper_Red(data_i_from_upper_Red),
        .data_i_from_upper_Green(data_i_from_upper_Green),
        .data_i_from_upper_Blue(data_i_from_upper_Blue),
        .fixed_multiplication_result_Red_o(fixed_multiplication_result_Red_o),
        .fixed_multiplication_result_Green_o(fixed_multiplication_result_Green_o),
        .fixed_multiplication_result_Blue_o(fixed_multiplication_result_Blue_o),
        .fixed_multiplication_done_o(fixed_multiplication_done_o)
    );

    always #5 clk_i_fix_multi = ~clk_i_fix_multi;
//always @(*) begin
//     sonuc_fixed_goster_R <= uut.multiplier_R[48:1];
//     sonuc_fixed_goster_G <= uut.multiplier_G[48:1];
//     sonuc_fixed_goster_B <= uut.multiplier_B[48:1];
//end
    initial begin
        clk_i_fix_multi = 0;
        rstn_i_fix_multi = 0;
        en_i_fix_multi = 0;
        

        #20 rstn_i_fix_multi = 1;
                                                // 170 sayýsýnýn 1,010_1010_0000_0000_0000_0000
        data_i_from_upper_Red   = 24'b1001_0110_0000_0000_0000_0000;   // 1.171875 // -0.828125
        data_i_from_upper_Green = 24'b1010_0000_0000_0000_0000_0000; // 1.25 // -0.75
        data_i_from_upper_Blue  = 24'b1010_1010_0000_0000_0000_0000; // 1.328125
        
        #20 en_i_fix_multi = 1;

        wait(fixed_multiplication_done_o);
        
        $display("Red Result   : %h", fixed_multiplication_result_Red_o);
        $display("Green Result : %h", fixed_multiplication_result_Green_o);
        $display("Blue Result  : %h", fixed_multiplication_result_Blue_o);

        #50 $finish;
    end
endmodule

