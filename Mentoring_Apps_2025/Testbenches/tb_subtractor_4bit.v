`timescale 1ns/1ps

module subtractor_4bit_tb;

  reg  [3:0] A, B;
  reg        Bin;
  wire [3:0] Difference;
  wire       Bout;

  subtractor_4bit dut (
    .A(A),
    .B(B),
    .Bin(Bin),
    .Difference(Difference),
    .Bout(Bout)
  );


  initial begin

    repeat (20) begin
      A   = $random % 16;   // 0..15 aras� de�er
      B   = $random % 16;   // 0..15 aras� de�er
      Bin = $random % 2;    // 0 veya 1
      #10;                  // 10 ns bekle
    end

    $finish;
  end

endmodule
