// Create Date: 12.12.2024 17:05:08
`timescale 1ns / 1ps
module uart_tx_top_tb();

parameter W = (uart_tx_top_uut.fifo_uart_rx_Inst.W) ; 
parameter B = (uart_tx_top_uut.fifo_uart_rx_Inst.B) ;
reg         clk_i;
reg         rstn_i;
reg [15:0]  baud_div;
reg         UART_Control_Register_tx_Active;
reg         UART_Data_Write_Register_enable;
reg [7:0]   UART_Data_Write_Register_wdata;

wire        Full_tb;
wire        Empty_tb;
wire        UART_tx_o_tb;
wire        UART_Data_Send_Tick_tb;

/*
uart da fifoya yazmak için "data write reg en" = 1 olmalý 
dýþarý veri seri çýkmasý için "control reg active " = 1 olmalý
fifonun içine yazýlacak data "UART_Data_Write_Register_wdata"
*/ 

/*
*** If you want to see the data sending step by step on the Tcl Console, 
*** you try "Run for ..ns" and enter these values(ns) then run : 
***   10  +  10  +  320  +  10  +  8680*8  +  8680*8*32
*** reset  reset FifoWrite  wait   TxSend     TxsendAll
*/

    initial begin
        clk_i = 1;
        forever #5 clk_i = ~clk_i;
    end

integer i;
integer pass_count = 0;
integer fail_count = 0;

reg [7:0] verifyarray [0:2**W-1]; // Random deðerlerin tutulduðu dizi
reg [7:0] buffer;                              // Tx_o'yu doðrulamak için kullanýlan buffer

    initial begin
        #1000;
        rstn_i = 0;
        baud_div = 16'd868;
        UART_Control_Register_tx_Active = 0;
        UART_Data_Write_Register_enable = 0;
        UART_Data_Write_Register_wdata = 8'd0;

        #10;
        rstn_i = 1;
        #10;
        
        buffer = 9'b0;
        pass_count = 0;
        fail_count = 0;
        
            if (Full_tb ==1 ) begin
                $display("FIFO: FULL");
            end 
            else if (Empty_tb == 1) begin 
                $display("FIFO: EMPTY");
            end
            else if (!Empty_tb & !Full_tb) begin 
                $display("FIFO: NOT EMPTY OR FULL");
            end
        write2FIFO();
        #10;
        
            if (Full_tb ==1 ) begin
                $display("FIFO: FULL");
            end 
            else if (Empty_tb == 1) begin 
                $display("FIFO: EMPTY");
            end
            else if (!Empty_tb & !Full_tb) begin 
                $display("FIFO: NOT EMPTY OR FULL");
            end

        #10;
        
        TX_senddata();
        
        #100;
        $display("\nTest Summary:");
        $display("Total PASSES: %0d", pass_count);
        $display("Total FAILS : %0d", fail_count);
        
        $finish;
    end
    
task write2FIFO ;
    begin
        $display("=== write2FIFO Task ===" );
        UART_Data_Write_Register_enable = 1;
        for (i=0 ; i<2**(uart_tx_top_uut.fifo_uart_rx_Inst.W) ; i=i+1) begin // Write data into FIFO // parameter "
            
            UART_Data_Write_Register_wdata = $random % 256;
            verifyarray[i] = UART_Data_Write_Register_wdata;
            UART_Data_Write_Register_enable = 1;
            #5;
            UART_Data_Write_Register_enable = 0;
            if (i) $display("FIFO   [%0d]= %b(%h)",i-1 , uart_tx_top_uut.fifo_uart_rx_Inst.array_reg[i-1] , uart_tx_top_uut.fifo_uart_rx_Inst.array_reg[i-1] );
            #5;
            $display("Random Value[%0d]= %b(%h)",i , UART_Data_Write_Register_wdata , UART_Data_Write_Register_wdata );
            
        end
    end
endtask

integer j ;
task TX_senddata ;
    begin
        $display("=== TX_senddata Task ===" );
        UART_Control_Register_tx_Active = 1;         // Enable UART transmission        
        for (i = 0; i < 2**(uart_tx_top_uut.fifo_uart_rx_Inst.W); i = i + 1) begin         // Wait for data to be transmitted
            buffer = 8'b0;
            #20; // setup signals
            #(((baud_div)*10)); // start bit wait
            $display("BYTE sending: %h", uart_tx_top_uut.fifo_uart_rx_Inst.array_reg[i]);
            for (j = 0; j < $bits(uart_tx_top_uut.fifo_uart_rx_Inst.array_reg[i]); j = j + 1) begin         // Wait for data to be transmitted
                #(((baud_div)*10));
                buffer[j] = UART_tx_o_tb ;
                $display("FIFO[%0d][%0d]=>Tx_out : %b      Time: %0t ns",i,j, UART_tx_o_tb , $time);
            end
            wait(uart_tx_top_uut.tx_done_tick_o==1); // Wait for each transmission // as stop bit wait
            j=0;
            if (buffer[7:0] === verifyarray[i]) begin
                pass_count = pass_count + 1;
                $display("PASS: FIFO[%0d] = %b, Buffer = %b", i, verifyarray[i], buffer[7:0]);
            end else begin
                fail_count = fail_count + 1;
                $display("FAIL: FIFO[%0d] = %b, Buffer = %b", i, verifyarray[i], buffer[7:0]);
            end
        end        
        UART_Control_Register_tx_Active = 0;

    end
endtask

    uart_tx_top uart_tx_top_uut (
        .clk_i(clk_i),
        .rstn_i(rstn_i),
        .baud_div(baud_div),
        .UART_Control_Register_tx_Active(UART_Control_Register_tx_Active),
        .UART_Data_Write_Register_enable(UART_Data_Write_Register_enable),
        .UART_Data_Write_Register_wdata(UART_Data_Write_Register_wdata),
        .UART_Status_Register_tx_full(Full_tb),
        .UART_Status_Register_tx_empty(Empty_tb),
        .UART_tx_o(UART_tx_o_tb),
        .UART_Data_Send_Tick(UART_Data_Send_Tick_tb)
    );
    
endmodule
