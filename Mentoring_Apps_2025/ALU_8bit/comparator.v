`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.08.2025 23:51:11
// Design Name: 
// Module Name: comparator
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


`timescale 1ns / 1ps


module comparator #(
parameter N = 8
) (
    input  wire [N-1:0] A, 
    input  wire [N-1:0] B, 
    output   reg gr,        // A > B
    output   reg le,        // A < B
    output   reg eq         // A == B
 );

    always @(*) begin
        gr = 0;
        le = 0;
        eq = 0;

        if (A > B) begin
            gr = 1;
        end else if (A < B) begin
            le = 1;
        end else begin
            eq = 1;
        end
    end

endmodule
  
      
