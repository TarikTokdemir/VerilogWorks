`timescale 1ns / 1ps
/*
    HATALAR : 
    1-) bit_akis_kontorlundeki --> "temp" isimlendirmesi "r_shift_register" olarak guncellenecekti 
    2-) HATA_SORGULA_BASLA statetinde --> s_data atamasi yerine i_data degerine atama yapilacakti 
    3-) HATA_SORGULA statetinde --> i_flag = 1 yapildiktan sonra , soncraki cycle da i_flag = 0 yapilacakti
    4-) Rame yazma yaparken 1 kere fazla yaziyor 15'inci adresten sonra 0'ýncý adrese tekrar yazmasýný engellenmek için we_ram kapatýlmalý 



*/


module TOP  #(
    parameter   DW = 6 , // Data Width
                AW = 4 , // Address Width
                WORD_WIDTH = 7 , // Rame kaydedilecek kelime uzunlugu 
                RAM_DEPTH  = AW**2 
) ( 
    input i_clk_top ,
    input i_rst_top ,
    
    output reg ok_o  ,
    output reg [WORD_WIDTH-1 : 0] ok_data_o   // 7 bit  { o_ERR , data }

);
///////////////////////////////////////////////////////////////////////////////////
reg                 r_lfsr_en   ;
reg   [DW-1 : 0]    r_lfst_data ;
reg                 r_rst_lfsr  ;
wire  [DW-1 : 0]    o_rnd_lfsr  ;
LFSR #(
    .DW_LFSR(DW) 
) LFSR_inst (
    .i_clk_lfsr (i_clk_top), 
    .i_en_lfsr  (r_lfsr_en),
    .i_rst_lfsr (r_rst_lfsr),
    .i_data_lfsr(r_lfst_data),
    .o_rnd_lfsr (o_rnd_lfsr)
);
///////////////////////////////////////////////////////////////////////////////////
reg [WORD_WIDTH-1:0]    r_ram_din   ;
reg [AW-1 : 0]          r_ram_addr  ; 
reg                     r_en_ram    ;
reg                     r_we_ram    ;
reg                     r_re_ram    ;
wire [WORD_WIDTH-1:0]   w_rdata_ram ; 
RAM #(
    .DATA_WIDTH(WORD_WIDTH  ),
    .ADDR_WIDTH(AW          ),
    .RAM_DEPTH (RAM_DEPTH   )
) RAM_inst (
    .i_clk_ram   (i_clk_top     ),
    .i_wdata_ram (r_ram_din     ),
    .i_addr_ram  (r_ram_addr    ),
    .i_en_ram    (r_en_ram      ),
    .i_we_ram    (r_we_ram      ),
    .i_re_ram    (r_re_ram      ),
    .o_rdata_ram (w_rdata_ram   )
);
///////////////////////////////////////////////////////////////////////////////////
reg [2:0]   i_data      ;
reg [0:0]   i_flag      ;
wire        o_ERR       ;
wire        o_ERR_done  ;
bit_akis_kontrolu  bit_akis_kontrolu_inst(
    .i_clk          (i_clk_top      ),    
    .i_rstn         (~i_rst_top     ),
    .i_data         (i_data         ),
    .i_flag         (i_flag         ),
    .o_ERR          (o_ERR          ),
    .o_ERR_done     (o_ERR_done     )
);
///////////////////////////////////////////////////////////////////////////////////
reg [AW:0] w_counter ;
reg [AW:0] r_counter ;

reg [2:0]   s_data  ;
reg         r_ERR   ;
reg [3:0] STATE ;
localparam  BASLA               = 'd0 ,
            RND_DEGER_AL        = 'd1 ,
            RAM_YAZ             = 'd2 ,
            SONRAKI             = 'd3 ,
            RAM_OKU             = 'd4 ,
            HATA_SORGULA_BASLA  = 'd5 ,
            HATA_SORGULA        = 'd6 ,
            HATA_BITI_AL        = 'd7 ,
            HATA_YAZ            = 'd8 ;

always @(posedge i_clk_top or posedge i_rst_top) begin
    if (i_rst_top) begin
        STATE   <= 0 ;
        w_counter   <= 0 ; 
        r_counter   <= 0 ; 
        ok_data_o   <= 0 ;
        ok_o        <= 0 ;
        s_data      <= 0 ;
        
        r_ERR       <= 0 ; 
        i_data      <= 0 ; 
        i_flag      <= 0 ; 
        
        r_ram_din   <= 0 ;
        r_ram_addr  <= 0 ;
        r_en_ram    <= 0 ;
        r_we_ram    <= 0 ;
        r_re_ram    <= 0 ;
        
        r_lfsr_en   <= 0 ;  
        r_lfst_data <= 6'b101010    ; 
        r_rst_lfsr  <= 0 ; 
        
        
    end
    else begin
        case (STATE) 
            
            BASLA : begin   
                ok_o        <= 0            ;
                r_lfsr_en   <= 1            ;
                r_rst_lfsr  <= 1            ; 
                r_lfst_data <= 6'b101010    ;
                STATE       <= RND_DEGER_AL ;
            end
            
            
            RND_DEGER_AL : begin
                r_lfsr_en   <= 1            ; 
                r_rst_lfsr  <= 0            ; 
                STATE       <= RAM_YAZ      ;
            end
            
            
            RAM_YAZ : begin
                r_en_ram    <= 1 ;
                r_we_ram    <= 1 ;
                r_re_ram    <= 0 ; 
                r_ram_addr  <= w_counter ;
                r_ram_din   <= {1'b0 , o_rnd_lfsr} ;  // 7 bit rame yazilir 
                STATE       <= SONRAKI ; 
            end
            
            
            SONRAKI : begin     // burda counta bagli kontrol . 16 tane veri aldik mi 
                if (w_counter == RAM_DEPTH-1) begin   // counter 15 oldu mu 
                    w_counter   <= 0 ; 
                    r_ram_addr  <= 0 ;
                    r_en_ram    <= 1 ;  //////////////////////////////////////////////////////////////////// sonradan eklendi
                    r_we_ram    <= 0 ;  //////////////////////////////////////////////////////////////////// sonradan eklendi
                    r_re_ram    <= 1 ;  //////////////////////////////////////////////////////////////////// sonradan eklendi
                    STATE       <= RAM_OKU ; // tum islem bittiyse
                end else begin
                    w_counter   <= w_counter + 1 ;
                    r_ram_addr  <= w_counter + 1 ; 
                    r_en_ram    <= 0 ;
                    r_we_ram    <= 0 ;
                    r_re_ram    <= 0 ;
                    STATE       <= RND_DEGER_AL  ;
                end
            end
            
            
            RAM_OKU : begin
                r_en_ram    <= 1 ;
                r_we_ram    <= 0 ;
                r_re_ram    <= 1 ;
                r_ram_addr  <= r_counter ; 
                STATE       <= HATA_SORGULA_BASLA ; 
            end
            
            
            HATA_SORGULA_BASLA : begin
                i_data      <= w_rdata_ram[5:3] ;  //////////////////////////////////////////////////////////////////// sonradan eklendi
                i_flag      <= 1 ; 
                STATE       <= HATA_SORGULA ; 
            end
            
            
            HATA_SORGULA : begin
                i_flag  <= 0 ; //////////////////////////////////////////////////////////////////// sonradan eklendi
                if (o_ERR_done) begin  // ERR sinyalinin 0 veya 1 durumunu alacak 
                    STATE   <= HATA_BITI_AL ; 
                end 
//                else 
//                    STATE   <= HATA_SORGULA ; 
            end
            
            HATA_BITI_AL : begin
                 r_ERR      <= o_ERR ;  // temp ara deðiþkende bunu sakladim
                 STATE      <= HATA_YAZ ; 
            end
            
            HATA_YAZ : begin
                ok_data_o   <= { r_ERR , w_rdata_ram[5:0] } ;
                
                if (r_counter == RAM_DEPTH-1) begin
                    w_counter   <= 0 ;              
                    r_counter   <= 0 ;           
                    ok_data_o   <= 0 ;           
                    s_data      <= 0 ;           
                
                    r_ERR       <= 0 ;           
                    i_data      <= 0 ;           
                    i_flag      <= 0 ;           
                
                    r_ram_din   <= 0 ;           
                    r_ram_addr  <= 0 ;           
                    r_en_ram    <= 0 ;           
                    r_we_ram    <= 0 ;           
                    r_re_ram    <= 0 ;           
                
                    r_lfsr_en   <= 0 ;           
                    r_lfst_data <= 6'b101010    ;
                    r_rst_lfsr  <= 0 ;           
                
                    STATE       <= BASLA ; 
                    ok_o        <= 1 ;
                end
                else begin
                    r_counter   <= r_counter + 1 ; 
                    r_ram_addr  <= r_counter + 1 ;
                    STATE       <= RAM_OKU       ;
                end
            end
        endcase
    end
end
endmodule
