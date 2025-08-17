module multiplier_4bit (
    input  wire [3:0] A,
    input  wire [3:0] B,
    output wire [7:0] P
);

    wire [15:0] pp; // partial products
    assign pp[ 0] = A[0] & B[0];
    assign pp[ 1] = A[1] & B[0];
    assign pp[ 2] = A[2] & B[0];
    assign pp[ 3] = A[3] & B[0];
    assign pp[ 4] = A[0] & B[1];
    assign pp[ 5] = A[1] & B[1];
    assign pp[ 6] = A[2] & B[1];
    assign pp[ 7] = A[3] & B[1];
    assign pp[ 8] = A[0] & B[2];
    assign pp[ 9] = A[1] & B[2];
    assign pp[10] = A[2] & B[2];
    assign pp[11] = A[3] & B[2];
    assign pp[12] = A[0] & B[3];
    assign pp[13] = A[1] & B[3];
    assign pp[14] = A[2] & B[3];
    assign pp[15] = A[3] & B[3];

    // Ara kablolar
    wire s1, c1, s2, c2, s3, c3, s4, c4, s5, c5, s6, c6, s7, c7, s8, c8;
    wire s9, c9, s10, c10, s11, c11, s12, c12, s13, c13;

    // P[0]
    assign P[0] = pp[0];

    // 1. sýra
    half_adder ha1 (pp[1], pp[4], s1, c1);
    full_adder fa1 (pp[2], pp[5], c1, s2, c2);
    full_adder fa2 (pp[3], pp[6], c2, s3, c3);
    half_adder ha2 (pp[7], c3, s4, c4);

    // 2. sýra
    half_adder ha3 (s2, pp[8], s5, c5);
    full_adder fa3 (s3, pp[9], c5, s6, c6);
    full_adder fa4 (s4, pp[10], c6, s7, c7);
    full_adder fa5 (c4, pp[11], c7, s8, c8);

    // 3. sýra
    half_adder ha4 (s6, pp[12], s9, c9);
    full_adder fa6 (s7, pp[13], c9, s10, c10);
    full_adder fa7 (s8, pp[14], c10, s11, c11);
    full_adder fa8 (c8, pp[15], c11, s12, c12);

    // Sonuç atamalarý
    assign P[1] = s1;
    assign P[2] = s5;
    assign P[3] = s9;
    assign P[4] = s10;
    assign P[5] = s11;
    assign P[6] = s12;
    assign P[7] = c12;

endmodule
