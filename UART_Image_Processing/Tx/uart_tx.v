`timescale 1ns / 1ps

module uart_tx #(
    parameter DATA_WIDTH = 8 
)(
    input                   clk_i_tx        , rsnt_i_tx     , tx_start  ,
    input [DATA_WIDTH-1:0]  data_i_tx       ,
    input [DATA_WIDTH*2:0]  baud_div_i_tx   ,
    
    output active_o_tx      ,
    output data_o_serial_tx ,
    output done_o_tx   
    
);

reg active_o_tx_reg         ;
reg data_o_serial_tx_reg    ;
reg done_o_tx_reg           ;
assign active_o_tx      = active_o_tx_reg       ; 
assign data_o_serial_tx = data_o_serial_tx_reg  ;
assign done_o_tx        = done_o_tx_reg         ;

reg [DATA_WIDTH*2:0] baud_counter   ;
reg [DATA_WIDTH*2:0] bit_counter    ;
reg [DATA_WIDTH-1:0] shift_reg      ;

reg [1:0]   STATE             ; 
localparam  IDLE      = 2'b00 ,
            START     = 2'b01 , 
            DATA      = 2'b10 ,
            STOP      = 2'b11 ;

always @(posedge clk_i_tx or negedge rsnt_i_tx) begin
    if(!rsnt_i_tx) begin
        STATE       <= IDLE ;     
    end
    else begin
        case (STATE)
            IDLE : begin
                active_o_tx_reg         <= 0 ; 
                data_o_serial_tx_reg    <= 1 ; 
                done_o_tx_reg           <= 0 ;
                baud_counter            <= 0 ;
                bit_counter             <= 0 ;
                
                if (tx_start == 1'b1) begin
                    active_o_tx_reg <= 1            ;                
                    shift_reg       <= data_i_tx    ;
                    data_o_serial_tx_reg    <= 0    ;
                    STATE           <= START        ; 
                end
            end
            
            START : begin // wait for start bit to finish 
                if (baud_counter == baud_div_i_tx-1) begin
                    data_o_serial_tx_reg    <= shift_reg[0]     ; // data'ya geçtiði anda güncellenir
                    shift_reg[7]            <= shift_reg[0]     ;
                    shift_reg[6:0]          <= shift_reg[7:1]   ;
                    baud_counter            <= 0                ;
                    STATE                   <= DATA             ;
                end
                else begin
                    baud_counter            <= baud_counter + 1 ; 
                end
            end
            
            DATA : begin
                if (bit_counter == 7) begin
                    if (baud_counter == baud_div_i_tx-1) begin
                        data_o_serial_tx_reg    <= 1    ; 
                        baud_counter            <= 0    ; 
                        bit_counter             <= 0    ; 
                        STATE                   <= STOP ;          
                    end
                    else begin
                        baud_counter            <= baud_counter + 1 ;
                    end
                end
                else begin
                    if (baud_counter == baud_div_i_tx-1) begin
                        shift_reg[7]            <= shift_reg[0]     ;
                        data_o_serial_tx_reg    <= shift_reg[0]     ;
                        shift_reg[6:0]          <= shift_reg[7:1]   ;
                        bit_counter             <= bit_counter + 1  ;
                        baud_counter            <= 0                ;
                    end
                    else begin
                        baud_counter            <= baud_counter + 1 ;
                    end
                end
            end
            
            STOP : begin
                if (baud_counter == baud_div_i_tx-1) begin
                    active_o_tx_reg         <= 0    ;
                    done_o_tx_reg           <= 1    ;
                    STATE                   <= IDLE ; 
                end
                else begin
                    baud_counter    <= baud_counter + 1 ;
                end
            end
            
        endcase
    end
end
endmodule
