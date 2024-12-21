// Create Date: 12.12.2024 14:30:12
`timescale 1ns / 1ps

module uart_tx_top(
input  wire      clk_i,
input  wire      rstn_i,
input  wire[15:0]baud_div,                       // clkfreq/baudrate 
input  wire      UART_Control_Register_tx_Active, // if UART_Control_Register_tx = 0 dont send data to outside 
input  wire      UART_Data_Write_Register_enable, // when the address comes from the master , enable = 1 and data write to buffer
input  wire[7:0] UART_Data_Write_Register_wdata,  // Data to be written into fifo. when tx_Active = 1 , data send out from fifo
output wire      UART_Status_Register_tx_full,  
output wire      UART_Status_Register_tx_empty,    
output wire      UART_tx_o,                      // serial data out
output reg       UART_Data_Send_Tick
);

   reg   [7:0]    fifo_w_data;
   wire  [7:0]    fifo_r_data;
   reg            fifo_rd;
   reg            fifo_wr;

   reg   [7:0]    din_i;
   reg            tx_start_i;
   wire           tx_done_tick_o;

   reg [3:0] state;
   parameter S_IDLE                    = 4'b0001;
   parameter S_UART_TRANSMIT           = 4'b0010;
   parameter S_FIFO_READ               = 4'b0100;
   parameter S_UART_DURUM_YAZMACI      = 4'b1000;
   
   always @(posedge clk_i, negedge rstn_i) begin  // writing to fifo
      if (!rstn_i) begin
         fifo_wr <= 1'b0;
      end 
      else begin
         fifo_wr <= 1'b0;
         if ( UART_Data_Write_Register_enable && !UART_Status_Register_tx_full ) begin  //  enable signal comes with address  
            fifo_wr     <= 1'b1;                                // fifo write open
            fifo_w_data <= UART_Data_Write_Register_wdata;      //  write data to FIFO  . write directly through instantiate
         end
      end
   end

   always @(posedge clk_i, negedge rstn_i)
   begin
      if (!rstn_i) begin
         tx_start_i  <= 1'b0;
         fifo_rd     <= 1'b0;
         state       <= S_IDLE;
      end
      else begin
         tx_start_i  <= 1'b0;
         fifo_rd     <= 1'b0;
         case (state)
            S_IDLE: begin
               if ( UART_Control_Register_tx_Active && !UART_Status_Register_tx_empty ) begin
                    UART_Data_Send_Tick <= 1'b0;
                  fifo_rd     <= 1'b1;
                  din_i       <= fifo_r_data; // prepare data for S_FIFO_READ state and sync
                  state       <= S_FIFO_READ;
               end
            end

            S_UART_TRANSMIT: begin
               if (tx_done_tick_o) begin 
                  UART_Data_Send_Tick <= 1'b1;
                  state   <= S_IDLE;
               end
            end
            
            S_FIFO_READ: begin
               tx_start_i  <= 1'b1;
               state       <= S_UART_TRANSMIT;
            end
            
            default: begin
               state   <= S_IDLE;
            end
         endcase
      end
   end

   uart_tx uart_tx_Inst (
      .clk_i            (clk_i                              ),
      .rstn_i           (rstn_i                             ),
      .din_i            (din_i                              ),
      .baud_div         (baud_div                           ), 
      .tx_start_i       (tx_start_i                         ),
      .tx_o             (UART_tx_o                          ),
      .tx_done_tick_o   (tx_done_tick_o                     )
   );

   fifo # (
      .B(8),  
      .W(5)  
   )
   fifo_uart_rx_Inst (
      .clk                 (clk_i                           ),
      .rstn_i              (rstn_i                          ),
      .rd                  (fifo_rd                         ),
      .wr                  (fifo_wr                         ), 
      .w_data              (fifo_w_data                     ),
      .empty               (UART_Status_Register_tx_empty     ),
      .full                (UART_Status_Register_tx_full      ),
      .r_data              (fifo_r_data                     )
   );
endmodule