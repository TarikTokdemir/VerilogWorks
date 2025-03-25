`timescale 1ns / 1ps

module binary_division #(
    parameter DATA_WIDTH = 8 
)(
// 16 bit dividend and 8 bit divisior  .  for contrast stretching ( a * b / c ) ---- (8 * 8 / 8 ) 
input clk_i_div , rstn_i_div , en_i_div ,
input [DATA_WIDTH-1:0]B , // divisior  8
input [DATA_WIDTH*2-1:0]Q , // dividend max 16
output  [DATA_WIDTH-1:0] result_o_div,
output  div_done_o 

    );
    
reg [4:0] count                             ;
reg [DATA_WIDTH*2   :0] A                   ;  // 8 x 2 16+1 bit
reg [DATA_WIDTH-1   :0] divisor             ;  // 8 bit
reg [DATA_WIDTH*2-1 :0] dividend            ;  // 16 bit
reg [DATA_WIDTH*4   :0] temp4               ;  // data 8bit ==>>>  8x8 = 16 bit  ===>>> {16+1 , 16 } = 33 bit  ==>> WIDTH*4  ==>>> [32:0]
reg [DATA_WIDTH*2   :0] complement_divisor  ; 
reg [3:0] STATE ; 

localparam  IDLE    = 4'b0000,
            LOAD    = 4'b0001,
            SHIFT   = 4'b0010,
            SUB     = 4'B0011,
            REVERSE = 4'b0100,
            DONE    = 4'b0101, 
            WAIT    = 4'b0110;
            
 reg [DATA_WIDTH*2   :0] remainder  ;
 reg [DATA_WIDTH-1   :0] division   ;          
 reg div_done ;
 
 assign div_done_o  = div_done      ;
 assign result_o_div    = division      ;
 
always @(posedge clk_i_div or negedge rstn_i_div) begin
    if (!rstn_i_div) begin
        STATE <= IDLE ; 
    end
    else begin
        case (STATE) 
            IDLE : begin // 0 
                A           <= 17'b0    ; 
                count       <= 0        ;
                div_done    <= 0        ; 
                temp4       <= 0        ; 
                divisor     <= 0        ; 
                dividend    <= 0        ;
                
                if (en_i_div) begin
                    STATE       <= LOAD     ;
                end
            end
            
            LOAD : begin // 1 
                divisor             <= B            ; 
                dividend            <= Q            ;
                STATE               <= SHIFT        ;
                temp4               <= { A , Q }    ;
                complement_divisor  <= (~{1'b0 , B}) + 1'b1 ; 
            end
            
            SHIFT : begin // 2
                if (count < 16) begin
                    temp4 <= temp4 << 1 ;
                    STATE <= SUB ;
                    count <= count + 1 ;  
                end 
                else begin
                    STATE <= DONE ; 
                end
            end
            
            SUB : begin // 3 // normally should subtract . but we have 2's copmlenet of divisior . so we can use summing  
                A <= temp4[DATA_WIDTH*4 : DATA_WIDTH*2] ; 
                temp4[DATA_WIDTH*4 : DATA_WIDTH*2] <= temp4 [DATA_WIDTH*4 : DATA_WIDTH*2] + complement_divisor  ;
                STATE <= REVERSE ; 
            end 
            
            REVERSE : begin // 4
                if (temp4[DATA_WIDTH*4] == 0 ) begin
                    temp4[0] <= 1 ; 
                end
                else begin // if msb == 1 
                    temp4[0] <= 0 ; 
                    temp4[DATA_WIDTH*4 : DATA_WIDTH*2] <= A ;
                end
                STATE <= SHIFT ;
            end 
            
            DONE : begin // 5 
                remainder <= temp4[DATA_WIDTH*4 : DATA_WIDTH*2] ;
                division  <= temp4[DATA_WIDTH*2-1: 0] ; 
                STATE     <= WAIT ;
                
            end
            
            WAIT : begin
                div_done  <= 1 ;
                if(div_done)
                    STATE     <= IDLE ; 
            end
        endcase
    end
end

endmodule