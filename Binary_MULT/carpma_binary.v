// Create Date: 08.03.2025 13:41:44
`timescale 1ns / 1ps

module carpma_binary  #(
        parameter [31:0] RED_CONSTANT   = 32'b00111110_10011001_00001001_01101100 ,//32'h3e99096c , 0.2989    // floating point halleri 
        parameter [31:0] GREEN_CONSTANT = 32'b00111111_00010110_01000101_10100010 ,//32'h3f1645a2 , 0.5870    // floating point halleri 
        parameter [31:0] BLUE_CONSTANT  = 32'b00111101_11101001_01111000_11010101 ,//32'h3de978d5 , 0.1140    // floating point halleri 
        
        parameter PIXEL_WIDTH       = 8  , 
        parameter FP_WIDTH          = 32 ,
        parameter MANTISSA_WIDTH    = 23 , 
        parameter EXPONENT_WIDTH    = 8  , 
        parameter SIGN_WIDTH        = 1  ,
        parameter BIAS              = 127
    )(
input clk_i_fix_multi  ,
input rstn_i_fix_multi ,
input en_i_fix_multi   ,

input [23:0] data_in_from_fp_R ,   //fraction_R
input [23:0] data_in_from_fp_G ,   //fraction_G
input [23:0] data_in_from_fp_B ,   //fraction_B

output [23:0] result_o_R ,
output [23:0] result_o_G ,
output [23:0] result_o_B ,
output signed [5:0] exp_o_R ,
output signed [5:0] exp_o_G ,
output signed [5:0] exp_o_B ,

output        multiplication_done_o 
    );

reg [23:0] multiplicand_R ;
reg [23:0] multiplicand_G ;
reg [23:0] multiplicand_B ;
reg [23:0] multiplier_R ;
reg [23:0] multiplier_G ;
reg [23:0] multiplier_B ;
reg [23:0] result_R ; 
reg [23:0] result_G ; 
reg [23:0] result_B ;
reg signed [5:0] exp_R ;
reg signed [5:0] exp_G ;
reg signed [5:0] exp_B ;

reg [5:0] index ;
reg [5:0] zero_count ; 
reg [47:0] buffer_48 ;
reg [47:0] buffer_48_shift ;
reg done_R ;
reg done_G ;
reg done_B ;
reg multiplication_done ;

assign multiplication_done_o = multiplication_done ;
assign result_o_R = result_R ;
assign result_o_G = result_G ;
assign result_o_B = result_B ;
assign exp_o_R = exp_R ;
assign exp_o_G = exp_G ;
assign exp_o_B = exp_B ;

reg [2:0] go_state ;
reg [2:0] STATE ;
localparam  IDLE   = 3'b000,
            LOAD   = 3'b001,
            MULT_R = 3'b010,
            MULT_G = 3'b011,
            MULT_B = 3'b100,
            SUM    = 3'b101,
            LAST   = 3'b111 ;
            
            
always @(posedge clk_i_fix_multi or posedge rstn_i_fix_multi ) begin
    if ( !rstn_i_fix_multi ) begin
        STATE <= IDLE ; 
    end 
    else begin
        case (STATE)
            IDLE : begin
                if ( en_i_fix_multi ) begin
                    STATE <= LOAD ;
                    multiplication_done <= 0 ; 
                    result_R  <= 0 ; 
                    result_G  <= 0 ; 
                    result_B  <= 0 ;
                    multiplier_R <= 0 ; 
                    multiplier_G <= 0 ; 
                    multiplier_B <= 0 ; 
                    multiplicand_R <= 0 ; 
                    multiplicand_G <= 0 ; 
                    multiplicand_B <= 0 ; 
                    index <= 0 ; 
                    zero_count <= 0 ; 
                    buffer_48 <= 0 ; 
                    go_state<= 0 ; 
                    exp_R <= 0 ;
                    exp_G <= 0 ;
                    exp_B <= 0 ;
                end
            end
            
            LOAD : begin
                multiplicand_R  <= data_in_from_fp_R ;
                multiplicand_G  <= data_in_from_fp_G ;
                multiplicand_B  <= data_in_from_fp_B ;
                
                multiplier_R    <= { 1'b1 , RED_CONSTANT  [22:0] } ; 
                multiplier_G    <= { 1'b1 , GREEN_CONSTANT[22:0] } ; 
                multiplier_B    <= { 1'b1 , BLUE_CONSTANT [22:0] } ; 
                
                STATE <= MULT_R ; 
            end
            
            MULT_R : begin
                if ( index < 24 ) begin
                    if ( multiplier_R [index] == 0 ) begin
                        buffer_48_shift   <= 0 ; 
                    end
                    else begin
                        buffer_48_shift[23:0]   <= multiplicand_R ;
                    end
                end 
                else begin
                    done_R <= 1 ; 
                    go_state <= go_state + 1 ; 
                    index <= 0 ;
                end
                STATE <= SUM ; // her turlu sum'a gidecek . orda state degisecek
            end
            
            MULT_G : begin
                if ( index < 24 ) begin
                    if ( multiplier_G [index] == 0 ) begin
                        buffer_48_shift   <= 0 ; 
                    end
                    else begin
                        buffer_48_shift[23:0]   <= multiplicand_G ;
                    end
                end 
                else begin
                    done_G <= 1 ;
                    go_state <= go_state + 1 ; 
                    index <= 0 ;
                end
                STATE <= SUM ;
            end
            
            MULT_B : begin
                if ( index < 24 ) begin
                    if ( multiplier_B [index] == 0 ) begin
                        buffer_48_shift   <= 0 ; 
                    end
                    else begin
                        buffer_48_shift[23:0]   <= multiplicand_B ;
                    end
                end 
                else begin
                    index   <= 0 ;
                    done_B  <= 1 ;
                end
                STATE <= SUM ; 
            end
            
            SUM : begin
                if (done_R) begin
                    if ( buffer_48[47] == 1 ) begin // bilimsel gosterim yapsýn
                        buffer_48 <= buffer_48 >> 1;
                        exp_R <= exp_R + 1 ; 
                    end else if ( buffer_48[46] == 0 ) begin
                        buffer_48 <= buffer_48 << 1;
                        exp_R <= exp_R - 1 ;
                    end else begin
                        result_R <= buffer_48 [46:23] ; 
                        STATE <= MULT_G ;
                        index   <= 0 ;
                        done_R  <= 0 ; 
                        buffer_48 <= 0 ;
                    end
                end else if (done_G) begin
                    if ( buffer_48[47] == 1 ) begin // bilimsel gosterim yapsýn
                        buffer_48 <= buffer_48 >> 1;
                        exp_G <= exp_G + 1 ;
                    end else if ( buffer_48[46] == 0 ) begin
                        buffer_48 <= buffer_48 << 1;
                        exp_G <= exp_G - 1 ;
                    end else begin
                        result_G <= buffer_48 [46:23] ; 
                        index   <= 0 ;
                        done_G  <= 0 ; 
                        buffer_48 <= 0 ;
                    end
                end else if (done_B) begin
                    if ( buffer_48[47] == 1 ) begin // bilimsel gosterim yapsýn
                        buffer_48 <= buffer_48 >> 1;
                        exp_B <= exp_B - 1 ;
                    end else if ( buffer_48[46] == 0 ) begin
                        buffer_48 <= buffer_48 << 1;
                        exp_B <= exp_B - 1 ;
                    end else begin
                        result_B <= buffer_48 [46:23] ; 
                        STATE <= LAST ;
                        index   <= 0 ;
                        done_B  <= 0 ; 
                        buffer_48 <= 0 ;
                    end
                end else begin 
                    STATE <= MULT_R + go_state  ;
                    buffer_48_shift <= 0 ;
                    done_R <= 0 ; 
                    buffer_48 <= (buffer_48_shift << index) + buffer_48  ;
                    index <= index + 1 ; 
                end
            end
            
            LAST : begin
                multiplication_done <= 1 ; 
                STATE <= IDLE ; 
            end
            
            
        endcase
    end
end


endmodule
