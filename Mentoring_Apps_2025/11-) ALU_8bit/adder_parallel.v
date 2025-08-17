module adder_parallel #(
    parameter N = 8
) (
    input wire [N-1:0] A, B,
    input wire Cin,

    output wire Cout,
    output wire [N-1:0] Sum
);

    wire [N:0] carry;
    assign carry[0] = Cin;

    genvar i;
    generate
        for (i = 0; i < N; i = i + 1) begin
            full_adder fa(
                .a    (A[i]),
                .b    (B[i]),
                .cin  (carry[i]),
                .sum  (Sum[i]),
                .cout (carry[i+1])
            );
        end
    endgenerate

    assign Cout = carry[N];

endmodule
