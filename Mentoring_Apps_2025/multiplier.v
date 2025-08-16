`timescale 1ns / 1ps

module multiplier_parametic #(
    parameter  WIDTH = 8
)(
    input  wire [WIDTH-1:0]       A,
    input  wire [WIDTH-1:0]       B,
    output wire [(2*WIDTH)-1:0]   P
);
    wire [(2*WIDTH)-1:0] base = {{WIDTH{1'b0}}, A};

    reg  [(2*WIDTH)-1:0] acc;
    integer i;

    always @* begin
        acc = { (2*WIDTH){1'b0} };
        for (i = 0; i < WIDTH; i = i + 1) begin
            if (B[i]) acc = acc + (base << i);
        end
    end

    assign P = acc;
endmodule

