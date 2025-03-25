`timescale 1ns / 1ps
module RAM 
    #(  parameter  DATA_WIDTH  = 8       , 
                    RAM_DEPTH = 76800     ,
                    ADDR_WIDTH = $clog2(RAM_DEPTH)       
                       
    )(
    input clk_i_ram , we_i_ram , re_i_ram , en_i_ram  ,
    input [DATA_WIDTH -1:0]  data_i_ram     ,
    input [ADDR_WIDTH-1:0]   address_i_ram  ,
    
    output write2ram_done_o ,
    output read_from_ram_done_o , 
    output  [DATA_WIDTH -1:0]  data_o_ram           //data_out baþka yere giriþ olacaðý zaman wire olmalý
    );
      (* ram_style = "block" *)  
reg [DATA_WIDTH -1:0] RAM [0:RAM_DEPTH-1] ; // reg [DATA_WIDTH -1:0] RAM [0:S-1]; de yazýlabilir 76799

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
    end else begin
        write2ram_done <= 0 ;
        data_o_ram_reg <= 0;
    end
end
endmodule


/*
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
reg                     we_i_ram        ;
reg                     re_i_ram        ;
reg                     en_i_ram        ;
reg  [DATA_WIDTH-1:0]   data_i_ram      ;
reg  [ADDR_WIDTH-1:0]   address_i_ram   ;
wire                    write2ram_done_o      ;
wire                    read_from_ram_done_o  ;
wire [DATA_WIDTH-1:0]   data_o_ram            ;

    RAM #(
        .DATA_WIDTH             (DATA_WIDTH             ),
        .ADDR_WIDTH             (ADDR_WIDTH             ),
        .RAM_DEPTH              (RAM_DEPTH              )
    )RAM_inst(                                                                
        .clk_i_ram              (clk_i_top              ),    
        .we_i_ram               (we_i_ram               ),
        .re_i_ram               (re_i_ram               ),     
        .en_i_ram               (en_i_ram               ),                                          
        .data_i_ram             (data_o_rom             ),  // ram <- rom
        .address_i_ram          (address_i_ram          ), 
        .write2ram_done_o       (write2ram_done_o       ),
        .read_from_ram_done_o   (read_from_ram_done_o   ),
        .data_o_ram             (data_o_ram             )                                       
    );                                                                 
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
*/