`timescale 1ns / 1ps

module uart_tx_tb;
    parameter DATA_WIDTH = 8;

    reg                   clk_i_tx;
    reg                   rsnt_i_tx;
    reg                   tx_start;
    reg  [DATA_WIDTH-1:0] data_i_tx;
    reg  [DATA_WIDTH*2:0] baud_div_i_tx;

    wire                  active_o_tx;
    wire                  data_o_serial_tx;
    wire                  done_o_tx;

    uart_tx #(
        .DATA_WIDTH(DATA_WIDTH)
    ) uut (
        .clk_i_tx(clk_i_tx),
        .rsnt_i_tx(rsnt_i_tx),
        .tx_start(tx_start),
        .data_i_tx(data_i_tx),
        .baud_div_i_tx(baud_div_i_tx),
        .active_o_tx(active_o_tx),
        .data_o_serial_tx(data_o_serial_tx),
        .done_o_tx(done_o_tx)
    );
reg [7:0] temp_tb ;
integer i=0 , j=0 , k=0 , pass_counter=0 , fail_counter =0;
always #5 clk_i_tx = ~clk_i_tx;

    initial begin
    clk_i_tx =0;
    rsnt_i_tx =0;
    #10;
    
    $display("----- UART TX Testbench Start -----");
        for (k=0 ; k<10 ; k=k+1) begin
            j=0;
            repeat (1) begin
                INITIAL ;
                SEND_DATA ; 
                WAIT ; 
                CHECK ; 
            end
            
            repeat (8) begin
                WAIT ; 
                CHECK ; 
                temp_tb[j] = data_o_serial_tx ;
                j = j+1;
            end
            
            repeat (1) begin
                WAIT ; 
                CHECK ; 
            end
            
            wait(done_o_tx == 1);
            $display("Data transmission completed at time %t", $time);
            $display("Data in = %b ////  Data out = %b %t",data_i_tx,temp_tb, $time);
            if (temp_tb == data_i_tx) begin
                $display("****PASS****");
                pass_counter = pass_counter + 1 ; 
            end else begin 
                $display("****FAIL****");
                fail_counter = fail_counter + 1 ; 
            end
        end
        
        $display("TOTAL_PASS = %0d  ----- TOTAL_FAIL = %0d ",pass_counter, fail_counter);
        
        #100;
        $finish;
    end

task INITIAL ;
    begin
        rsnt_i_tx   = 1 ; 
        baud_div_i_tx = 868  ; 
        @(posedge clk_i_tx) ;
    end
endtask

task SEND_DATA ;
    begin
        rsnt_i_tx   = 1 ; 
        data_i_tx   = $random % 256 ;
        tx_start    = 1 ; 
        $display("Data sending=%b=%0d --- time=%t:",data_i_tx,data_i_tx, $time);
    end
endtask

task WAIT ;
    begin
        for (i=0 ; i<baud_div_i_tx ; i=i+1) begin
            @(posedge clk_i_tx) ;
        end
        $display("waited for:%0d cycle --- time=%t:",i , $time);
    end
endtask
    
task CHECK ;
    begin
        $display("serial data out =%b  --- time=%t:",data_o_serial_tx , $time);
    end
endtask


endmodule
