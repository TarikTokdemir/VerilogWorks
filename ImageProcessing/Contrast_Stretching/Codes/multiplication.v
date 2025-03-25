`timescale 1ns / 1ps

module booth_mult_unsigned #(
    parameter DATA_WIDTH = 8 
)(
input                       clk_i_mult  , rstn_i_mult , en_i_mult ,
input   [DATA_WIDTH-1:0]    A           , // multiplier 
input   [DATA_WIDTH-1:0]    B           , // multiplicand
output  [DATA_WIDTH*2-1:0]  result_o_mult    ,
output                      mult_done_o 

    );
    
reg [2:0] STATE ;
localparam  IDLE    = 3'b000,
            LOAD    = 3'b001,
            OP      = 3'b010,
            SHIFT   = 3'b011,
            LAST    = 3'b100; 
            
localparam  SUB     = 2'b10,
            SUM     = 2'b01;

            
reg [DATA_WIDTH:0] multiplier     ; // A 
reg [DATA_WIDTH:0] multiplicand   ; // B
reg [DATA_WIDTH:0] Zeros          ; 
reg                  Q_1            ;
reg signed [DATA_WIDTH*2+2:0] temp19         ;
reg [DATA_WIDTH/2:0] counter        ;
reg [DATA_WIDTH+1  :0] complement_multiplicand ; 

reg [DATA_WIDTH*2-1:0] result_o_reg ;
assign result_o_mult = result_o_reg; 
reg mult_done_o_reg ;
assign mult_done_o = mult_done_o_reg ; 

always @(posedge clk_i_mult or negedge rstn_i_mult) begin
    if (!rstn_i_mult) begin
        STATE <= IDLE ; 
    end
    else begin
        case (STATE) 
        
            IDLE : begin // 0 
                multiplier      <= 0 ; 
                multiplicand    <= 0 ; 
                Zeros           <= 0 ;
                Q_1             <= 0 ; 
                mult_done_o_reg <= 0 ;
                complement_multiplicand <= {1'b0 , B} ;  
                counter         <= 0 ;
                result_o_reg    <= 0 ;  
                
                if (en_i_mult) begin
                    STATE       <= LOAD     ;
                end
            end
            
            LOAD : begin // 1 
                multiplier      <= {1'b0 , A} ;
                multiplicand    <= {1'b0 , B} ;
                temp19 <= {Zeros , A , Q_1};  // 9 9 1
                complement_multiplicand <= ( ((~complement_multiplicand) + 1'b1) ) ;  
                STATE <= OP ; 
            end
            
            OP : begin // 2
                if (counter < DATA_WIDTH+1 ) begin
                    case ({temp19[1] , temp19[0]}) 
                        SUM : begin // 01
                            temp19[DATA_WIDTH*2+2:DATA_WIDTH+2] <= temp19[DATA_WIDTH*2+2:DATA_WIDTH+2] + multiplicand ; 
                            STATE <= SHIFT ; 
                        end
                        
                        SUB : begin // 10 
                            temp19[DATA_WIDTH*2+2:DATA_WIDTH+2] <= temp19[DATA_WIDTH*2+2:DATA_WIDTH+2] + complement_multiplicand[DATA_WIDTH:0] ; 
                            STATE <= SHIFT ; 
                        end
                        
                        default : begin
                            temp19 <= temp19 >>> 1 ; 
                        end
                    endcase
                    counter <= counter + 1 ; 
                end
                else begin
                    STATE <= LAST ; 
                end
            end 
            
            SHIFT : begin // 3
                temp19 <= temp19 >>> 1 ;
                STATE   <= OP ; 
            end
            
            LAST : begin // 4 
                mult_done_o_reg <= 1 ; 
                result_o_reg    <= temp19[DATA_WIDTH*2+2:1] ; 
                STATE           <= IDLE ;
            end
        endcase
    end
end

endmodule
/*
reg                     en_i_div        ;
wire [DATA_WIDTH*2-1:0] result_o_div    ;
wire                    div_done_o      ;
     binary_division #(
.DATA_WIDTH(DATA_WIDTH)
    )inst_binary_division(
.clk_i_div      (clk_i_top_contrast      ),
.rstn_i_div     (rstn_i_top_contrast     ),
.en_i_div       (en_i_div       ),
.B              (B              ),   // comes from mult
.Q              (Q              ),  // comes from mult
.result_o_div   (result_o_div   ), //max 1111_1111_1111_1111 / 1 = 65535
.div_done_o     (div_done_o     )
);
*/