`timescale 100ns / 1ps

module gauss (  
    input       clk_i_g  , rst_i_g  , en_i_g   , 
    input [7:0] data_i_0 , data_i_1 , data_i_2 ,
    input [7:0] data_i_3 , data_i_4 , data_i_5 ,
    input [7:0] data_i_6 , data_i_7 , data_i_8 , 
    
    output[7:0] data_o ,
    output sonuc_done
     );
     
    reg [20:0] mult_data       [0:8]    ;
    reg [7:0]  data_i_reg      [0:8]    ;
    reg [7:0]  kernel_gaussian [0:8]    ;
    
    reg        sonuc_done_g = 0     ;
    reg [16:0] sum_data     = 0     ;  
    reg [16:0] sum_data2    = 0     ;
    reg [6:0]  durum        = 0     ;
    reg [7:0]  div_data             ;
    
    integer i       = 0     ; 
    integer sayac   = 0     ;
    integer g_sayac = 0     ;  

    initial begin
        kernel_gaussian[0] = 8'b001 ; kernel_gaussian[1] = 8'b010 ; kernel_gaussian[2] = 8'b001 ;   //  1  2  1
        kernel_gaussian[3] = 8'b010 ; kernel_gaussian[4] = 8'b100 ; kernel_gaussian[5] = 8'b010 ;   //  2  4  2 
        kernel_gaussian[6] = 8'b001 ; kernel_gaussian[7] = 8'b010 ; kernel_gaussian[8] = 8'b001 ;   //  1  2  1 
    end
    
    always @ ( posedge clk_i_g) begin  
        if(!rst_i_g) begin 
        
        end else begin
            if(en_i_g==1) begin
                g_sayac = g_sayac + 1   ;
                case (durum)
                    0:begin
                        if(sayac<3)begin
                           data_i_reg[0] = data_i_0  ; data_i_reg[1] = data_i_1  ; data_i_reg[2] = data_i_2 ;
                           data_i_reg[3] = data_i_3  ; data_i_reg[4] = data_i_4  ; data_i_reg[5] = data_i_5 ;
                           data_i_reg[6] = data_i_6  ; data_i_reg[7] = data_i_7  ; data_i_reg[8] = data_i_8 ;
                           sayac         = sayac + 1 ;
                        end else begin
                           durum    = 1 ;
                           sayac    = 0 ;
                        end
                    end
                    
                    1:begin
                        if(sayac<9)begin
                            mult_data[i] <= kernel_gaussian[i] * data_i_reg[i];
                            sayac   = sayac + 1 ;
                            i       = i + 1     ;
                            durum   = 1         ;
                        end else begin
                            sayac   = 0     ;
                            i       = 0     ;
                            durum   = 2     ;
                        end
                    end

                    2:begin
                        if(sayac<9)begin
                            sum_data <= sum_data+ mult_data[i];
                            sayac   = sayac + 1     ;
                            i       = i + 1         ;
                            durum   = 2             ;
                        end else begin
                            durum   = 3             ;
                        end
                    end
                    
                    3:begin
                        sum_data2 <= sum_data2 + sum_data ;
                        durum     = 4           ;
                    end
                    
                    4:begin
                        sum_data2 <= sum_data2 >> 4 ; //sum_data2/16; 
                        durum    = 5                ;
                    end
                    
                    5:begin
                        div_data        <= sum_data2 ;
                        sonuc_done_g    <= 1         ;
                        durum           =  6         ;
                    end
                    
                    6:begin
                        i           <= 0 ;
                        sayac       <= 0 ;
                        g_sayac     <= 0 ;
                        
                        sum_data        <= 0    ;
                        sum_data2       <= 0    ;
                        durum           <= 0    ;
                        sonuc_done_g    <= 0    ;
                        
                        mult_data [0] <= 0 ; mult_data [1] <= 0 ; mult_data [2]<=0;
                        mult_data [3] <= 0 ; mult_data [4] <= 0 ; mult_data [5]<=0;
                        mult_data [6] <= 0 ; mult_data [7] <= 0 ; mult_data [8]<=0; 
    
                        data_i_reg[0] <= 0 ; data_i_reg[1] <= 0 ; data_i_reg[2]<=0;
                        data_i_reg[3] <= 0 ; data_i_reg[4] <= 0 ; data_i_reg[5]<=0; 
                        data_i_reg[6] <= 0 ; data_i_reg[7] <= 0 ; data_i_reg[8]<=0;
                   end
                endcase
            end else begin
                g_sayac = 0;
                durum   = 0;
            end
        end
    end
    
assign data_o       = div_data      ;
assign sonuc_done   = sonuc_done_g  ;

endmodule