`timescale 1ns/1ps

module carpma(
    input        clk,
    input        rst_n,
    input        start,
    input  [3:0] multiplicand, // çarpýlan
    input  [3:0] multiplier,   // çarpan
    output [7:0] product,      // sonuç
    output reg   done
);
    // Durum kodlarý
    localparam S_IDLE  = 2'b00;
    localparam S_CHECK = 2'b01;
    localparam S_SHIFT = 2'b10;
    localparam S_DONE  = 2'b11;

    reg [1:0] state, next_state;
    reg [7:0] mcand;    // geniþletilmiþ çarpýlan
    reg [3:0] mplier;   // çarpan
    reg [7:0] prod;     // ürün
    reg [2:0] count;    // adým sayacý (0..4)

    assign product = prod;

    // Durum geçiþleri
    always @(*) begin
        next_state = state;
        case (state)
            S_IDLE:  if (start) next_state = S_CHECK;
            S_CHECK: next_state = S_SHIFT;
            S_SHIFT: next_state = (count == 3'd3) ? S_DONE : S_CHECK;
            S_DONE:  next_state = S_IDLE;
        endcase
    end

    // Durum ve veri yolu güncelleme
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state   <= S_IDLE;
            prod    <= 8'b0;
            mcand   <= 8'b0;
            mplier  <= 4'b0;
            count   <= 3'b0;
            done    <= 1'b0;
        end else begin
            state <= next_state;
            case (state)
                S_IDLE: begin
                    done   <= 1'b0;
                    if (start) begin
                        prod   <= 8'b0;
                        mcand  <= {4'b0000, multiplicand};
                        mplier <= multiplier;
                        count  <= 3'b0;
                    end
                end
                S_CHECK: begin
                    if (mplier[0])
                        prod <= prod + mcand; // LSB=1 ise ekle
                end
                S_SHIFT: begin
                    mcand  <= mcand << 1; // sola kaydýr
                    mplier <= mplier >> 1; // saða kaydýr
                    count  <= count + 1'b1;
                end
                S_DONE: begin
                    done <= 1'b1; // sonuç hazýr
                end
            endcase
        end
    end
endmodule
