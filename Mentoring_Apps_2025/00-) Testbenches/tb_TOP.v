module tb_TOP;
    reg clk;
    reg rst;
    wire ok_o;
    wire [6:0] ok_data_o;

    TOP dut(
        .i_clk_top(clk),
        .i_rst_top(rst),
        .ok_o(ok_o),
        .ok_data_o(ok_data_o)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 100 MHz
    end

    initial begin
        rst = 1;
        #20;
        rst = 0;

        #2000;
        $finish;
    end

    initial begin
        $monitor("T=%0t ns | STATE OK=%b DATA=%b",
                 $time, ok_o, ok_data_o);
    end

endmodule