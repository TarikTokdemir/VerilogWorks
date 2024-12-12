// Create Date: 11.12.2024 19:45:26
`timescale 1ns / 1ps

module uart_tx_tb;
    reg          clk_i;
    reg          rstn_i;
    reg  [7:0]   din_i;
    reg  [15:0]  baud_div;
    reg          tx_start_i;
    wire         tx_o;
    wire         tx_done_tick_o;

    uart_tx uart_tx_uut (
        .clk_i(clk_i),
        .rstn_i(rstn_i),
        .din_i(din_i),
        .baud_div(baud_div),
        .tx_start_i(tx_start_i),
        .tx_o(tx_o),
        .tx_done_tick_o(tx_done_tick_o)
    );

    initial begin
        clk_i = 1;
        forever #5 clk_i = ~clk_i; // 
    end

reg [7:0] tx_buffer_tb ; 

    initial begin
        rstn_i = 0;
        din_i = 8'b0;
        baud_div = 16'd868; 
        tx_start_i = 0;

        #10; 
        rstn_i = 1;
        #10;
        
        din_i = 8'b10101010;
        tx_start_i = 1;
        #10;                
        tx_start_i = 0;
        #8670; // start bit delay
        wait(tx_done_tick_o);
        Check();
        
        #10;
        din_i = 8'b11001100;
        tx_start_i = 1;
        #10;
        tx_start_i = 0;
        #8670; // start bit delay
        wait(tx_done_tick_o);
        Check();

        repeat (5) begin
            #10;
            din_i = $random;
            tx_start_i = 1;
            #10;
            tx_start_i = 0;
            wait(tx_done_tick_o);
            Check();
        end

        #100;
        $finish;
    end
    
   task Check;
       begin
           if ( tx_buffer_tb == din_i) begin
               $display(" === PASS === Expected=%h , Transmitted=%h " , din_i , tx_buffer_tb);
           end else begin
               $display(" === ! ERROR ! === Expected=%h , Transmitted=%h " , din_i , tx_buffer_tb);
           end
       end
   endtask
   
   always @(posedge clk_i) begin
        if (!rstn_i) begin
            tx_buffer_tb <= 8'b0;
        end else begin
            if (uart_tx_uut.bitcntr < 8 ) begin
                if (uart_tx_uut.bitcntr == 7 ) begin
                    tx_buffer_tb[uart_tx_uut.bitcntr] <= tx_o; 
                    #10;
                    wait(tx_done_tick_o);
                end else begin
                    tx_buffer_tb[uart_tx_uut.bitcntr] <= tx_o; 
                end
            end
        end
    end

endmodule
