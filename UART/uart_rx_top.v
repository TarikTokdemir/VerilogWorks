// Create Date: 22.12.2024 01:21:11
`timescale 1ns / 1ps

module uart_rx_top(
      input  wire             clk_i,
      input  wire             rstn_i,
      input  wire             UART_Control_Register_rx_Active, // serial data controller
      input  wire             UART_Data_Read_Register_enable, // when the address comes from the master , enable = 1 
      input  wire             uart_rx_i,  // serial data in
      input  wire   [15:0]    baud_div,   // clkfreq/baudrate 
      output wire             UART_Status_Register_rx_full,     
      output wire             UART_Status_Register_rx_empty,    
      output reg     [7:0]    UART_Data_Read_Register_rdata, // is read when the related address is true
      output reg              UART_Data_Read
   );

   reg   [7:0] fifo_w_data;
   wire  [7:0] fifo_r_data;
   reg         fifo_rd;
   reg         fifo_wr;

   wire        rx_done_tick_o;  // 
   wire  [7:0] wire_uart_rx_dout_o;
   reg   [7:0] cntr;

   reg [3:0] state;
   parameter S_IDLE        = 4'b0001;
   parameter S_FIFO_WRITE  = 4'b0010;
   parameter S_FIFO_READ   = 4'b0100;

   always @(posedge clk_i, negedge rstn_i) begin
      if (!rstn_i) begin
         fifo_wr           <= 1'b0;
         fifo_w_data       <= 8'h00;
         cntr              <= 8'h00;
         fifo_rd           <= 1'b0;
         state             <= S_IDLE;
      end else begin
         
         fifo_wr <= 1'b0;
         if (rx_done_tick_o && !UART_Status_Register_rx_full && UART_Control_Register_rx_Active) begin 
            fifo_wr         <= 1'b1; 
            fifo_w_data     <= wire_uart_rx_dout_o; 
         end

         fifo_rd           <= 1'b0;
         UART_Data_Read  <= 1'b0;
         case (state) 
            S_IDLE: begin
               if (UART_Data_Read_Register_enable && !UART_Status_Register_rx_empty) begin // bos olmamasýna dikkat et, bos ise okuyacagin veri yok cunku
                  fifo_rd     <= 1'b1;
                  UART_Data_Read_Register_rdata  <= fifo_r_data;
                  state       <= S_FIFO_READ;
                  cntr        <= 0;
               end
            end

            S_FIFO_READ: begin
               UART_Data_Read  <= 1'b1;
               state    <= S_IDLE;
            end
         endcase
      end
   end 

   uart_rx uart_rx_Inst (
      .clk_i          (clk_i                          ),
      .rstn_i         (rstn_i                         ),
      .rx_i           (uart_rx_i                      ),
      .baud_div       (baud_div                       ), 
      .dout_o         (wire_uart_rx_dout_o            ),
      .rx_done_tick_o (rx_done_tick_o                 )
   );

   fifo # (
      .B(8),  
      .W(5)   
   )
   fifo_uart_rx_Inst
   (
      .clk            (clk_i                          ),
      .rstn_i         (rstn_i                         ),
      .rd             (fifo_rd                        ),
      .wr             (fifo_wr                        ),
      .w_data         (fifo_w_data                    ),
      .empty          (UART_Status_Register_rx_empty    ),
      .full           (UART_Status_Register_rx_full     ),
      .r_data         (fifo_r_data                    )
   );
endmodule