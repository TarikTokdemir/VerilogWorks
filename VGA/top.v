`timescale 1ns / 1ps
module top #(  
    parameter DATA_WIDTH  = 8       , 
               RAM_DEPTH = 640*480     ,
               ADDR_WIDTH = $clog2(RAM_DEPTH)       
                
                   
    )(
    input clk_i_top, rstn_i_top , en_i_top , 
    input en_vga_top , 
    output [11:0] VGA_RGB,
    output VGA_HS,
    output VGA_VS
);
reg [7:0] deneme_ram [1000:0] ; 
reg en_combinational ;
reg  write_done ; 
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
reg                     re_i_rom                ;          
reg                     en_i_rom                ;          
reg  [ADDR_WIDTH-1:0]   address_i_rom           ;          
wire                    read_from_rom_done_o    ;
wire [DATA_WIDTH-1:0]   data_o_rom              ;

    ROM #(
        .DATA_WIDTH         (DATA_WIDTH     ),
        .ADDR_WIDTH         (ADDR_WIDTH     ),
        .RAM_DEPTH          (RAM_DEPTH      )
    )ROM_inst( 
        .clk_i_rom              (clk_i_top              ) ,
        .re_i_rom               (re_i_rom               ) ,
        .en_i_rom               (en_i_rom               ) ,
        .address_i_rom          (address_i_rom          ) ,
        .read_from_rom_done_o   (read_from_rom_done_o   ) ,
        .data_o_rom             (data_o_rom             )
    );
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
wire video_on_controller_o;
wire [9:0] vga_x, vga_y;
wire p_tick;  // Kullanýlacaksa
vga_control vga_inst (
    .clk_100MHz     (clk_i_top              ),   // clk_i_top'in 100MHz olduðunu varsayýyoruz
    .reset          (rstn_i_top            ),
    .video_on       (video_on_controller_o  ),
    .hsync          (VGA_HS                 ),
    .vsync          (VGA_VS                 ),
    .p_tick         (p_tick                 ),
    .x              (vga_x                  ),
    .y              (vga_y                  )
);
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
reg [DATA_WIDTH-1:0]    rgb_data_in     ;
reg                     rgb_i_video_on  ;
wire [11:0]             rgb_o           ;
rgb #(
.DATA_WIDTH(DATA_WIDTH) 
)rgb_inst (
.rgb_i_data     (data_o_ram            ),
.rgb_i_video_on (video_on_controller_o  ),
.rgb_o          (VGA_RGB                  )
    );
    
reg [2:0] STATE;     
localparam  IDLE        = 3'b000,
            ACTIVATE    = 3'b001, 
            ROM2RAM     = 3'b010, 
            RAM2VGA     = 3'b011, 
            VGA         = 3'b100;    
always @(posedge clk_i_top or posedge rstn_i_top) begin
    if (rstn_i_top) begin
        STATE           <= IDLE ;
    end 
    else begin
        case (STATE)
            IDLE : begin // 0     her islem bittiginde veya switchden en_i 1 yapilmadiginda
                address_i_rom   <= 0    ;
                address_i_ram   <= 0    ;
                en_i_rom    <= 0        ;
                re_i_rom    <= 0        ;
                en_i_ram    <= 0        ;
                we_i_ram    <= 0        ;
                re_i_ram    <= 0        ;
                en_combinational<=0     ;
                write_done  <= 0        ;
                
                
                if (en_i_top) begin
                    STATE <= ACTIVATE ;  
                end
            end
            
            ACTIVATE : begin // 1
                en_i_rom    <= 1        ;
                re_i_rom    <= 1        ;
                en_i_ram    <= 1        ;
                we_i_ram    <= 1        ;
                re_i_ram    <= 0        ;
                STATE       <= ROM2RAM  ;
            end
            
            ROM2RAM : begin // 2
                if (read_from_rom_done_o && write2ram_done_o) begin
                    STATE <= RAM2VGA ; 
                    address_i_rom <= 0 ; 
                    address_i_ram <= 0 ; 
                    en_i_rom    <= 0        ;
                    re_i_rom    <= 0        ;
                    en_i_ram    <= 1        ;   // vga'ya yazmak icin aktif kalmaya devam edecek 
                    we_i_ram    <= 0        ;   // ram'e yazma bitti
                    re_i_ram    <= 1        ;   // ram'den okuma baslayacak
                    write_done  <= 1 ; // ram ve rom'a yazma dogrulandi kontrol edildi // bundan sonra ramden dogru cikis aliniyormu bak
                end 
                else begin
                    if ( address_i_rom != RAM_DEPTH ) 
                        address_i_rom <= address_i_rom + 1 ;
                    if (address_i_rom != 0) 
                        address_i_ram <= address_i_ram + 1 ;  // arkada rom cikisi , ram'e girecek 
                end
            end
            
            RAM2VGA : begin 
                if ( video_on_controller_o ) 
                address_i_ram <= address_i_ram + 1 ;
                if ( address_i_ram == RAM_DEPTH) address_i_ram = 0 ; 
            end
        endcase
        

    end // else begin
end // always    


endmodule
