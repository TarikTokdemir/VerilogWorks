// Create Date: 11.12.2024 11:59:45
`timescale 1ns / 1ps

module uart_rx (
    input  wire  		clk_i,
    input  wire  		rstn_i,
    input  wire  		rx_i,
    input  wire  [15:0] baud_div, // clkfreq/baudrate as input
    output wire  [7:0] 	dout_o,
    output reg   		rx_done_tick_o
);
    reg [3:0] state;
   parameter S_IDLE  = 4'b0001;
   parameter S_START = 4'b0010;
   parameter S_DATA  = 4'b0100;
   parameter S_STOP  = 4'b1000;

   integer bittimer = 0;
   integer bitcntr  = 0;
   reg [7:0] shreg  = 0;

   reg r_Rx_Data_R = 1'b1;                // Purpose: Double-register the incoming data.
   reg r_Rx_Data_R2 = 1'b1;               // This allows it to be used in the UART RX Clock Domain.
   reg r_Rx_Data   = 1'b1;                // (It removes problems caused by metastability)

   always @(posedge clk_i, negedge rstn_i) begin
      if (!rstn_i) begin
         r_Rx_Data_R  <= 1'b1;
         r_Rx_Data_R2 <= 1'b1;
         r_Rx_Data    <= 1'b1;
      end else begin
         r_Rx_Data_R    <= rx_i;
         r_Rx_Data_R2   <= r_Rx_Data_R;
         r_Rx_Data      <= r_Rx_Data_R2;
      end
   end

   always @(posedge clk_i, negedge rstn_i) begin
      if (!rstn_i) begin
         state	        <= S_IDLE;
         rx_done_tick_o	<= 0;
         bittimer		<= 0;
         bitcntr 	    <= 0;
         shreg           <= 8'h00;
      end else begin
         case (state)
               S_IDLE: begin
                  rx_done_tick_o	<= 0;
                  bittimer		<= 0;
                  if (r_Rx_Data == 1'b0) begin
                     state	<= S_START;
                  end
               end

               S_START : begin
                  if ( bittimer == baud_div/2-1 ) begin
                     state		<= S_DATA;
                     bittimer	<= 0;
                  end else begin
                     bittimer	<= bittimer + 1;
                  end
               end 

               S_DATA  : begin
                  if (bittimer == baud_div-1) begin
                     if ( bitcntr == 7 ) begin
                        state	<= S_STOP;
                        bitcntr	<= 0;
                     end else begin
                        bitcntr	<= bitcntr + 1;
                     end
                     shreg		<= {r_Rx_Data, (shreg[7:1])};
                     bittimer	<= 0;
                  end else begin
                     bittimer	<= bittimer + 1;
                  end
               end 

               S_STOP: begin
                  if (bittimer == baud_div-1) begin
                     state			<= S_IDLE;
                     bittimer		<= 0;
                     rx_done_tick_o	<= 1;
                  end else begin
                     bittimer	<= bittimer + 1;
                  end
               end

               default : begin 
                  state <= S_IDLE;
               end
         endcase
      end
   end

    assign dout_o = shreg;

endmodule // uart_rx