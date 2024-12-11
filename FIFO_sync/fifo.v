`timescale 1ns / 1ps

module fifo
   # (
      parameter B = 8,  // number of bits in a word
      parameter W = 4   // number of address bits
   )(
      input  wire          clk, 
      input  wire          rstn_i, 
      input  wire          rd, wr,
      input  wire [B-1:0]  w_data,
      output wire          empty,
      output wire          full,
      output wire [B-1:0]  r_data
   );

   reg [B-1:0] array_reg [2**W-1:0]; // register array
   reg [W-1:0] w_ptr_reg, w_ptr_next, w_ptr_succ;
   reg [W-1:0] r_ptr_reg, r_ptr_next, r_ptr_succ;
   reg full_reg, empty_reg, full_next, empty_next;

   wire wr_en;

  
   always @(posedge clk) begin
      if (wr_en) begin
         array_reg[w_ptr_reg] <= w_data;
      end
   end

   assign r_data = array_reg [r_ptr_reg];
   assign wr_en = wr & ~full_reg;

   always @ (posedge clk , negedge rstn_i) begin 
      if (!rstn_i) begin
         w_ptr_reg   <= 0;
         r_ptr_reg   <= 0;
         full_reg    <= 1'b0;
         empty_reg   <= 1'b1;
      end else begin
         w_ptr_reg   <= w_ptr_next;
         r_ptr_reg   <= r_ptr_next;
         full_reg    <= full_next;
         empty_reg   <= empty_next;
      end
   end

   always @(*) begin 
      
      w_ptr_succ = w_ptr_reg + 1;
      r_ptr_succ = r_ptr_reg + 1;

      w_ptr_next = w_ptr_reg;
      r_ptr_next = r_ptr_reg;
      full_next = full_reg;
      empty_next = empty_reg;
      case ({wr, rd})
         // 2'bOO: no op
         2'b01: begin// read
            if (~empty_reg) begin// not empty
               r_ptr_next = r_ptr_succ ;
               full_next = 1'b0;
               if (r_ptr_succ == w_ptr_reg) begin 
                  empty_next = 1'b1;
               end
            end
         end

         2'b10: begin // write
            w_ptr_next = w_ptr_succ ;
            empty_next = 1'b0;
            if (w_ptr_succ == r_ptr_reg) begin 
               full_next = 1'b1;
            end
         end

         2'b11: begin// write and read
            w_ptr_next = w_ptr_succ;
            r_ptr_next = r_ptr_succ ;
         end
      endcase
   end

   // output
   assign full    = full_reg;
   assign empty   = empty_reg;
endmodule

