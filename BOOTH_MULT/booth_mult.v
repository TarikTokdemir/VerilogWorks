// Create Date: 03.03.2025 11:39:30
`timescale 1ns / 1ps

module booth_mult
    #(                                  
        parameter [31:0] RED_CONSTANT   = 32'b0_01111101_0011001_00001001_01101100 ,//32'h3e99096c , 0.2989    varsyilan degerler bunlar ama ust modulden degistirilebilir  1.1956000328063965 ,    -0.8043999671936035
        parameter [31:0] GREEN_CONSTANT = 32'b0_01111110_0010110_01000101_10100010 ,//32'h3f1645a2 , 0.5870    varsyilan degerler bunlar ama ust modulden degistirilebilir  1.1740000247955322 ,    -0.8259999752044678
        parameter [31:0] BLUE_CONSTANT  = 32'b0_01111011_1101001_01111000_11010101 ,//32'h3de978d5 , 0.1140    varsyilan degerler bunlar ama ust modulden degistirilebilir
        parameter PIXEL_WIDTH       = 8  ,
        parameter FP_WIDTH          = 32 ,
        parameter MANTISSA_WIDTH    = 23 ,
        parameter EXPONENT_WIDTH    = 8  ,
        parameter SIGN_WIDTH        = 1  ,
        parameter BIAS              = 127 
    )(
    
input clk_i_fix_multi , 
input rstn_i_fix_multi , 
input en_i_fix_multi    ,

input [MANTISSA_WIDTH:0]  data_i_from_upper_Red   , //{1,mantissa}       //24bit       fraction_Red  
input [MANTISSA_WIDTH:0]  data_i_from_upper_Green , //{1,mantissa}       //24bit       fraction_Green
input [MANTISSA_WIDTH:0]  data_i_from_upper_Blue  , //{1,mantissa}       //24bit       fraction_Blue 

output [MANTISSA_WIDTH:0] fixed_multiplication_result_Red_o    ,  // carpim sonucu 24*24 = 48 bit  ama gonderilirken 24 kýsmý gonderilsin
output [MANTISSA_WIDTH:0] fixed_multiplication_result_Green_o  ,  // carpim sonucu 24*24 = 48 bit  ama gonderilirken 24 kýsmý gonderilsin
output [MANTISSA_WIDTH:0] fixed_multiplication_result_Blue_o   ,  // carpim sonucu 24*24 = 48 bit  ama gonderilirken 24 kýsmý gonderilsin

output [EXPONENT_WIDTH-4:0] significant_exponent_Red_o   ,
output [EXPONENT_WIDTH-4:0] significant_exponent_Green_o ,
output [EXPONENT_WIDTH-4:0] significant_exponent_Blue_o  ,

output fixed_multiplication_done_o

    );

reg [4:0] counter ;

reg [2:0] COLOR_STATE;
reg [1:0] ISLEM_STATE;

reg Q_1_R, Q_1_G, Q_1_B  ;  // Q-1 inci degerler . x[-1]

reg [MANTISSA_WIDTH:0] A     ;       // 24 bit
reg [MANTISSA_WIDTH*2+2:0] bit_birlesmis_49_R ;    // 49 bit
reg [MANTISSA_WIDTH*2+2:0] bit_birlesmis_49_G ;    // 49 bit
reg [MANTISSA_WIDTH*2+2:0] bit_birlesmis_49_B ;    // 49 bit

reg [MANTISSA_WIDTH:0] multiplicand_R ;   // 24bit
reg [MANTISSA_WIDTH:0] multiplicand_G ;   // 24bit
reg [MANTISSA_WIDTH:0] multiplicand_B ;   // 24bit

reg [MANTISSA_WIDTH:0] multiplier_R ;   //24 bit
reg [MANTISSA_WIDTH:0] multiplier_G ;   //24 bit
reg [MANTISSA_WIDTH:0] multiplier_B ;   //24 bit

reg [MANTISSA_WIDTH*2+1:0] fixed_multiplication_result_Red     ; //sonuc 48 bit 46+2-1 [47:0]
reg [MANTISSA_WIDTH*2+1:0] fixed_multiplication_result_Green   ; //sonuc 48 bit
reg [MANTISSA_WIDTH*2+1:0] fixed_multiplication_result_Blue    ; //sonuc 48 bit

reg [MANTISSA_WIDTH*2+1:0] direkt_carpma ;

reg fixed_multiplication_done ; 
assign fixed_multiplication_done_o = fixed_multiplication_done ;

reg CONSTANT24;

reg multiplication_done_Red , multiplication_done_Green , multiplication_done_Blue ;
reg [EXPONENT_WIDTH-4:0] significant_exponent_Red   ;
reg [EXPONENT_WIDTH-4:0] significant_exponent_Green ;
reg [EXPONENT_WIDTH-4:0] significant_exponent_Blue  ;

reg [MANTISSA_WIDTH:0] complement2_mulitplican ;
assign significant_exponent_Red_o   = significant_exponent_Red   ;
assign significant_exponent_Green_o = significant_exponent_Green ;
assign significant_exponent_Blue_o  = significant_exponent_Blue  ;


assign fixed_multiplication_result_Red_o    =  fixed_multiplication_result_Red   [47:24] ;
assign fixed_multiplication_result_Green_o  =  fixed_multiplication_result_Green [47:24] ;
assign fixed_multiplication_result_Blue_o   =  fixed_multiplication_result_Blue  [47:24] ;

localparam OPERATION = 2'b00 , SHIFTING = 2'b01  ;
localparam SUBTRACT  = 2'b10 , ADDING   = 2'b01  ; 
localparam START     = 3'b00 , RED      = 3'b001 , GREEN    = 3'b010 ,  BLUE = 3'b011 , SIGNIFICANT = 3'b100 , LAST = 3'b101 ; 


always @(posedge clk_i_fix_multi or negedge rstn_i_fix_multi) begin
        if (!rstn_i_fix_multi) begin
            COLOR_STATE <= 0 ; 
            fixed_multiplication_done <= 1'b0;
            ISLEM_STATE <= 0 ;
            multiplicand_R   <= 0 ;
            multiplicand_G   <= 0 ;
            multiplicand_B   <= 0 ;
            counter <= 0 ;
            A <= 0 ;
            Q_1_R <= 0 ; Q_1_G <= 0 ;  Q_1_B <= 0 ; 
            multiplier_R  <=   { 1'b1 , RED_CONSTANT  [22:0] } ;
            multiplier_G  <=   { 1'b1 , GREEN_CONSTANT[22:0] } ;
            multiplier_B  <=   { 1'b1 , BLUE_CONSTANT [22:0] } ;
            
        end else begin
            if (en_i_fix_multi) begin
                case ( COLOR_STATE )
                    START : begin // 3'b000
                        if ( fixed_multiplication_done != 1 ) begin
                            multiplicand_R <= data_i_from_upper_Red    ; 
                            multiplicand_G <= data_i_from_upper_Green  ;
                            multiplicand_B <= data_i_from_upper_Blue   ;
                            
                            bit_birlesmis_49_R <= {A , multiplier_R , Q_1_R }  ;// 24 , 24 , 1
                            bit_birlesmis_49_G <= {A , multiplier_G , Q_1_G }  ;
                            bit_birlesmis_49_B <= {A , multiplier_B , Q_1_B }  ;
                            
                            significant_exponent_Red    <= 0 ;
                            significant_exponent_Green  <= 0 ;
                            significant_exponent_Blue   <= 0 ;
                            complement2_mulitplican <= (~data_i_from_upper_Red)+1'b1;
                            COLOR_STATE <= RED ; 
                            ISLEM_STATE <= OPERATION ; 
                            CONSTANT24  <= 1'b1 ;
                        end
                    end
                        
                    RED : begin // 3'b001
                        if (counter < MANTISSA_WIDTH+1) begin
                            case (ISLEM_STATE)
                                OPERATION : begin // 2'b00 
                                    case ( {bit_birlesmis_49_R[1] , bit_birlesmis_49_R[0]} ) 
                                        SUBTRACT : begin // 2'b10 2scomplement ile topla
                                            bit_birlesmis_49_R[48:25] <= bit_birlesmis_49_R[48:25] - multiplicand_R  ; // 48:25 - 
                                            ISLEM_STATE <= SHIFTING ; 
                                        end
                                        
                                        ADDING : begin // 2'b01
                                            bit_birlesmis_49_R[48:25] <= bit_birlesmis_49_R[48:25] + multiplicand_R ; // 48:25
                                            ISLEM_STATE <= SHIFTING ; 
                                        end
                                        
                                        default : begin
                                            ISLEM_STATE <= SHIFTING ; 
                                        end
                                    endcase    
                                end
                                    
                                SHIFTING : begin   // 2'b01
                                    counter <= counter + 1 ;
                                    if (bit_birlesmis_49_R[48] == 1 ) begin
                                        bit_birlesmis_49_R <= bit_birlesmis_49_R >> 1 ;
                                        bit_birlesmis_49_R[48] <= 1 ; 
                                    end else begin // degilse 0 kalcak
                                        bit_birlesmis_49_R <= bit_birlesmis_49_R >> 1 ;
                                    end
                                    ISLEM_STATE <= OPERATION ;   // shifting    [47:25] <= [48],[47:25]
                                end
                                
                            endcase
                        end else begin // counter == 24
                            ISLEM_STATE <= OPERATION ;
                            COLOR_STATE <= GREEN ; 
                            multiplication_done_Red  <= 1 ;
                            fixed_multiplication_result_Red <= bit_birlesmis_49_R[MANTISSA_WIDTH*2+2-1:1] ; // 48:25
                            counter <= 0 ; 
                            complement2_mulitplican <= (~data_i_from_upper_Green)+1'b1;
                            direkt_carpma <= multiplicand_R*multiplier_R ;
                        end
                    end
                    
                    GREEN : begin // 3'b001
                        if (counter < MANTISSA_WIDTH+1) begin
                            case (ISLEM_STATE)
                                OPERATION : begin // 2'b00 
                                    case ( {bit_birlesmis_49_G[1] , bit_birlesmis_49_G[0]} ) 
                                        SUBTRACT : begin // 2'b10 2scomplement ile topla
                                            bit_birlesmis_49_G[48:25] <= bit_birlesmis_49_G[48:25] + complement2_mulitplican ; // 48:25 - 
                                            ISLEM_STATE <= SHIFTING ; 
                                        end
                                        
                                        ADDING : begin // 2'b01
                                            bit_birlesmis_49_G[48:25] <= bit_birlesmis_49_G[48:25] + multiplicand_G ; // 48:25
                                            ISLEM_STATE <= SHIFTING ; 
                                        end
                                        
                                        default : begin
                                            ISLEM_STATE <= SHIFTING ; 
                                        end
                                    endcase    
                                end
                                    
                                SHIFTING : begin   // 2'b01
                                    counter <= counter + 1 ;
                                    if (bit_birlesmis_49_G[48] == 1 ) begin
                                        bit_birlesmis_49_G <= bit_birlesmis_49_G >> 1 ;
                                        bit_birlesmis_49_G[48] <= 1 ; 
                                    end else begin // degilse 0 kalcak
                                        bit_birlesmis_49_G <= bit_birlesmis_49_G >> 1 ;
                                    end
                                    ISLEM_STATE <= OPERATION ;   // shifting    [47:25] <= [48],[47:25]
                                end
                                
                            endcase
                        end else begin // counter == 24
                            ISLEM_STATE <= OPERATION ;
                            COLOR_STATE <= BLUE ; 
                            multiplication_done_Green  <= 1 ;
                            fixed_multiplication_result_Green <= bit_birlesmis_49_G[MANTISSA_WIDTH*2+2-1:1] ; // 48:25
                            counter <= 0 ; 
                            complement2_mulitplican <= (~data_i_from_upper_Blue)+1'b1;
                        end
                    end
                    
                    BLUE : begin // 3'b001
                        if (counter < MANTISSA_WIDTH+1) begin
                            case (ISLEM_STATE)
                                OPERATION : begin // 2'b00 
                                    case ( {bit_birlesmis_49_B[1] , bit_birlesmis_49_B[0]} ) 
                                        SUBTRACT : begin // 2'b10 2scomplement ile topla
                                            bit_birlesmis_49_B[48:25] <= bit_birlesmis_49_B[48:25] + complement2_mulitplican ; // 48:25 - 
                                            ISLEM_STATE <= SHIFTING ; 
                                        end
                                        
                                        ADDING : begin // 2'b01
                                            bit_birlesmis_49_B[48:25] <= bit_birlesmis_49_B[48:25] + multiplicand_B ; // 48:25
                                            ISLEM_STATE <= SHIFTING ; 
                                        end
                                        
                                        default : begin
                                            ISLEM_STATE <= SHIFTING ; 
                                        end
                                    endcase    
                                end
                                    
                                SHIFTING : begin   // 2'b01
                                    counter <= counter + 1 ;
                                    if (bit_birlesmis_49_B[48] == 1 ) begin
                                        bit_birlesmis_49_B <= bit_birlesmis_49_B >> 1 ;
                                        bit_birlesmis_49_B[48] <= 1 ; 
                                    end else begin // degilse 0 kalcak
                                        bit_birlesmis_49_B <= bit_birlesmis_49_B >> 1 ;
                                    end
                                    ISLEM_STATE <= OPERATION ;   // shifting    [47:25] <= [48],[47:25]
                                end
                                
                            endcase
                        end else begin // counter == 24
                            ISLEM_STATE <= OPERATION ;
                            COLOR_STATE <= SIGNIFICANT ; 
                            multiplication_done_Blue  <= 1 ;
                            fixed_multiplication_result_Blue <= bit_birlesmis_49_B[MANTISSA_WIDTH*2+2-1:1] ; // 48:25
                            counter <= 0 ; 
                        end
                    end
                    
                    SIGNIFICANT : begin // bilimsel gosterim icin 1 sayýsý bulana kadar kaydýr . 
                        if (fixed_multiplication_result_Red[47] == 0 ) begin
                            fixed_multiplication_result_Red <= fixed_multiplication_result_Red << 1 ;
                            significant_exponent_Red <= significant_exponent_Red + 1 ;
                        end else if (fixed_multiplication_result_Green[47] == 0) begin
                            fixed_multiplication_result_Green <= fixed_multiplication_result_Green << 1 ;
                            significant_exponent_Green <= significant_exponent_Green + 1 ;
                        end else if (fixed_multiplication_result_Blue[47] == 0) begin
                            fixed_multiplication_result_Blue <= fixed_multiplication_result_Blue << 1 ;
                            significant_exponent_Blue <= significant_exponent_Blue + 1 ;
                        end else begin
                            COLOR_STATE <= LAST;
                        end
                    end
                    
                    LAST : begin 
                        fixed_multiplication_done <= 1 ; 
                        COLOR_STATE <= START ; 
                    end
                endcase
            end
        end
end
    

endmodule