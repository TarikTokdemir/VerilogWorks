`timescale 1ns / 1ps

module fifo_tb();

parameter B = 8;  // Veri geniþliði
parameter W = 4;  // Derinlik (adres geniþliði)

reg clk_tb;
reg rstn_i_tb;
reg rd_tb;
reg wr_tb;
reg [B-1:0] w_data_tb;
wire empty_tb;
wire full_tb;
wire [B-1:0] r_data_tb;

fifo #(
    .B(B),  
    .W(W)
) fifo_dut (
    .clk    (clk_tb      ),
    .rstn_i (rstn_i_tb   ),
    .rd     (rd_tb       ),
    .wr     (wr_tb       ),
    .w_data (w_data_tb   ),
    .empty  (empty_tb    ),
    .full   (full_tb     ),
    .r_data (r_data_tb   )
);


reg [W:0] w_pointer_tb, r_pointer_tb;

initial begin
    clk_tb = 0;
    forever #5 clk_tb = ~clk_tb;
end

initial begin
    #1000;
    reset();
    #100 ; 
    
    fifo_write();
    fifo_read();

    #100;
    fifo_write();
    fifo_read();
    
    reset();
    
    wr_tb = 1; // just write [0] first index. real write_pointer_reg = 0
    w_data_tb = $urandom % 255; //in this situation , automaticly read 0. index. "r_data = array_reg [r_ptr_reg];"
    #10;
    
    wr_tb = 1; // just write [1] second index. real write_pointer_reg = 1
    w_data_tb = $urandom % 255;
    #10;
    
    write_read(); //  write [2] third index. real write_pointer_reg = 2 . then also read 
    $finish;
end


task fifo_write;
    begin
        $display("=== FIFO WRITE ===");
        for (w_pointer_tb = 0; w_pointer_tb < 2**W; w_pointer_tb = w_pointer_tb + 1) begin
            if (!full_tb) begin
                wr_tb = 1;
                rd_tb = 0 ;
                w_data_tb = $urandom % 255;
                $display("w_pointer_tb = %d, Random_Bin = %b, Random_Deci = %d, Empty = %d, Full = %d",
                         w_pointer_tb, w_data_tb, w_data_tb, empty_tb, full_tb);
            end else begin
                $display("FIFO Full: Write Stopped");
            end
            #10;
        end
        $display( "Empty = %d, Full = %d" , empty_tb, full_tb );
        wr_tb = 0;
    end
endtask

task reset;
    begin
        rstn_i_tb = 0;
        w_pointer_tb = 0 ;
        r_pointer_tb = 0 ; 
        #10; 
        rstn_i_tb = 1;
    end
endtask

task fifo_read;
    begin
        $display("=== FIFO READ ===");
        for (r_pointer_tb = 0; r_pointer_tb < 2**W; r_pointer_tb = r_pointer_tb + 1) begin
            if (!empty_tb) begin
                wr_tb = 0;
                rd_tb = 1;
                $display("r_pointer_tb = %d, Out_bin = %b, Out_deci = %d, Empty = %d, Full = %d",
                         r_pointer_tb, r_data_tb, r_data_tb, empty_tb, full_tb);
            end else begin
                $display("FIFO Empty: Read Stopped");
            end
            #10;
            
        end
        $display( "Empty = %d, Full = %d" , empty_tb, full_tb );
        rd_tb = 0;
    end
endtask

integer i ; 
task write_read; // in same cycle
    begin
        wr_tb = 1;
        rd_tb = 1;
        for (i = 0; i < 2**W; i = i + 1) begin
            $display("w_pointer_tb = %d, r_pointer_tb = %d, Out_bin = %b, Out_deci = %d, Empty = %d, Full = %d",
            w_pointer_tb, r_pointer_tb, r_data_tb, r_data_tb, empty_tb, full_tb, empty_tb, full_tb);
            $display( "" , empty_tb, full_tb );
            #10;
        end
        $display( "Empty = %d, Full = %d" , empty_tb, full_tb );
        wr_tb = 0;
        rd_tb = 0;
    end
endtask
endmodule
