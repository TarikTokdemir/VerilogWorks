`timescale 1ns / 1ps
module ROM 
    #(  parameter DATA_WIDTH  = 8       , 
                   ADDR_WIDTH = 17       , //
                   RAM_DEPTH = 76800      
    )(
    input  clk_i_rom , re_i_rom , en_i_rom  ,
    input  [ADDR_WIDTH-1:0] address_i_rom   , 
   
    output read_from_rom_done_o             ,               // ram yazmasi bittiginde bu sinyal 1 olmalý
    output  [DATA_WIDTH-1:0]  data_o_rom        //data_out baþka yere giriþ olacaðý zaman wire olmalý
    );
  (* ram_style="block" *)  
reg [DATA_WIDTH-1:0] ROM [0:RAM_DEPTH-1] ;          // reg [DATA_WIDTH -1:0] RAM [0:S-1]; de yazýlabilir 76799

reg read_from_rom_done ;
assign read_from_rom_done_o = read_from_rom_done ; 

reg [DATA_WIDTH-1:0] data_o_rom_reg ; 
assign data_o_rom = data_o_rom_reg ; 

initial begin
    $readmemb("C:/Users/pc/Downloads/sobel_input_640.mem", ROM);
end  

always @(posedge clk_i_rom)begin
    if (en_i_rom) begin
        if (re_i_rom) begin
            data_o_rom_reg <= ROM [address_i_rom] ; 
            if (address_i_rom == (RAM_DEPTH-1) ) begin
                read_from_rom_done <= 1 ; 
            end
        end
    end else
    data_o_rom_reg <= 0 ;
end

endmodule
