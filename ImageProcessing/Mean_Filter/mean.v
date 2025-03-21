`timescale 100ns / 1ps

module mean #(
        parameter KERNEL_MATRIS = 3 ,  // 3x3 5x5 7x7   // 3 5 7
        parameter DATA_WIDTH = 8 
    )(  
    input       clk_i_mean   , rst_i_mean   , en_i_mean , 
    input [7:0] data_i_0    , data_i_1    , data_i_2 ,
    input [7:0] data_i_3    , data_i_4    , data_i_5 ,
    input [7:0] data_i_6    , data_i_7    , data_i_8 ,
     
    output [7:0] data_o ,
    output sonuc_done
     );
     
    reg [7:0]  data_i_reg  [0:8]    ;
    reg [7:0]  kernel_mean [0:8]    ;
    
    reg        sonuc_done_mean = 0     ;
    reg [18:0] sum_data     = 0     ;  // maks 12 bit gelebilir .  (x << 6) - (x << 3) - x;  // x * 57 = (x * 64) - (x * 8) - x
    reg [3:0]  durum        = 0     ;  
    reg [18:0]  divided_data             ;// x / 9 ? (x * 57) / 512        57/512 ~= 1/9 
    reg [3:0]  sayac ; 
    reg [31:0] genel_sayac ; 
    
    initial begin
        kernel_mean[0] = 8'b1 ; kernel_mean[1] = 8'b1 ; kernel_mean[2] = 8'b1 ;   //  1 1 1 
        kernel_mean[3] = 8'b1 ; kernel_mean[4] = 8'b1 ; kernel_mean[5] = 8'b1 ;   //  1 1 1 
        kernel_mean[6] = 8'b1 ; kernel_mean[7] = 8'b1 ; kernel_mean[8] = 8'b1 ;   //  1 1 1 
    end
    
    always @ ( posedge clk_i_mean) begin  
        if(!rst_i_mean) begin 
            durum = 0 ; 
            data_i_reg[0] = 0  ; data_i_reg[1] = 0  ; data_i_reg[2] = 0 ; 
            data_i_reg[3] = 0  ; data_i_reg[4] = 0  ; data_i_reg[5] = 0 ; 
            data_i_reg[6] = 0  ; data_i_reg[7] = 0  ; data_i_reg[8] = 0 ; 
            sayac = 0 ;
            genel_sayac =  0 ; 
            sum_data = 0 ;
            durum = 0 ; 
            sonuc_done_mean = 0 ;
        end else begin
            if(en_i_mean==1) begin

                case (durum)
                    0:  begin
                        sonuc_done_mean = 0 ;
                        genel_sayac = genel_sayac + 1 ;
                        data_i_reg[0] = data_i_0  ; data_i_reg[1] = data_i_1  ; data_i_reg[2] = data_i_2 ;
                        data_i_reg[3] = data_i_3  ; data_i_reg[4] = data_i_4  ; data_i_reg[5] = data_i_5 ;
                        data_i_reg[6] = data_i_6  ; data_i_reg[7] = data_i_7  ; data_i_reg[8] = data_i_8 ; 
                        sayac = 0 ;
                        durum = 1 ; 
                    end
                    
                    1:  begin
                        genel_sayac = genel_sayac + 1 ; 
                        if (sayac < 9) begin
                            sum_data <= sum_data + data_i_reg[sayac]*kernel_mean[sayac] ;
                            sayac = sayac + 1; 
                            durum = 1 ; 
                        end else begin
                            durum = 2;
                            sayac = 0 ; 
                        end
                    end
                    
                    2: begin // /9
                        genel_sayac = genel_sayac + 1 ;
                        divided_data <= (sum_data << 6) - (sum_data << 3) - sum_data  ; 
                        durum <= 3 ; 
                        sayac = 0 ; 
                    end
                    
                    3 : begin
                        divided_data <= (divided_data >> 9) + (sum_data >> 8 ) + 1 ;
                        durum <= 4 ; 
                    end
                    
                    4 : begin
                        genel_sayac = genel_sayac + 1 ;
                        if (divided_data > 255 ) begin
                            divided_data = 255 ; 
                        end else begin
                            divided_data <= divided_data ; 
                        end
                        durum = 5 ; 
                    end
                    
                    5: begin
                        genel_sayac = genel_sayac + 1 ;
                        sonuc_done_mean <= 1 ; // cıkısa akrtarılmis olacak
                        durum = 6 ; 
                    end
                    
                    6: begin
                        durum = 0 ;                                                    
                        data_i_reg[0] = 0  ; data_i_reg[1] = 0  ; data_i_reg[2] = 0 ;  
                        data_i_reg[3] = 0  ; data_i_reg[4] = 0  ; data_i_reg[5] = 0 ;  
                        data_i_reg[6] = 0  ; data_i_reg[7] = 0  ; data_i_reg[8] = 0 ;  
                        sayac = 0 ;                                                    
                        genel_sayac =  0 ;                                             
                        sum_data = 0 ;                                                 
                        durum = 0 ;                                                    
                        sonuc_done_mean = 0 ;                                          
                    end
                endcase
            end else begin
                durum   = 0;
            end
        end
    end
    
assign data_o       = divided_data  ;
assign sonuc_done   = sonuc_done_mean  ;

endmodule