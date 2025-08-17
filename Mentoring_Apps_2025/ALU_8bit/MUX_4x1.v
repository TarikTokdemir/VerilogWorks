`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.08.2025 23:38:19
// Design Name: 
// Module Name: MUX_4x1
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module Mux_4x1 #(
    parameter  W = 16
)(
    input  wire [W-1:0] D0,
    input  wire [W-1:0] D1,
    input  wire [W-1:0] D2,
    input  wire [W-1:0] D3,
    input  wire [1:0]   sel,
    output reg  [W-1:0] Y
);
    always @* begin
        case (sel)
            2'b00: Y = D0;
            2'b01: Y = D1;
            2'b10: Y = D2;
            2'b11: Y = D3;
            default: Y = {W{1'b0}};
        endcase
    end
endmodule

