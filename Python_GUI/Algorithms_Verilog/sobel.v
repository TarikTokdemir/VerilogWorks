`timescale 1ns / 1ps
// Create Date: 18.06.2025 16:26:36
module sobel 
#(
    parameter KERNEL_MxM = 3, // 3x3
    parameter Numb_of_Data = KERNEL_MxM**2
)
( 
    input  clk_i_s,rstn_i_s ,  
    input  en_i_s            ,
    input  [7:0] data_i_s  , 

    output [7:0] data_o_s    , 
    output sobel_done        
);
reg [7:0]  data_i_reg       [0:8]; // buffer 
reg signed [2:0]  kernel_sobel_x    [0:8]; // cekirdek matrisler 9 tane 3x3
reg signed [2:0]  kernel_sobel_y    [0:8]; // cekirdek matrisler 9 tane 3x3
reg [10:0] counter ; 
reg [3:0] STATE_SOBEL ;

reg signed [10:0] mult_data_x       [0:8]; // carpim sonuclarini tutar  
reg signed [10:0] mult_data_y       [0:8]; // carpim sonuclarini tutar  
reg signed [10:0] sum_result_x , sum_result_y ; // 255 + 512 + 212 + 0 + 0 + 0 - 0 - 0 - 0 = 1024 Max positive value = 11 bit need
reg [7:0] data_o_reg ;
reg sobel_done_reg ;

localparam  INIT        = 4'd0 ,
            DATA_IN     = 4'd1 ,
            PROCESS     = 4'd2 ,
            SUM         = 4'd3 ,
            GRADIENT    = 4'd4 ,
            LAST        = 4'd5 ,
            INIT15      = 4'd15 ;

always @ (posedge clk_i_s or negedge rstn_i_s) begin  
    if (!rstn_i_s) begin 
        STATE_SOBEL <= 0 ;
    end else begin
        if (en_i_s == 1) begin
            case (STATE_SOBEL)
                INIT : begin // 0
                    data_i_reg[0]<=0;    data_i_reg[1]<=0;    data_i_reg[2]<=0;
                    data_i_reg[3]<=0;    data_i_reg[4]<=0;    data_i_reg[5]<=0;
                    data_i_reg[6]<=0;    data_i_reg[7]<=0;    data_i_reg[8]<=0;
             
                    data_i_reg[0]<=0;    data_i_reg[1]<=0;    data_i_reg[2]<=0;
                    data_i_reg[3]<=0;    data_i_reg[4]<=0;    data_i_reg[5]<=0;
                    data_i_reg[6]<=0;    data_i_reg[7]<=0;    data_i_reg[8]<=0;
                    // Source : OpenCv
                    kernel_sobel_x[0]<= 3'b111 ; kernel_sobel_x[1]<= 3'b000 ;  kernel_sobel_x[2]<= 3'b001 ;  //    -1  0  +1
                    kernel_sobel_x[3]<= 3'b110 ; kernel_sobel_x[4]<= 3'b000 ;  kernel_sobel_x[5]<= 3'b010 ;  //    -2  0  +2
                    kernel_sobel_x[6]<= 3'b111 ; kernel_sobel_x[7]<= 3'b000 ;  kernel_sobel_x[8]<= 3'b001 ;  //    -1  0  +1
                                     
                    kernel_sobel_y[0]<= 3'b111 ; kernel_sobel_y[1]<= 3'b110 ;  kernel_sobel_y[2]<= 3'b111 ;  //    -1  -2  -1 
                    kernel_sobel_y[3]<= 3'b000 ; kernel_sobel_y[4]<= 3'b000 ;  kernel_sobel_y[5]<= 3'b000 ;  //     0   0   0 
                    kernel_sobel_y[6]<= 3'b001 ; kernel_sobel_y[7]<= 3'b010 ;  kernel_sobel_y[8]<= 3'b001 ;  //    +1   2  +1 
                    
                    counter <= 0 ;
                    sobel_done_reg <= 0 ;
                    STATE_SOBEL <= DATA_IN ;
                end
            
                DATA_IN : begin // 1 
                    if (counter < Numb_of_Data) begin
                        data_i_reg[counter]<= data_i_s ; 
                        counter <= counter + 1 ; 
                    end else begin
                        counter <= 0 ; 
                        STATE_SOBEL <= PROCESS ; 
                    end
                end
                
                PROCESS : begin // 2 
                    if (counter < Numb_of_Data) begin
                        if (kernel_sobel_x[counter] == 3'b111 ) begin // -1
                            mult_data_x[counter] <= ~(data_i_reg[counter])+1   ;
                        end else if (kernel_sobel_x[counter] == 3'b110 ) begin // -2 
                            mult_data_x[counter] <= ~(data_i_reg[counter] << 1)+1 ;
                        end else if (kernel_sobel_x[counter] == 3'b001 ) begin // +1 
                            mult_data_x[counter] <=  (data_i_reg[counter]) ;
                        end else if (kernel_sobel_x[counter] == 3'b010 ) begin // +2 
                            mult_data_x[counter] <=  (data_i_reg[counter] << 1) ;
                        end else begin // 0 
                            mult_data_x[counter] <= 0 ;
                        end
                        
                        if (kernel_sobel_y[counter] == 3'b111 ) begin // -1
                            mult_data_y[counter] <= ~(data_i_reg[counter])+1   ;
                        end else if (kernel_sobel_y[counter] == 3'b110 ) begin // -2 
                            mult_data_y[counter] <= ~(data_i_reg[counter] << 1)+1 ;
                        end else if (kernel_sobel_y[counter] == 3'b001 ) begin // +1 
                            mult_data_y[counter] <=  (data_i_reg[counter]) ;
                        end else if (kernel_sobel_y[counter] == 3'b010 ) begin // +2 
                            mult_data_y[counter] <=  (data_i_reg[counter] << 1) ;
                        end else begin // 0 
                            mult_data_y[counter] <= 0 ;
                        end
                        
                        counter <= counter + 1 ;
                    end else begin
                        counter <= 0 ; 
                        STATE_SOBEL <= SUM ; 
                    end
                end

                SUM : begin // 3 
                    sum_result_x <= mult_data_x[0] + mult_data_x[1] + mult_data_x[2] +
                                    mult_data_x[3] + mult_data_x[4] + mult_data_x[5] +
                                    mult_data_x[6] + mult_data_x[7] + mult_data_x[8] ;
                    sum_result_y <= mult_data_y[0] + mult_data_y[1] + mult_data_y[2] +
                                    mult_data_y[3] + mult_data_y[4] + mult_data_y[5] +
                                    mult_data_y[6] + mult_data_y[7] + mult_data_y[8] ;
                    STATE_SOBEL <= GRADIENT ;
                end
                
                GRADIENT : begin // 4 
                    if (sum_result_x[10] == 1) // negative
                        sum_result_x <= ~sum_result_x + 1 ;
                    
                    if (sum_result_y[10] == 1)  // negative
                        sum_result_y <= ~sum_result_y + 1 ;
                    
                    STATE_SOBEL <= LAST ;
                end
                
                LAST : begin // 5 
                    if (sum_result_x + sum_result_y > 11'd255) 
                        data_o_reg <= 8'd255 ;
                    else 
                        data_o_reg <= sum_result_x + sum_result_y ; 
                    
                    sobel_done_reg <= 1 ; 
                    STATE_SOBEL <= INIT ;
                end
            endcase
        end
    end
end
assign data_o_s = data_o_reg ;
assign sobel_done = sobel_done_reg ; 
endmodule