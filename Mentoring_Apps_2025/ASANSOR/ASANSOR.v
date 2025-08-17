`timescale 1ns / 1ps

module ASANSOR(
    input wire i_clk ,
    input wire i_rst ,
    input wire [1:0] i_btn , 
    
    output reg [1:0] o_led 
    );
    
reg [1:0] STATE ;

localparam  KAT0 = 2'd0 ,
            KAT1 = 2'd1 ,
            KAT2 = 2'd2 ;

localparam  KIRMIZI = 2'd0 ,
            YESIL   = 2'd1 , 
            MAVI    = 2'd2 ;
     
    always @(posedge i_clk or posedge i_rst) begin
        if( i_rst ) begin
            o_led   <= 'd0 ; 
            STATE   <= 'd0 ; 
        end
        else begin
            case (STATE) 
                KAT0 : begin
                    if (i_btn == 2'b01) begin
                        STATE <= KAT1 ;
                    end else if ( i_btn == 2'b10 ) begin  // 
                        STATE <= KAT2 ;
                    end else begin  // 11 
                        STATE <= KAT0 ; 
                    end
                end
                
                KAT1 : begin
                    if (i_btn == 2'b00) begin
                        STATE <= KAT0 ;
                    end else if (i_btn == 2'b10) begin
                        STATE <= KAT2 ;
                    end else begin
                        STATE <= KAT1 ; //01
                    end
                end
                
                KAT2 : begin
                    if (i_btn == 2'b00) begin
                        STATE <= KAT0 ; 
                    end else if (i_btn == 2'b01) begin
                        STATE <= KAT1 ;
                    end else begin
                        STATE <= KAT2 ; 
                    end
                end
                
                default : begin
                    if (i_btn == 2'b00) begin
                        STATE <= KAT0 ; 
                    end else if (i_btn == 2'b01) begin
                        STATE <= KAT1 ; 
                    end else begin
                        STATE <= KAT2 ; 
                    end
                end
            endcase 
        end
    end
    
    always @(*) begin
        case (STATE) 
            KAT0 : o_led = KIRMIZI ; 
            KAT1 : o_led = YESIL ; 
            KAT2 : o_led = MAVI ; 
            default : o_led = KAT0 ;
        endcase 
    end
endmodule
