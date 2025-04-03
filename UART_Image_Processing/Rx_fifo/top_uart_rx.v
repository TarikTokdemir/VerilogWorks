`timescale 1ns / 1ps

module top_uart_rx #(
    parameter DATA_WIDTH        = 8 ,
    parameter FIFO_DEPTH        = 32 , 
    parameter ADDR_WIDTH_FIFO   = $clog2(FIFO_DEPTH) 
    )(
input                   clk_i_top_rx      , 
input                   rstn_i_top_rx     , 
input                   active_i_top_rx   , // serial data controller
input                   data_i_serial_top_rx, // serial data in
input  [DATA_WIDTH*2:0] baud_div_top_rx   ,

output                  full_o_top_rx     ,
output                  empty_o_top_rx    
    );
    
reg   [DATA_WIDTH-1:0]  fifo_w_data ;
wire  [DATA_WIDTH-1:0]  fifo_r_data ;
reg                     fifo_rd     ;
reg                     fifo_wr     ; 
wire                    done_o_rx   ;   
wire  [DATA_WIDTH-1:0]  data_o_rx   ;

always @(posedge clk_i_top_rx or negedge rstn_i_top_rx) begin
    if(!rstn_i_top_rx) begin
        fifo_wr     <= 0          ;
        fifo_rd     <= 0          ;
        fifo_w_data <= 0          ;
    end
    else begin
        if ( (done_o_rx)  && (!full_o_top_rx) ) begin // signals for write to fifo
            fifo_wr         <= 1            ;
            fifo_rd         <= 0            ; // reading from fifo
            fifo_w_data     <= data_o_rx    ;
        end
        else begin
            fifo_wr         <= 0            ;
            fifo_rd         <= 0            ;
            fifo_w_data     <= 0            ;
        end
    end
end

uart_rx #(
    .DATA_WIDTH     (DATA_WIDTH     )
)uart_rx_inst(
    .clk_i_rx           (clk_i_top_rx       ),
    .rsnt_i_rx          (rstn_i_top_rx      ),
    .data_i_serial_rx   (data_i_serial_top_rx),
    .baud_div_i_rx      (baud_div_top_rx    ),
    .active_o_rx        (active_i_top_rx    ),
    .data_o_rx          (data_o_rx          ),
    .done_o_rx          (done_o_rx          )); 
//////////////////////////////////////////////////////////////////////////////////////
fifo #(
      .B    (DATA_WIDTH     ),  
      .W    (ADDR_WIDTH_FIFO)   
)fifo_uart_rx_inst(
      .clk            (clk_i_top_rx         ),
      .rstn_i         (rstn_i_top_rx        ),
      .rd             (fifo_rd              ),
      .wr             (fifo_wr              ),
      .w_data         (fifo_w_data          ), //8
      .empty          (empty_o_top_rx       ),
      .full           (full_o_top_rx        ), //o
      .r_data         (fifo_r_data          )   //8
   );    
endmodule