// Create Date: 22.12.2024 13:03:06

`timescale 1ns / 1ps
module uart_rx_top_tb();

parameter W = (uart_rx_top_uut.fifo_uart_rx_Inst.W); 
parameter B = (uart_rx_top_uut.fifo_uart_rx_Inst.B); 

reg         clk_i;
reg         rstn_i;
reg         UART_Control_Register_rx_Active;
reg         UART_Data_Read_Register_enable;
reg [15:0]  baud_div;
reg         rx_serial_data;

wire        Full_tb;
wire        Empty_tb;
wire [7:0]  UART_Data_Read_Register_rdata_tb;
wire        UART_Data_Read_tb;

integer i;
integer pass_count = 0;
integer fail_count = 0;

reg [7:0] verifyarray [0:2**W-1]; 


initial begin
    clk_i = 1;
    forever #5 clk_i = ~clk_i;
end

initial begin
    rstn_i = 0;
    UART_Control_Register_rx_Active = 0;
    UART_Data_Read_Register_enable = 0;
    baud_div = 16'd868;
    rx_serial_data = 1;
    
    #20;
    rstn_i = 1;
    pass_count = 0;
    fail_count = 0;

    if (Full_tb == 1)
        $display("FIFO: FULL");
    else if (Empty_tb == 1)
        $display("FIFO: EMPTY");
    else
        $display("FIFO: NOT EMPTY OR FULL");

    RX_receive_and_check();

    #100;
    $display("\nTest Summary:");
    $display("Total PASSES: %0d", pass_count);
    $display("Total FAILS : %0d", fail_count);

    $finish;
end

task RX_receive_and_check;
    begin
        $display("=== RX_receive_and_check Task ===");
        UART_Control_Register_rx_Active = 1;

        for (i = 0; i < 2**W; i = i + 1) begin
            rx_serial_data = 0;
            #((baud_div) * 10);
            verifyarray[i] = $random % 256;
            for (int bit_index = 0; bit_index < 8; bit_index = bit_index + 1) begin
                rx_serial_data = verifyarray[i][bit_index];
                #((baud_div) * 10);
            end

            rx_serial_data = 1;
            #((baud_div) * 10);
            wait (UART_Data_Read_tb == 1);
            UART_Data_Read_Register_enable = 1;
            #10;
            UART_Data_Read_Register_enable = 0;
            if (UART_Data_Read_Register_rdata_tb === verifyarray[i]) begin
                pass_count = pass_count + 1;
                $display("PASS: Sent[%0d] = %b, Received = %b", i, verifyarray[i], UART_Data_Read_Register_rdata_tb);
            end else begin
                fail_count = fail_count + 1;
                $display("FAIL: Sent[%0d] = %b, Received = %b", i, verifyarray[i], UART_Data_Read_Register_rdata_tb);
            end
        end
        UART_Control_Register_rx_Active = 0;
    end
endtask

uart_rx_top uart_rx_top_uut (
    .clk_i(clk_i),
    .rstn_i(rstn_i),
    .UART_Control_Register_rx_Active(UART_Control_Register_rx_Active),
    .UART_Data_Read_Register_enable(UART_Data_Read_Register_enable),
    .uart_rx_i(rx_serial_data),
    .baud_div(baud_div),
    .UART_Status_Register_rx_full(Full_tb),
    .UART_Status_Register_rx_empty(Empty_tb),
    .UART_Data_Read_Register_rdata(UART_Data_Read_Register_rdata_tb),
    .UART_Data_Read(UART_Data_Read_tb)
);

endmodule

