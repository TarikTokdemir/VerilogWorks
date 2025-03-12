`timescale 1ns / 1ps

module carpma_8bit  #(
        parameter [31:0] RED_CONSTANT   = 32'b00111110_10011001_00001001_01101100 ,//32'h3e99096c , 0.2989    // floating point halleri 
        parameter [31:0] GREEN_CONSTANT = 32'b00111111_00010110_01000101_10100010 ,//32'h3f1645a2 , 0.5870    // floating point halleri 
        parameter [31:0] BLUE_CONSTANT  = 32'b00111101_11101001_01111000_11010101 ,//32'h3de978d5 , 0.1140    // floating point halleri 
        
        parameter PIXEL_WIDTH       = 8  , 
        parameter FP_WIDTH          = 32 ,
        parameter MANTISSA_WIDTH    = 8 ,  /// 8 bit mantissa
        parameter EXPONENT_WIDTH    = 8  , 
        parameter SIGN_WIDTH        = 1  ,
        parameter BIAS              = 127
    )(
input clk_i_fix_multi  ,
input rstn_i_fix_multi ,
input en_i_fix_multi   ,

input [9:0] data_i_mult_R ,   //fraction_R {1,8}
input [9:0] data_i_mult_G ,   //fraction_G {1,8}
input [9:0] data_i_mult_B ,   //fraction_B {1,8}

output [9:0] result_o_R ,   // fraction degeri gonder {1,8}
output [9:0] result_o_G ,   // fraction degeri gonder {1,8}
output [9:0] result_o_B ,   // fraction degeri gonder {1,8}

output signed [4:0] exp_o_R ,  // 8x8 min 00.0000_0000_0000_01 exp en fazla -14 kadar kayabilir . -16 olsa yeterli  => 5 bit 
output signed [4:0] exp_o_G ,  // 8x8 min 00.0000_0000_0000_01 exp en fazla -14 kadar kayabilir . -16 olsa yeterli  => 5 bit 
output signed [4:0] exp_o_B ,  // 8x8 min 00.0000_0000_0000_01 exp en fazla -14 kadar kayabilir . -16 olsa yeterli  => 5 bit 

output mult_done_o  
    );
    
reg [9:0] multiplicand_R ;   // data_in r
reg [9:0] multiplicand_G ;   // data_in g 
reg [9:0] multiplicand_B ;   // data_in b
reg [9:0] multiplier_R ;     // constant r   
reg [9:0] multiplier_G ;     // constant g   
reg [9:0] multiplier_B ;     // constant b   
reg [9:0] result_R ;   
reg [9:0] result_G ;   
reg [9:0] result_B ;   
reg signed [EXPONENT_WIDTH/2:0] exp_R ;
reg signed [EXPONENT_WIDTH/2:0] exp_G ;
reg signed [EXPONENT_WIDTH/2:0] exp_B ;

reg mult_done ; 

assign mult_done_o = mult_done ;
assign result_o_R = result_R ;
assign result_o_G = result_G ;
assign result_o_B = result_B ;
assign exp_o_R = exp_R ;
assign exp_o_G = exp_G ;
assign exp_o_B = exp_B ;

reg [2:0] STATE ;
localparam  IDLE        = 3'b000, 
            LOAD        = 3'b001, 
            MULT        = 3'b010,
            SUM         = 3'b011,
            MULT_DONE   = 3'b100;
            
reg [19:0] reg_20_R          ;
reg [19:0] reg_20_G          ;  
reg [19:0] reg_20_B          ;        
reg [19:0] reg_20_shift_R   ;
reg [19:0] reg_20_shift_G   ;
reg [19:0] reg_20_shift_B   ;
reg [5:0] index ; 
reg done_rgb ;



always @(posedge clk_i_fix_multi or posedge rstn_i_fix_multi ) begin
    if ( !rstn_i_fix_multi ) begin
        STATE <= IDLE ; 
    end 
    else begin
        if ( en_i_fix_multi ) begin
            case (STATE)
                IDLE : begin
                    if ( en_i_fix_multi ) begin
                        multiplicand_R <= 0 ;     
                        multiplicand_G <= 0 ;     
                        multiplicand_B <= 0 ;           
                        multiplier_R <= 0 ;       
                        multiplier_G <= 0 ;       
                        multiplier_B <= 0 ;       
                        result_R  <= 0 ;          
                        result_G  <= 0 ;          
                        result_B  <= 0 ;
                        exp_R <= 0 ;              
                        exp_G <= 0 ;              
                        exp_B <= 0 ;
                        mult_done <= 0 ;
                        
                        index               <= 0 ;              
                        reg_20_R          <= 0 ;          
                        reg_20_G          <= 0 ;
                        reg_20_B          <= 0 ;
                        reg_20_shift_R    <= 0 ;
                        reg_20_shift_G    <= 0 ;
                        reg_20_shift_B    <= 0 ;
                        done_rgb <= 0 ;             
                        STATE <= LOAD ;               
                    end
                end
                        
                LOAD : begin
                    multiplicand_R  <= data_i_mult_R ;
                    multiplicand_G  <= data_i_mult_G ;
                    multiplicand_B  <= data_i_mult_B ;
                    multiplier_R    <= { 1'b1 , RED_CONSTANT  [22:14] } ; 
                    multiplier_G    <= { 1'b1 , GREEN_CONSTANT[22:14] } ; 
                    multiplier_B    <= { 1'b1 , BLUE_CONSTANT [22:14] } ; 
                    
                    STATE <= MULT ; 
                end
                
                MULT : begin
                    if ( index < 10 ) begin
                        if ( multiplier_R [index] == 0 ) begin
                            reg_20_shift_R   <= 0 ; 
                        end else begin
                            reg_20_shift_R[9:0] <= multiplicand_R ;
                        end
                        
                        if ( multiplier_G [index] == 0 ) begin
                            reg_20_shift_G   <= 0 ; 
                        end else begin
                            reg_20_shift_G[9:0] <= multiplicand_G ;
                        end
                        
                        if ( multiplier_B [index] == 0 ) begin
                            reg_20_shift_B   <= 0 ; 
                        end else begin
                            reg_20_shift_B[9:0] <= multiplicand_B ;
                        end
                    end else begin
                        done_rgb <= 1 ; 
                        index <= 0 ;
                    end
                    
                    STATE <= SUM ;
                end   
                
                SUM : begin
                    if ( done_rgb ) begin
                        if ( reg_20_R[19] == 1 ) begin          //RED
                            reg_20_R <= reg_20_R >> 1;
                            exp_R <= exp_R + 1 ; 
                        end else if ( reg_20_R[18] == 0 ) begin
                            reg_20_R <= reg_20_R << 1;
                            exp_R <= exp_R - 1 ;
                            
                        end else if ( reg_20_G[19] == 1 ) begin// GREEN
                            reg_20_G <= reg_20_G >> 1;
                            exp_G <= exp_G + 1 ;
                        end else if ( reg_20_G[18] == 0 ) begin
                            reg_20_G <= reg_20_G << 1;
                            exp_G <= exp_G - 1 ;
                            
                        end else if ( reg_20_B[19] == 1 ) begin//BLUE
                            reg_20_B <= reg_20_B >> 1;
                            exp_B <= exp_B + 1 ;
                        end else if ( reg_20_B[18] == 0 ) begin
                            reg_20_B <= reg_20_B << 1;
                            exp_B <= exp_B - 1 ;
                            
                        end else begin
                            result_R <= reg_20_R [18:9] ; 
                            result_G <= reg_20_G [18:9] ;
                            result_B <= reg_20_B [18:9] ;
                            index   <= 0 ;

                            STATE <= MULT_DONE ;
                        end
                    end else begin
                        reg_20_R  <= (reg_20_shift_R << index ) + reg_20_R  ;
                        reg_20_G  <= (reg_20_shift_G << index ) + reg_20_G  ;
                        reg_20_B  <= (reg_20_shift_B << index ) + reg_20_B  ;
                        
                        index           <= index + 1 ;
                        STATE           <= MULT ; 
                    end
                end    
                
                MULT_DONE : begin
                    mult_done <= 1 ; 
                    STATE <= IDLE ;
                end  
            endcase
        end
    end  
end                

endmodule