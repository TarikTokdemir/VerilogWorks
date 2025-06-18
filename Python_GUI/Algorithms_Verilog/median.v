// Create Date: 18.06.2025 10:01:43

`timescale 100ns / 1ps

module median #(
        parameter DATA_SAYISI = 25   // 3x3 5x5 7x7   // 9 25 41
    )(  
    input       clk_i_median    , 
    input       rstn_i_median   , 
    input       en_i_median     , 
    input [7:0] data_i_median   ,
     
    output [7:0] data_o_median ,
    output median_done
     );

    
reg [7:0]   median_array   [0:DATA_SAYISI-1]  ; 
reg [7:0]   index_cntr      ; 
reg [7:0]   sort_cntr       ;  
reg [7:0]   iteration_cntr  ; 


reg median_done_reg ; 
assign median_done = median_done_reg ; 
reg data_o_median_reg ; 
assign data_o_median = data_o_median_reg ; 

reg [2:0] STATE_MED ; 
localparam  IDLE        = 3'd0 ,
            DATA_REGS   = 3'd1 ,
            SORT        = 3'd2 ,
            ITERATION   = 3'd3 ,
            IDLE5       = 3'd4 ,
            IDLE6       = 3'd5 ;
            
reg [7:0] temp1 ;
reg [7:0] temp2 ;
    always @* begin
        if (median_array[sort_cntr] > median_array[sort_cntr+1]) begin
            temp1 = median_array[sort_cntr] ;
            temp2 = median_array[sort_cntr+1] ;
        end
    end           
    
    always @ ( posedge clk_i_median or negedge rstn_i_median) begin  
        if(!rstn_i_median) begin 
            STATE_MED <= IDLE ; 
        end else begin
                case (STATE_MED)
                    IDLE : begin
                        index_cntr         <= 0 ; 
                        sort_cntr          <= 0 ; 
                        iteration_cntr     <= 0 ; 
                        median_done_reg    <= 0 ; 
                        data_o_median_reg  <= 0 ; 
                        index_cntr  <= 0 ; 
                        if (en_i_median) begin
                            STATE_MED <= DATA_REGS ; 
                        end
                    end
                    
                    DATA_REGS: begin
                        if (index_cntr < DATA_SAYISI) begin
                            median_array[index_cntr] <= data_i_median ; 
                            index_cntr  <= index_cntr + 1 ; 
                        end else begin
                            index_cntr <= 0 ; 
                            STATE_MED <= SORT ; 
                        end
                    end  
                    
                    SORT : begin
                        if (sort_cntr < DATA_SAYISI-1) begin
                            if (median_array[sort_cntr] > median_array[sort_cntr+1]) begin
                                median_array[sort_cntr+1]   <= temp1 ; 
                                median_array[sort_cntr]     <= temp2 ;
                            end else begin // degilse sabit kalacak
                                sort_cntr <= sort_cntr + 1;
                            end
                        end else begin
                            sort_cntr <= 0 ; 
                            STATE_MED <= ITERATION ; 
                        end
                    end
                        
                    ITERATION : begin
                        if (iteration_cntr < DATA_SAYISI) begin 
                            iteration_cntr <= iteration_cntr + 1 ; 
                            STATE_MED <= SORT ; 
                        end else begin
                            iteration_cntr <= 0 ;
                            median_done_reg <= 1 ; 
                            data_o_median_reg <= median_array[(DATA_SAYISI-1)/2];
                            STATE_MED <= IDLE ;
                        end
                    end
                endcase
        end
    end


endmodule
