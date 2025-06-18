// Create Date: 18.06.2025 10:09:41
`timescale 1ns / 1ps

module median_tb;

    parameter DATA_SAYISI = 25;

    reg         clk;
    reg         rstn;
    reg         en;
    reg  [7:0]  data_in;
    wire [7:0]  data_out;
    wire        done;

    median #(
        .DATA_SAYISI(DATA_SAYISI)
    ) dut (
        .clk_i_median(clk),
        .rstn_i_median(rstn),
        .en_i_median(en),
        .data_i_median(data_in),
        .data_o_median(data_out),
        .median_done(done)
    );

    always #5 clk = ~clk;

    // Test data
    reg [7:0] test_data [0:DATA_SAYISI-1];
    integer i;

    initial begin
        clk     = 0;
        rstn    = 0;
        en      = 0;
        data_in = 0;

        #50 ;
         
        rstn = 1 ;
        en = 1 ; 
        
        repeat (25) begin
            data_in = $random % 256 ;
            #10;
        end
        en = 0 ;
        wait(done) ;
        en = 1 ;
        repeat (25) begin
            data_in = $random % 256 ;
            #10;
        end
        wait(done) ;
        $finish;
    end

endmodule

