`timescale 1ns/1ps

module tb;
    reg clk = 0, rst_n = 0, start = 0;
    reg [3:0] A, B;
    wire [7:0] P;
    wire done;

    carpma dut (
        .clk(clk), .rst_n(rst_n), .start(start),
        .multiplicand(A), .multiplier(B),
        .product(P), .done(done)
    );

    always #5 clk = ~clk;

    initial begin
        // Reset
        #10 rst_n = 1;

        // Görseldeki örnek: 1011 × 1110
        @(negedge clk);
        A = 4'b1011; // 11
        B = 4'b1110; // 14
        start = 1;
        @(negedge clk) start = 0;

        // Sonuç bekleme
        wait(done);
        $display("A=%0d B=%0d => P=%0d (%b)", A, B, P, P);

        #20 $finish;
    end
endmodule