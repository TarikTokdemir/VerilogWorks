`timescale 1ns / 1ps

module RAM #(
    parameter   DATA_WIDTH = 8 ,  // veri genisligi 
                ADDR_WIDTH = 4 ,  // adres genisligi
                RAM_DEPTH  = ADDR_WIDTH**2  // ram derinligi
)(
    input                         i_clk_ram     ,
    input [DATA_WIDTH-1 : 0]      i_wdata_ram   ,   // rame gelen veri
    input [ADDR_WIDTH-1 : 0]      i_addr_ram    ,   // rame gelen adres 
    input                         i_en_ram      ,       // genel ram enable 
    input                         i_we_ram      ,       //  write enable
    input                         i_re_ram      ,       //  read enable 
    output reg [DATA_WIDTH-1 : 0] o_rdata_ram      // read data 

    );
    
(*ram_style = " distributed "*)
reg [DATA_WIDTH-1 : 0]   ram_mem   [0:RAM_DEPTH-1] ;

always @(posedge i_clk_ram) begin
    if (i_en_ram) begin
        if (i_we_ram) begin
            ram_mem[i_addr_ram] <= i_wdata_ram ; 
        end
        
        if (i_re_ram) begin
            o_rdata_ram     <=  ram_mem[i_addr_ram];
        end
    end 
end

endmodule
