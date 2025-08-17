`timescale 1ns/1ps

module tb_carpma2;
    reg clk = 0;
    reg rst_n = 0;
    reg start = 0;
    reg [3:0] multiplicand;
    reg [3:0] multiplier;
    wire [7:0] product;
    wire done;

    // DUT (Device Under Test)
    carpma2 dut (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .multiplicand(multiplicand),
        .multiplier(multiplier),
        .product(product),
        .done(done)
    );

    // Clock üretimi
    always #5 clk = ~clk; // 100 MHz clock (10 ns periyod)

    // Görev: çarpma testi yap
    task run_test;
        input [3:0] a, b;
        begin
            @(negedge clk);
            multiplicand = a;
            multiplier   = b;
            start = 1'b1;
            @(negedge clk);
            start = 1'b0;

            // done=1 olana kadar bekle
            wait(done);
            @(posedge clk); // done yakalandýktan sonra bir clock bekle
            $display("Test: %0d (0x%0h) x %0d (0x%0h) = %0d (0x%0h) | Beklenen = %0d",
                     a, a, b, b, product, product, a*b);
        end
    endtask

    initial begin
        // VCD dalga kaydý (opsiyonel)
        $dumpfile("tb_carpma2.vcd");
        $dumpvars(0, tb_carpma2);

        // Reset
        multiplicand = 0;
        multiplier   = 0;
        #12 rst_n = 1;

        // Testler
        run_test(4'd3, 4'd2);  // 3 x 2 = 6
        run_test(4'd7, 4'd5);  // 7 x 5 = 35
        run_test(4'd15, 4'd15); // 15 x 15 = 225
        run_test(4'd8, 4'd4);  // 8 x 4 = 32
        run_test(4'd9, 4'd7);  // 9 x 7 = 63

        #20;
        $display("Tüm testler tamamlandý.");
        $finish;
    end
endmodule
