`timescale 1ns / 1ps

module uart_rx #(
    parameter DATA_WIDTH = 8 
)(
    input                   clk_i_rx            , rsnt_i_rx     , 
    input                   data_i_serial_rx    ,
    input [DATA_WIDTH*2:0]  baud_div_i_rx       ,
    
    output                  active_o_rx ,
    output [DATA_WIDTH-1:0] data_o_rx   ,
    output                  done_o_rx   
    
);
reg [DATA_WIDTH-1:0] shift_reg      ;
reg active_o_rx_reg         ;
reg done_o_rx_reg           ;
assign active_o_rx      = active_o_rx_reg       ; 
assign data_o_rx        = shift_reg             ;
assign done_o_rx        = done_o_rx_reg         ;

reg [DATA_WIDTH*2:0] baud_counter   ;
reg [DATA_WIDTH/2:0] bit_counter    ;


reg [1:0]   STATE            ;
localparam  IDLE      = 2'b00 ,
            START     = 2'b01 , 
            DATA      = 2'b10 ,
            STOP      = 2'b11 ;

always @(posedge clk_i_rx or negedge rsnt_i_rx) begin
    if(!rsnt_i_rx) begin
        STATE       <= IDLE ;     
    end
    else begin
        case (STATE)
            IDLE : begin
                active_o_rx_reg         <= 0 ; 
                done_o_rx_reg           <= 0 ;
                baud_counter            <= 0 ;
                bit_counter             <= 0 ;
                
                if (data_i_serial_rx == 1'b0) begin
                    active_o_rx_reg <= 1            ;                
                    STATE           <= START        ; 
                end
            end
            
            START : begin // wait for start bit to finish . t/2 in rx
                if (baud_counter == baud_div_i_rx/2-1) begin
                    baud_counter            <= 0                ;
                    STATE                   <= DATA             ;
                end
                else begin
                    baud_counter            <= baud_counter + 1 ; 
                end
            end
            
            DATA : begin
                if (baud_counter == baud_div_i_rx-1) begin
                    if (bit_counter == 7) begin
                        bit_counter <= 0                ; 
                        STATE       <= STOP             ; 
                    end
                    else begin
                        bit_counter <= bit_counter + 1  ;
                    end
                    shift_reg       <= {data_i_serial_rx , shift_reg[7:1]} ;
                    baud_counter    <= 0 ;
                end
                else begin
                    baud_counter    <= baud_counter + 1 ;
                end
            end
            
            STOP : begin
                if (baud_counter == baud_div_i_rx-1) begin
                    active_o_rx_reg         <= 0    ;
                    done_o_rx_reg           <= 1    ;
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
