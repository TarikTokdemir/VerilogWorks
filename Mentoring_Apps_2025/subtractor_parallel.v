
module subtractor_parallel #(
parameter N = 8
) (
    input  wire [N-1:0] A, B,
    input  wire         Bin,
    output wire [N-1:0] Difference,
    output wire         Bout
);

    wire [N:0] borrow;
    assign borrow[0] = Bin;

    genvar i;
    generate
        for (i = 0; i < N; i = i + 1) begin
            full_subtractor fs (
                .A          (A[i]),
                .B          (B[i]),
                .Bin        (borrow[i]),
                .Difference (Difference[i]),
                .Borrow     (borrow[i+1])
            );
        end
    endgenerate

    assign Bout = borrow[N];

endmodule

