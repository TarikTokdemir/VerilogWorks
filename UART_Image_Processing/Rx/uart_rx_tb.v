`timescale 1ns / 1ps

module uart_rx_tb;

    parameter DATA_WIDTH = 8;

    reg                   clk_i_rx;
    reg                   rsnt_i_rx;
    reg                   data_i_serial_rx;
    reg  [DATA_WIDTH*2:0] baud_div_i_rx;

    wire                  active_o_rx;
    wire [DATA_WIDTH-1:0] data_o_rx;
    wire                  done_o_rx;

    uart_rx #(
        .DATA_WIDTH(DATA_WIDTH)
    ) uut (
        .clk_i_rx(clk_i_rx),
        .rsnt_i_rx(rsnt_i_rx),
        .data_i_serial_rx(data_i_serial_rx),
        .baud_div_i_rx(baud_div_i_rx),
        .active_o_rx(active_o_rx),
        .data_o_rx(data_o_rx),
        .done_o_rx(done_o_rx)
    );

    always #5 clk_i_rx = ~clk_i_rx; 

    reg [7:0] data_send;
    integer i,j, pass_counter = 0, fail_counter = 0;
    reg [7:0] array [0:999] ;
    
    initial begin
        clk_i_rx = 1;
        rsnt_i_rx = 0;
        data_i_serial_rx = 1;
        baud_div_i_rx = 868; 
        
        for (i=0 ; i<1000 ; i=i+1) begin
            array[i] = $random % 256;
        end
        i= 0; 
        #20 ;
        
        rsnt_i_rx = 1;

        $display("----- UART RX Testbench Start -----");

        repeat (1000) begin
            data_send = array[i] ;
            data_i_serial_rx = 0 ;
            #10; 
            #(baud_div_i_rx*10/2);
            
            
            for (j=0 ; j<8 ; j=j+1) begin
                data_i_serial_rx  = data_send[j] ;
                #(baud_div_i_rx*10);
            end
            
            
            wait (done_o_rx == 1);
            #10;
            $display("Data Sent     = 0x%0h (%b)", data_send, data_send);
            $display("Data Received = 0x%0h (%b)", data_o_rx, data_o_rx);

            if (data_send === data_o_rx) begin
                $display("*** PASS ***\n");
                pass_counter = pass_counter + 1;
            end else begin
                $display("*** FAIL ***\n");
                fail_counter = fail_counter + 1;
            end
            i = i+1 ;
        end

        $display("TOTAL PASS: %0d, TOTAL FAIL: %0d", pass_counter, fail_counter);
        #20;
        $finish;
    end
endmodule
