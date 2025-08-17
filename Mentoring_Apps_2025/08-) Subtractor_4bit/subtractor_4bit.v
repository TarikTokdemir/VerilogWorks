`timescale 1ns / 1ps

module subtractor_4bit (
    input  [3:0] A,
    input  [3:0] B,
    input        Bin,
    output [3:0] Difference,
    output       Bout
);
    wire [4:0] borrow; // 0. eleman Bin, 4. eleman Bout olacak

    assign borrow[0] = Bin; // ilk borrow giri�i d��ar�dan

    genvar i;
    generate
        for (i = 0; i < 4; i = i + 1) begin
            full_subtractor fs (
                .A(A[i]),
                .B(B[i]),
                .Bin(borrow[i]),         // her bitin borrow giri�i
                .Difference(Difference[i]),
                .Borrow(borrow[i+1])     // ��kan borrow bir sonraki bite gider
            );
        end
    endgenerate

    assign Bout = borrow[4]; // en �st bitten ��kan borrow
endmodule