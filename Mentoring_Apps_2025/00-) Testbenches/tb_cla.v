`timescale 1ns / 1ps
module tb_cla;

    reg  [3:0] a, b;
    reg        cin;
    wire [4:0] sum;

    cla_adder_4 dut(
        .a_in(a), 
        .b_in(b), 
        .c_in(cin), 
        .sum_out(sum)
    );

    initial begin
        #100;
        cin = 1'b0;
        
        repeat (10) begin
            #5 ;
            {a,b} = $random;
            $display("a=%b b=%b cin=%b  ->  {cout,sum}=%b", a,b,cin,sum);
            #5 ; 
        end
        
        #10 $finish;
    end
endmodule
