`timescale 1ns / 1ps
module bit_akis_kontrolu(
    input wire          i_clk           , 
    input wire          i_rstn          , 
    input wire [2:0]    i_data          , 
    input wire          i_flag          , 
    output wire         o_ERR           ,
    output wire         o_ERR_done  // artýk o_ERR sinyali gecerlidir.  
    );
reg [2:0] r_STATE ;  // 8 durum var 
localparam  START = 3'd0 , 
            S0    = 3'd1 , 
            S1    = 3'd2 , 
            S2    = 3'd3 , 
            S3    = 3'd4 , 
            S4    = 3'd5 , 
            S5    = 3'd6 , 
            IDLE  = 3'd7 ;
            
reg [2:0] r_shift_data ;
reg r_ERR ; 
reg r_din ; 
assign o_ERR =  r_ERR ;

reg r_ERR_done ;                    // flag
assign o_ERR_done  = r_ERR_done ;   // flag

always @* begin
    r_din = r_shift_data[2];
end

always @(posedge i_clk or negedge i_rstn) begin
    if( !i_rstn ) begin
        r_STATE <= 0 ; 
        r_ERR   <= 0 ;
        r_shift_data <= 0 ;
        r_din   <= 0 ; 
        r_shift_data <= 0 ; 
        r_ERR_done <= 0 ;
    end else begin
        case (r_STATE) 
            START : begin 
                r_shift_data <= i_data ;  // shift_ data , veri kaybolmamasý icin 
                r_ERR_done   <= 0 ; 
                if (i_flag) // flag == 1 
                    r_STATE     <= S0 ; 
            end 
            
            S0 : begin   // << 1 ; 
                r_ERR_done <= 0 ; 
                r_shift_data <= {r_shift_data[1:0] , r_shift_data[2]}; // 1 bit kaydirma //////////////////////////////////////////////////////////////////// sonradan eklendi
                r_STATE <= S1 ; 
            end 
            
            S1 : begin 
                if (r_din) begin   // r_din == 1'b1 
                    r_ERR_done <= 0 ;
                    r_STATE <= S2 ;    // hata cikma ihtimali hala var . 1 degeri geldi
                end else begin
                    r_ERR_done <= 1 ;
                    r_ERR <= 0 ;
                    r_STATE <= IDLE ; 
                end
            end 
            
            S2 : begin
                r_ERR_done <= 0 ;
                r_shift_data <= {r_shift_data[1:0] , r_shift_data[2]}; // 1 bit kaydirma
                r_STATE <= S3 ; 
            end 
            
            S3 : begin 
                if (r_din == 1'd1) begin
                    r_ERR_done <= 0 ;
                    r_STATE <= S4 ; 
                end else begin // herhangi bir 0 degeri geldiyse 
                    r_ERR_done <= 1 ;
                    r_ERR <= 0 ;
                    r_STATE <= IDLE ; 
                end
            end 
            
            S4 : begin 
                r_shift_data <= {r_shift_data[1:0] , r_shift_data[2]};
                r_ERR_done <= 0 ;
                r_STATE <= S5 ; 
            end 
            
            S5 : begin 
                if(r_din == 1'b1) begin // 3.kaydirma sonucu da 1 degeri geldiyse 
                    r_ERR <= 1'b1 ; 
                end else begin
                    r_ERR <= 0 ; 
                end
                
                r_STATE     <= IDLE ;
                r_ERR_done  <= 1 ;
            end 
            
            IDLE : begin 
                r_ERR           <= 0 ;
                r_shift_data    <= 0 ;
                r_din           <= 0 ; 
                r_shift_data            <= 0 ; 
                r_ERR_done      <= 0 ;
                r_STATE         <= START ; // r_ERR = 0 
            end 
            
            default : begin
                r_STATE <= START ; 
                r_ERR   <= 0 ; 
            end
        endcase 
    end
end
endmodule
