`timescale 1ns / 1ps


module ALU_8bit #(
    parameter DATA_WIDTH = 8 ,
    parameter N = DATA_WIDTH
)(
    input  wire [N-1:0] A,
    input  wire [N-1:0] B,
    input  wire         Cin,  
    input  wire         Bin,  
    input  wire [1:0]   sel,  

    output wire [(2*N)-1:0] Y,
    output wire Cout,
    output wire Bout,
    output wire gr,
    output wire le,
    output wire eq
);
    wire [N-1:0]  sum_w;
    wire [N-1:0]  diff_w;
    wire [2*N-1:0] sq_w;

    adder_parallel #(.N(N)) adder_inst (
        .A   (A),
        .B   (B),
        .Cin (Cin),
        .Cout(Cout),
        .Sum (sum_w)
    );

    subtractor_parallel #(.N(N)) subtractor_inst (
        .A          (A),
        .B          (B),
        .Bin        (Bin),
        .Difference (diff_w),
        .Bout       (Bout)
    );

    comparator #(.N(N)) comparator_inst (
        .A  (A),
        .B  (B),
        .gr (gr),
        .le (le),
        .eq (eq)
    );
    
    Square_parametic #(.WIDTH(N)) Square_inst (
        .X (A),
        .Y (sq_w)
    );
    
    wire [2*N-1:0] D_ADD = {{N{1'b0}}, sum_w};
    wire [2*N-1:0] D_SUB = {{N{1'b0}}, diff_w};
    wire [2*N-1:0] D_CMP = {{(2*N-3){1'b0}}, gr, le, eq};
    wire [2*N-1:0] D_SQR = sq_w;

    Mux_4x1 #(.W(2*N)) Mux_4x1_inst (
        .D0 (D_ADD),
        .D1 (D_SUB),
        .D2 (D_CMP),
        .D3 (D_SQR),
        .sel(sel),
        .Y  (Y)
    );

endmodule
