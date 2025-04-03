`timescale 1ns / 1ps

module tb_top_uart_rx;

    parameter DATA_WIDTH = 8;
    parameter FIFO_DEPTH = 32;
    parameter ADDR_WIDTH_FIFO = $clog2(FIFO_DEPTH);

    reg clk_i_top_rx;
    reg rstn_i_top_rx;
    reg active_i_top_rx;
    reg data_i_serial_top_rx;
    reg [DATA_WIDTH*2:0] baud_div_top_rx;

    wire full_o_top_rx;
    wire empty_o_top_rx;

    top_uart_rx #(
        .DATA_WIDTH(DATA_WIDTH),
        .FIFO_DEPTH(FIFO_DEPTH)
    ) DUT (
        .clk_i_top_rx(clk_i_top_rx),
        .rstn_i_top_rx(rstn_i_top_rx),
        .active_i_top_rx(active_i_top_rx),
        .data_i_serial_top_rx(data_i_serial_top_rx),
        .baud_div_top_rx(baud_div_top_rx),
        
        .full_o_top_rx(full_o_top_rx),
        .empty_o_top_rx(empty_o_top_rx)
    );

    always #5 clk_i_top_rx = ~clk_i_top_rx; 


reg [7:0] random_data ; 
integer i=0,j=0, pass_counter = 0, fail_counter = 0;
    initial begin
        clk_i_top_rx    = 1;
        rstn_i_top_rx   = 0;
        active_i_top_rx = 0;
        data_i_serial_top_rx   = 1; 
        baud_div_top_rx = 868; 

        #20;
        rstn_i_top_rx = 1;
        active_i_top_rx = 1;
        
        repeat (32) begin
            random_data = $urandom_range(0, 255);
            uart_send_byte(random_data);
            
            $display("Data Sent     = %0h (%b)", random_data, random_data);
            #20;
            $display("FIFO[%0d]= %0h (%b)", i, DUT.fifo_uart_rx_inst.array_reg[i], DUT.fifo_uart_rx_inst.array_reg[i]);

            if (random_data === DUT.fifo_uart_rx_inst.array_reg[i]) begin
                $display("*** PASS ***\n");
                pass_counter = pass_counter + 1;
            end else begin
                $display("*** FAIL ***\n");
                fail_counter = fail_counter + 1;
            end
            i = i+1 ;
        end
        
        $display("TOTAL PASS: %0d, TOTAL FAIL: %0d", pass_counter, fail_counter);

        $finish;
        
    end
    
    task uart_send_byte(input [7:0] data);
        begin
            data_i_serial_top_rx = 0;
            #(baud_div_top_rx*10/2);
            #10;
            
            for (j = 0; j < 8; j = j + 1) begin
                data_i_serial_top_rx = data[j];
                #(baud_div_top_rx*10);
            end
            
            data_i_serial_top_rx = 1;
            #(baud_div_top_rx*10);
        end
    endtask

endmodule
