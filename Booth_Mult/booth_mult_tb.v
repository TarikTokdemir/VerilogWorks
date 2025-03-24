`timescale 1ns / 1ps

module tb_booth_mult;

parameter DATA_WIDTH = 8;

reg clk_i_mult, rstn_i_mult, en_i_mult;
reg [DATA_WIDTH-1:0] A, B;
wire [DATA_WIDTH*2-1:0] result_o;
wire mult_done_o;
    
    booth_mult #(
        .DATA_WIDTH(DATA_WIDTH)
    ) uut (
        .clk_i_mult(clk_i_mult),
        .rstn_i_mult(rstn_i_mult),
        .en_i_mult(en_i_mult),
        .A(A),
        .B(B),
        .result_o(result_o),
        .mult_done_o(mult_done_o)
    );
    
    initial begin
        clk_i_mult = 0;
        forever #5 clk_i_mult = ~clk_i_mult;
    end
    
    initial begin
        rstn_i_mult = 0;
        en_i_mult   = 0;
        A           = 0;
        B           = 0;
        
        #20;
        rstn_i_mult = 1;  
        #10;
        
        A = 8'd3;
        B = 8'd5;
        en_i_mult = 1;  
        #10;
        
        wait (mult_done_o == 1);
        $display("Test 1: A = %d, B = %d, result = %d", A, B, result_o);
        en_i_mult = 0 ;
        
        #20;
        en_i_mult = 1;
        A = 8'd7;
        B = 8'd9;
        
        wait (mult_done_o == 1);
        $display("Test 2: A = %d, B = %d, result = %d", A, B, result_o);
        en_i_mult = 0 ;
        
        #20;
        en_i_mult = 1;
        A = 8'd255;
        B = 8'd1;
        
        wait (mult_done_o == 1);
        $display("Test 2: A = %d, B = %d, result = %d", A, B, result_o);
        en_i_mult = 0 ;
        
        #20;
        en_i_mult = 1;
        A = 8'd255;
        B = 8'd0;
        
        wait (mult_done_o == 1);
        $display("Test 2: A = %d, B = %d, result = %d", A, B, result_o);
        en_i_mult = 0 ;
        
        #20;
        en_i_mult = 1;
        A = 8'd0;
        B = 8'd255;
        
        wait (mult_done_o == 1);
        $display("Test 2: A = %d, B = %d, result = %d", A, B, result_o);
        en_i_mult = 0 ;
        
        #20;
        en_i_mult = 1;
        A = 8'd255;
        B = 8'd254;
        
        wait (mult_done_o == 1);
        $display("Test 2: A = %d, B = %d, result = %d", A, B, result_o);
        en_i_mult = 0 ;

        #20;
        $finish;
    end

endmodule
