`timescale 1ns / 1ps

module uart_rx_tb();

reg  clk_i_tb           ;
reg  rstn_i_tb          ;
reg  rx_i_tb            ;
reg  [15:0] baud_div_tb ;                  
wire [7:0] dout_o_tb    ;
wire rx_done_tick_o_tb  ;

reg [7:0] buffer_tb ; 
uart_rx uart_rx_dut(
    .clk_i           (clk_i_tb         ),
    .rstn_i          (rstn_i_tb        ),
    .rx_i            (rx_i_tb          ),
    .baud_div        (baud_div_tb      ),
    .dout_o          (dout_o_tb        ),
    .rx_done_tick_o  (rx_done_tick_o_tb)
);

initial begin
    clk_i_tb = 1 ;
    forever #5 clk_i_tb = ~clk_i_tb;
end

initial begin
    #1000;
    Reset();
    Baud_Set();
    TX_Frame();
    Check();
    TX_Frame();
    Check();
    Reset();
    TX_Frame();
    Check();
    $finish;
end

task Reset;
    begin
        rstn_i_tb = 0 ;
        #10;
        rstn_i_tb = 1 ;
        #10;
    end
endtask

task Baud_Set;
    begin
        baud_div_tb = 868;
        #10;
    end
endtask

integer i ;
task TX_Frame;
    begin
        buffer_tb = 8'bx ;
        $display("=== RECEIVE STARTED === " );
        rx_i_tb = 0 ;
        wait (uart_rx_dut.bittimer == 434);
        for ( i=0 ; i<8 ; i=i+1 ) begin  
            $display("Bitcounter = %0h " ,uart_rx_dut.bitcntr);
            rx_i_tb = $random % 2 ; 
            #5;
            buffer_tb = {rx_i_tb, buffer_tb[7:1]};
            #5;
            $display("Received bit from the system = %b , Rx_Done = %b " , rx_i_tb , uart_rx_dut.rx_done_tick_o );
            $display("buffer_tb = %b \n #######" , buffer_tb);
            #8680;
        end
        if ( i==7)buffer_tb[0]= rx_i_tb ;
        $display("Received Byte from the system = %b \n ------------------------------------------------------" , buffer_tb );
    end
endtask

task Check;
    begin
        if ( buffer_tb == uart_rx_dut.dout_o) begin
            $display(" *********PASS*********** \n ------------------------------------------------------");
        end
        else begin
            $display(" ERROR  ,  Expected = %b , Received = %h " , buffer_tb , uart_rx_dut.dout_o );
        end
    end
endtask 



endmodule
