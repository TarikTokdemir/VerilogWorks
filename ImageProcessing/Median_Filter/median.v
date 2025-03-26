`timescale 100ns / 1ps

module median #(
        parameter DATA_SAYISI = 9 ,  // 3x3 5x5 7x7   // 9 25 41
        parameter DATA_WIDTH = 8 
    )(  
    input       clk_i_median   , rst_i_median   , en_i_median , 
    input [7:0] data_i_0    , data_i_1    , data_i_2 ,
    input [7:0] data_i_3    , data_i_4    , data_i_5 ,
    input [7:0] data_i_6    , data_i_7    , data_i_8 ,
     
    output [7:0] data_o ,
    output sonuc_done
     );
     
    reg [7:0]   data_i_reg  [0:8]    ;
    reg [7:0]   sayac = 0 ; 
    reg [7:0]   iterasyon = 0 ; 
    reg [3:0]   durum = 0 ; 
    reg [3:0]   genel_sayac = 0 ; 
    
    reg [7:0]   array   [0:8]  ; 

    reg [7:0]   temp;
    reg         compare_done = 0 ; 
    reg         sonuc_done_median = 0 ; 
    reg [7:0]   data_son ; 
    always @ ( posedge clk_i_median) begin  
        if(!rst_i_median) begin 
            durum = 0 ; 
            data_i_reg[0] = 0  ; data_i_reg[1] = 0  ; data_i_reg[2] = 0 ; 
            data_i_reg[3] = 0  ; data_i_reg[4] = 0  ; data_i_reg[5] = 0 ; 
            data_i_reg[6] = 0  ; data_i_reg[7] = 0  ; data_i_reg[8] = 0 ; 
            sayac = 0 ;
            compare_done= 0 ; 
            iterasyon = 0 ; 
//bu yöntem işe yaramzsa 24 lük 3 tane reg tanımla birbiri içinde kaydırma işlemi uygula
        end else begin
            if(en_i_median==1) begin
                case (durum)
                    0:  begin
                        sonuc_done_median = 0 ;
                        genel_sayac = genel_sayac + 1 ;
                        data_i_reg[0] = data_i_0  ; data_i_reg[1] = data_i_1  ; data_i_reg[2] = data_i_2 ;
                        data_i_reg[3] = data_i_3  ; data_i_reg[4] = data_i_4  ; data_i_reg[5] = data_i_5 ;
                        data_i_reg[6] = data_i_6  ; data_i_reg[7] = data_i_7  ; data_i_reg[8] = data_i_8 ; 
                        sayac = 0 ;
                        iterasyon = 0 ; 
                        durum = 1 ; 
                        compare_done=0;
                    end
                    
                    1: begin
                        if (sayac < DATA_SAYISI - 1) begin
                            if (data_i_reg[sayac] > data_i_reg[sayac+1]) begin
                                temp <= data_i_reg[sayac];
                                durum = 2 ;
                            end else begin// degilse sabit kalcak 
                                sayac <= sayac + 1;
                                durum = 1 ; 
                            end
                        end else begin  // 
                            compare_done = 1 ; 
                            durum <= 3;
                            sayac <= 0;
                        end
                    end
                    
                    2: begin
                        data_i_reg[sayac] <= data_i_reg[sayac+1];
                        data_i_reg[sayac+1] <= temp;
                        durum = 1 ;
                    end
                    
                    3: begin
                        if ( iterasyon < 9 ) begin
                            iterasyon = iterasyon + 1 ; 
                            durum = 1 ; 
                            compare_done = 0 ; 
                        end else begin
                            durum = 4 ; 
                        end
                    end
                    
                    4: begin
                        iterasyon = 0 ;
                        data_son <= data_i_reg[(DATA_SAYISI-1)/2]; // Ortadaki değer medyan
                        sonuc_done_median <= 1;
                        durum <= 5;
                    end
                    
                    5: begin
                        iterasyon = 0 ; 
                        sonuc_done_median = 0 ; 
                        compare_done = 0 ; 
                        durum <= 0;
                    end
                endcase
            end else begin
                durum   = 0;
            end
        end
    end
    
assign data_o = data_son ;
assign sonuc_done   = sonuc_done_median  ;

endmodule