`timescale 1ns / 1ps
module bolme(
    input clk ,
    input rst ,
    input start ,
    input [3:0] bolunen ,
    input [3:0] bolen ,
    output[3:0] kalan ,
    output[3:0] bolum ,
    output reg done,
    output reg divisor_zero
    );
    
    localparam IDLE  = 2'b00;
    localparam SHIFT = 2'b01;
    localparam DONE  = 2'b10;
    
    reg [1:0] state;
//    reg [1:0] nextstate;
    
    reg [4:0] rem ; //5 bit  çýkartma iþleminde güvenlik için
    reg [2:0] count ;
    reg [3:0] bm_reg; // kalan çýkýþý
    reg [3:0] kal_reg;// bölüm çýkýþý
    
    assign bolum = bm_reg;
    assign kalan = kal_reg;
//    always @ (*) begin
//        nextstate = state ;
//        case (state)  
//            // bölme iþleminde bölen sýfýrsa tanýmsýzdýr iþlemi bitir 
//            // bölen sýfýr deðilse bölme iþlemine devam etsin 
//            IDLE  : if (start) nextstate = ( bolen == 4'd0) ?  DONE : SHIFT;
//            SHIFT : nextstate = SUBS;
//            SUBS  : nextstate = (count == 3'd4 ) ? DONE : SHIFT ;
//            DONE  : nextstate = IDLE ;
        
//        endcase
//    end 
    
    always @ ( posedge clk or negedge rst ) begin
        if (!rst) begin
            state <= IDLE;
            kal_reg <= 4'b0 ;
            bm_reg <= 4'b0 ;
            count <= 3'b0;
            rem   <= 5'b0;
            done  <= 1'b0;
            divisor_zero <= 1'b0;
                
        end 
        else begin
//            state <= nextstate;
            
            case (state)
            
            IDLE : begin
                done <= 1'b0;
                divisor_zero <= 1'b0;
                
                if (start) begin
                    if ( bolunen == 4'd0) begin
                        bm_reg       <= 4'd0;
                        kal_reg      <= bolunen;
                        divisor_zero <= 1'b1; 
                        done         <= 1'b1;
                        state <= DONE; 
                    end
                    else begin
                        rem    <= 5'd0;
                        bm_reg <= bolunen;
                        count  <= 3'b0;
                        state <= SHIFT;
                    end
                end    
            end
            
            SHIFT : begin
            
                rem <= { rem [3:0], bm_reg [3]};
                bm_reg <= { bm_reg [2:0] ,1'b0};
                
                if ({rem [3:0], bm_reg [3]} >= bolen) begin
                
                    rem <= {rem [3:0], bm_reg [3]} - bolen;
                    bm_reg[0] <= 1'b1;
                end
                else begin 
                
                  bm_reg[0] <= 1'b0;
                end
               
                if (count ==3'd3) begin
                    kal_reg <= ( ({rem [3:0],bm_reg[3]} >= bolen) ? ({rem [3:0],bm_reg[3]}- bolen) : {rem[3:0], bm_reg[3]});
                    done <=1'b1;
                    state <= DONE;
                end
                else begin
                    count <= count + 1 ;  
                    state <= SHIFT ;
                end
            end
            
            DONE : begin
            
            end
            endcase        
        end
    end
    
endmodule
