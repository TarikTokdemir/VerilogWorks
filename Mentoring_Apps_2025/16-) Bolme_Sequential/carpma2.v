`timescale 1ns/1ps

module carpma2 (
    input              clk,
    input              rst_n,
    input              start,
    input      [3:0]   multiplicand,  // �arp�lan
    input      [3:0]   multiplier,    // �arpan
    output reg [7:0]   product,       // sonu�
    output reg         done
);

    // Durum kodlar�
    localparam S_IDLE  = 2'b00;
    localparam S_CHECK = 2'b01;
    localparam S_SHIFT = 2'b10;
    localparam S_DONE  = 2'b11;

    reg [1:0] state, next_state;
    reg [3:0] A;          // �arp�lan
    reg [8:0] result;     // �ift uzunluklu sonu� + ta�ma biti (9 bit)
    reg [2:0] count;      // tekrar sayac� (0..4)

    // Next-state logic
    always @(*) begin
        next_state = state;
        case (state)
            S_IDLE : if (start) next_state = S_CHECK;
            S_CHECK: next_state = S_SHIFT;
            S_SHIFT: next_state = (count == 3'd3) ? S_DONE : S_CHECK;
            S_DONE : next_state = S_IDLE;
        endcase
    end

    // State and datapath
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state   <= S_IDLE;
            A       <= 4'b0;
            result  <= 9'b0;
            count   <= 3'b0;
            product <= 8'b0;
            done    <= 1'b0;
        end else begin
            state <= next_state;
            case (state)
                S_IDLE: begin
                    done   <= 1'b0;
                    if (start) begin
                        A       <= multiplicand;
                        result  <= {5'b00000, multiplier}; // �st yar�=0, alt yar�=�arpan
                        count   <= 3'd0;
                    end
                end

                S_CHECK: begin
                    if (result[0] == 1'b1) begin
                        // �st yar�ya �arp�lan� ekle (ta�ma otomatik olarak result[8]'de tutulur)
                        result[8:4] <= result[8:4] + A;
                    end
                end

                S_SHIFT: begin
                    // 1 bit sa�a kayd�rma (9 bit)
                    result <= result >> 1;
                    count  <= count + 1'b1;
                end

                S_DONE: begin
                    done    <= 1'b1;
                    product <= result[7:0]; // sadece 8 bitlik k�sm� ��k��a ver
                end
            endcase
        end
    end

endmodule
