`timescale 1ns / 1ps

module tb_RAM();
parameter   DATA_WIDTH = 8 ;  // veri genisligi 
parameter   ADDR_WIDTH = 4 ;  // adres genisligi
parameter   RAM_DEPTH  = ADDR_WIDTH**2 ; // ram derinligi

reg i_clk_ram       ; 
reg [DATA_WIDTH-1 : 0] i_wdata_ram     ;
reg [ADDR_WIDTH-1 : 0]i_addr_ram      ;
reg i_en_ram        ;
reg i_we_ram        ;
reg i_re_ram        ;
wire [DATA_WIDTH-1 : 0] o_rdata_ram    ;
   
    RAM  #(
        .DATA_WIDTH(DATA_WIDTH) , 
        .ADDR_WIDTH(ADDR_WIDTH) ,
        .RAM_DEPTH (RAM_DEPTH )
    ) DUT (
        .i_clk_ram      (i_clk_ram  ),  
        .i_wdata_ram    (i_wdata_ram),
        .i_addr_ram     (i_addr_ram ),
        .i_en_ram       (i_en_ram   ),
        .i_we_ram       (i_we_ram   ),
        .i_re_ram       (i_re_ram   ),
        .o_rdata_ram    (o_rdata_ram)
    );
    
initial begin
    i_clk_ram = 1 ; 
    forever #5 i_clk_ram = ~i_clk_ram ;
end

initial begin
    i_wdata_ram = 0;
    i_addr_ram  = 0;
    i_en_ram    = 0;
    i_we_ram    = 0;
    i_re_ram    = 0;
    #1000;
    
    
    write_mem('d12 , 'd0 );
    write_mem('d5  , 'd3 );
    write_mem('d15 , 'd6 );
    
    #100 ;
    
    read_mem ('d6);
    read_mem ('d3);
    read_mem ('d0);
    
    $finish ; 
end

task write_mem ( input [DATA_WIDTH-1:0] i_wdata , input [ADDR_WIDTH-1:0] i_waddr );
    begin
        #5; 
        i_wdata_ram = i_wdata ;
        i_addr_ram  = i_waddr ;
        i_we_ram    = 1 ; 
        i_en_ram    = 1 ; 
        i_re_ram    = 0 ; 
        #10;
    end
endtask

task read_mem ( input [ADDR_WIDTH-1:0] i_raddr );
    begin
        #10; 
        i_we_ram    = 0 ; 
        i_en_ram    = 1 ; 
        i_re_ram    = 1 ; 
        i_addr_ram  = i_raddr ;
        #10;
    end
endtask

endmodule
