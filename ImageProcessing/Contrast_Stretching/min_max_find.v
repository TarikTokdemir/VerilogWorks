`timescale 1ns / 1ps

module min_max_find // RAM1'e yazma yaparken bu islem de gerceklestirilebilir .
    #(
    parameter  DATA_WIDTH = 8     ,
                RAM_DEPTH  = 76800 ,
                ADDR_WIDTH = $clog2(RAM_DEPTH) 
    )(
input                   clk_i_min_max   , rstn_i_min_max , en_i_min_max , 
input  [DATA_WIDTH-1:0] data_i_min_max  , 
input                   last_i_min_max  , // ram addr == RAM_DEPTH ----->>> last_i_min_max = 1 

output [DATA_WIDTH-1:0] data_o_min_value , data_o_max_value , 
output                  done_o_min_max 

    );
    
reg [1:0] STATE ; 
localparam  IDLE        = 2'b00,
            MIN_MAX     = 2'b01,
            END         = 2'b10;
            
reg [DATA_WIDTH-1:0]    min_value_reg           ;            
reg [DATA_WIDTH-1:0]    max_value_reg           ;          
     
reg [DATA_WIDTH-1:0]    data_o_min_value_reg    ; 
reg [DATA_WIDTH-1:0]    data_o_max_value_reg    ; 
reg                     done_o_min_max_reg      ; 
assign data_o_min_value = data_o_min_value_reg  ;
assign data_o_max_value = data_o_max_value_reg  ;
assign done_o_min_max   = done_o_min_max_reg    ;


           
always @(posedge clk_i_min_max or posedge rstn_i_min_max) begin
    if (!rstn_i_min_max) begin
        STATE <= IDLE ;
    end else begin
        case (STATE) 
            IDLE : begin
                min_value_reg           <= 8'd255 ;  // ***
                max_value_reg           <= 8'b0 ;    // ***
                
                data_o_min_value_reg    <= 8'b0 ; 
                data_o_max_value_reg    <= 8'b0 ; 
                done_o_min_max_reg      <= 1'b0 ;
                
                if (en_i_min_max) begin
                    STATE           <= MIN_MAX          ; 
                end
            end
            
            MIN_MAX : begin
                if (data_i_min_max > max_value_reg) begin
                    max_value_reg <= data_i_min_max ; 
                end
                
                if (data_i_min_max < min_value_reg) begin
                    min_value_reg <= data_i_min_max ; 
                end
                
                if (last_i_min_max) begin
                    STATE <= END ;
                end
            end
            
            END : begin
                done_o_min_max_reg      <= 1                ; 
                data_o_min_value_reg    <= min_value_reg    ; 
                data_o_max_value_reg    <= max_value_reg    ;
                STATE                   <= IDLE             ;
            end
        default : STATE <= IDLE ;
        endcase
    end
end
endmodule
