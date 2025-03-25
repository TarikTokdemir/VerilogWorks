`timescale 1ns / 1ps

module top_contrast_stretching // RAM1'e yazma yaparken bu islem de gerceklestirilebilir .
    #(
    parameter  DATA_WIDTH = 8     ,
                RAM_DEPTH  = 76800  ,
                ADDR_WIDTH = $clog2(RAM_DEPTH) ,
                MAX        = 255 ,  //  What range does the image to span
                MIN        = 0   ,  //  What range does the image to span
                VALUE      = MAX-MIN 
                
    )(
input                   clk_i_top_contrast  , rstn_i_top_contrast , en_i_top_contrast , 
input  [DATA_WIDTH-1:0] data_i_top_contrast , 

output [DATA_WIDTH-1:0] data_o_top_contrast ,
output                  done_process      , 
output                  done_o_top_contrast 

);

reg [DATA_WIDTH-1:0] data_o_top_contrast_reg            ;          
assign data_o_top_contrast = data_o_top_contrast_reg    ; 
reg done_o_top_contrast_reg                             ;
assign done_o_top_contrast = done_o_top_contrast_reg    ;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
reg                     we_i_ram1        ;
reg                     re_i_ram1        ;
reg                     en_i_ram1        ;
reg  [ADDR_WIDTH-1:0]   address_i_ram    ;
wire                    write2ram_done_o1      ;
wire                    read_from_ram_done_o1  ;
wire [DATA_WIDTH-1:0]   data_o_ram1            ;

    RAM #(
        .DATA_WIDTH             (DATA_WIDTH             ),
        .ADDR_WIDTH             (ADDR_WIDTH             ),
        .RAM_DEPTH              (RAM_DEPTH              )
    )RAM1_inst(                                                                
        .clk_i_ram              (clk_i_top_contrast     ),    
        .we_i_ram               (we_i_ram1               ),
        .re_i_ram               (re_i_ram1               ),     
        .en_i_ram               (en_i_ram1               ),                                          
        .data_i_ram             (data_i_top_contrast             ),  
        .address_i_ram          (address_i_ram          ), 
        .write2ram_done_o       (write2ram_done_o1       ),
        .read_from_ram_done_o   (read_from_ram_done_o1   ),
        .data_o_ram             (data_o_ram1             )                                       
    );
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
reg                     we_i_ram2        ;
reg                     re_i_ram2        ;
reg                     en_i_ram2        ;
reg  [DATA_WIDTH-1:0]   data_i_ram2      ;
//reg  [DATA_WIDTH-1:0]   address_i_ram   ;
wire                    write2ram_done_o2      ;
wire                    read_from_ram_done_o2  ;
wire [DATA_WIDTH-1:0]   data_o_ram2            ;

    RAM #(
        .DATA_WIDTH             (DATA_WIDTH             ),
        .ADDR_WIDTH             (ADDR_WIDTH             ),
        .RAM_DEPTH              (RAM_DEPTH              )
    )RAM2_inst(                                                                
        .clk_i_ram              (clk_i_top_contrast      ),    
        .we_i_ram               (we_i_ram2               ),
        .re_i_ram               (re_i_ram2               ),     
        .en_i_ram               (en_i_ram2               ),                                          
        .data_i_ram             (data_i_ram2             ),  
        .address_i_ram          (address_i_ram           ), 
        .write2ram_done_o       (write2ram_done_o2       ),
        .read_from_ram_done_o   (read_from_ram_done_o2   ),
        .data_o_ram             (data_o_ram2             )                                       
    );                                                                 
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
reg                     en_i_min_max        ;
reg                     last_i_min_max      ;
reg  [DATA_WIDTH-1:0]   data_i_min_max      ;
wire [DATA_WIDTH-1:0]   data_o_min_value    ;
wire [DATA_WIDTH-1:0]   data_o_max_value    ;
wire                    done_o_min_max      ;
    min_max_find #(
.DATA_WIDTH         (DATA_WIDTH ),
.RAM_DEPTH          (RAM_DEPTH  ),
.ADDR_WIDTH         (ADDR_WIDTH )
   )inst_min_max_find(
.clk_i_min_max      (clk_i_top_contrast ),
.rstn_i_min_max     (rstn_i_top_contrast),
.en_i_min_max       (en_i_min_max       ),
.data_i_min_max     (data_i_min_max     ),
.last_i_min_max     (last_i_min_max     ),
.data_o_min_value   (data_o_min_value   ),
.data_o_max_value   (data_o_max_value   ),
.done_o_min_max     (done_o_min_max     )
);
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

reg                     en_i_mult       ;
reg  [DATA_WIDTH-1:0]   mult1           ;
reg  [DATA_WIDTH-1:0]   mult2           ;
wire [DATA_WIDTH*2-1:0] result_o_mult   ;
wire                    mult_done_o     ;
     booth_mult_unsigned #(
.DATA_WIDTH(DATA_WIDTH)
    )inst_booth_mult_unsigned(
.clk_i_mult      (clk_i_top_contrast    ),
.rstn_i_mult     (rstn_i_top_contrast   ),
.en_i_mult       (en_i_mult             ),
.A               (mult1                 ),      // multiplier
.B               (mult2                 ),      // multiplicand
.result_o_mult   (result_o_mult         ),      // max 1111_1111_1111_1111 / 1 = 65535
.mult_done_o     (mult_done_o           )
);

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
reg                     en_i_div        ;
reg  [DATA_WIDTH-1  :0] B               ;
reg  [DATA_WIDTH*2-1:0] Q               ;      
wire [DATA_WIDTH-1  :0] result_o_div    ;
wire                    div_done_o      ;
     binary_division #(
.DATA_WIDTH(DATA_WIDTH)
    )inst_binary_division(
.clk_i_div      (clk_i_top_contrast     ),
.rstn_i_div     (rstn_i_top_contrast    ),
.en_i_div       (en_i_div               ),
.B              (B                      ),      // comes from mult // divisior max 8
.Q              (Q                      ),      // comes from mult // dividend max 16
.result_o_div   (result_o_div           ),      //max 1111_1111_1111_1111 / 1 = 65535
.div_done_o     (div_done_o             )
);
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


reg [DATA_WIDTH-1:0]    min_data_reg    ;
reg [DATA_WIDTH-1:0]    max_data_reg    ;
reg [DATA_WIDTH  :0]    complement_min  ;


reg [DATA_WIDTH-1:0]     div1            ;
reg [DATA_WIDTH*2-1 :0]  result_pixel    ;

reg [3:0]   STATE ;

localparam  IDLE        = 4'b0000 ,
            WR2RAM1     = 4'b0001 ,
            PROCESS     = 4'b0010 ,
            MULT        = 4'b0011 , 
            DIV         = 4'b0100 , 
            LAST        = 4'b0101 ,
            WAIT        = 4'b0110 ;
reg done_process_reg ; 
assign done_process = done_process_reg ;
always @(posedge clk_i_top_contrast or negedge rstn_i_top_contrast ) begin
    if (!rstn_i_top_contrast) begin
        STATE <= IDLE ;
    end else begin
        case (STATE)
            IDLE : begin // 0
                mult1 <= 0 ;
                mult2 <= 0 ;
                div1  <= 0 ;
                
                we_i_ram1       <= 0 ;
                re_i_ram1       <= 0 ;
                en_i_ram1       <= 0 ;
                we_i_ram2       <= 0 ; 
                re_i_ram2       <= 0 ; 
                en_i_ram2       <= 0 ; 
                data_i_ram2     <= 0 ; 
                address_i_ram   <= 0 ;
                done_process_reg<= 0 ;
                 
                en_i_mult   <= 0 ; 
                
                if (en_i_top_contrast) begin 
                    STATE <= WR2RAM1 ;
                    we_i_ram1        <= 1 ;
                    re_i_ram1        <= 0 ;
                    en_i_ram1        <= 1 ;
                    en_i_min_max     <= 1 ; 
                end
            end 
            
            WR2RAM1 : begin // 1
                if(div_done_o) begin
                     we_i_ram1        <= 0 ;
                     re_i_ram1        <= 1 ;
                     en_i_ram1        <= 1 ;
                     STATE            <= WAIT  ;
                end else begin
                    if (done_o_min_max) begin
                        min_data_reg     <= data_o_min_value ; 
                        max_data_reg     <= data_o_max_value ;
                        complement_min   <= (~({1'b0 , data_o_min_value})) + 1'b1 ; 
                        we_i_ram1        <= 0 ;
                        re_i_ram1        <= 1 ;
                        en_i_ram1        <= 1 ;
                        address_i_ram    <= 0 ; 
                        
                        STATE            <= WAIT  ;
                    end
                    else begin
                        if (address_i_ram != RAM_DEPTH) 
                            address_i_ram <= address_i_ram + 1 ;  
                        data_i_min_max   <= data_i_top_contrast  ;
                    end 
                    
                    if (address_i_ram == RAM_DEPTH-1) begin
                        last_i_min_max  <= 1 ;
                        en_i_min_max    <= 0 ;
                    end
                end
            end
            
            WAIT : begin    
                if(done_process_reg)
                    STATE            <= LAST  ;
                else
                    STATE            <= PROCESS  ;
            end 
            
            PROCESS : begin // 2 // need to read from RAM1
                we_i_ram1        <= 0 ;
                re_i_ram1        <= 0 ;
                en_i_ram1        <= 0 ;
             
                mult1 <= data_o_ram1  + complement_min[DATA_WIDTH-1:0] ;
                mult2 <= VALUE                                         ;
                div1  <= max_data_reg + complement_min[DATA_WIDTH-1:0] ;
                
                en_i_mult   <= 1    ;
                STATE       <= MULT ;
            end
            
            MULT : begin // 3
                if (mult_done_o == 1) begin
                    Q           <= result_o_mult    ;
                    B           <= div1             ;
                    en_i_mult   <= 0                ;
                    
                    we_i_ram2   <= 1                ;
                    re_i_ram2   <= 0                ;
                    en_i_ram2   <= 1                ;
                    
                    en_i_div    <= 1                ;
                    STATE       <= DIV              ;
                end
            end
            
            DIV : begin // 4
                if (div_done_o == 1) begin
                    if (result_o_div + MIN > 8'd255) begin
                        result_pixel    <= 8'd255  ;
                        data_i_ram2     <= 8'd255  ;
                        address_i_ram   <= address_i_ram + 1    ;
                    end
                    else begin
                        result_pixel    <= result_o_div + MIN   ;
                        data_i_ram2     <= result_o_div + MIN   ; //ram2'ye yazar
                        address_i_ram   <= address_i_ram + 1    ;
                    end
                    en_i_div            <= 0                    ;
                    
                    if (address_i_ram == RAM_DEPTH-1) begin // ram2'ye yazma bitti 
                        we_i_ram2   <= 0                ;
                        re_i_ram2   <= 1                ;
                        en_i_ram2   <= 1                ;
                        address_i_ram   <= 0            ;
                        done_process_reg<= 1            ;
                        STATE       <= WAIT             ; // ram2'ye yazma bitti 
                    end 
                    else begin // ram2'ye yazma bittimediyse ram2'yi kapatýr
                        we_i_ram2   <= 0                ;
                        re_i_ram2   <= 0                ;
                        en_i_ram2   <= 0                ;
                        
                        STATE       <= WR2RAM1          ; // state 1
                    end
                end
            end
            
            LAST : begin //ram2'den okuma baslamalý
                address_i_ram           <= address_i_ram + 1    ; 
                data_o_top_contrast_reg <= data_o_ram2          ;
                if (read_from_ram_done_o2) begin
                    done_o_top_contrast_reg <= 1                ;
                    
                    STATE               <= IDLE             ;
                end
            end
            
        endcase
    end
end

endmodule