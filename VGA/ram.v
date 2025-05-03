`timescale 1ns / 1ps
module RAM 
    #(  parameter DATA_WIDTH  = 8       , 
                   ADDR_WIDTH = 17       , 
                   RAM_DEPTH = 76800      
    )(
    input clk_i_ram , we_i_ram , re_i_ram , en_i_ram  ,
    input [DATA_WIDTH -1:0]  data_i_ram     ,
    input [ADDR_WIDTH-1:0]   address_i_ram  ,
    
    output write2ram_done_o ,
    output read_from_ram_done_o , 
    output  [DATA_WIDTH -1:0]  data_o_ram           //data_out ba�ka yere giri� olaca�� zaman wire olmal�
    );
      (* ram_style = "block" *)  
reg [DATA_WIDTH -1:0] RAM [0:RAM_DEPTH-1] ; // reg [DATA_WIDTH -1:0] RAM [0:S-1]; de yaz�labilir 76799

reg write2ram_done ; 
assign write2ram_done_o = write2ram_done ;

reg read_from_ram_done ;
assign read_from_ram_done_o = read_from_ram_done ; 

reg [DATA_WIDTH-1:0] data_o_ram_reg ; 
assign data_o_ram = data_o_ram_reg ; 

always@(posedge(clk_i_ram))begin
    if (en_i_ram) begin
        if (we_i_ram) begin
            RAM[address_i_ram]  <= data_i_ram    ;
            if ( address_i_ram == RAM_DEPTH-1 ) begin
                write2ram_done <= 1 ; 
            end 
            else begin
                write2ram_done <= 0  ;
            end
        end 
        
        else if (re_i_ram) begin
            data_o_ram_reg  <= RAM[address_i_ram]    ;
            if ( address_i_ram == RAM_DEPTH-1 ) begin
                read_from_ram_done <= 1 ; 
            end 
            else begin
                read_from_ram_done <= 0  ;
            end
        end
    end else 
    data_o_ram_reg <= 0;//
end
endmodule