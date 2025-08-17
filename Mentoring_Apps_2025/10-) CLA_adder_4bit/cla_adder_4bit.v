`timescale 1ns / 1ps

module cla_adder_4bit #(

parameter W = 8   // width

) (
    input wire  [W-1:0] a_in , b_in ,
    input wire  [0:0] c_in ,
    output wire [W:0] sum_out 
    );
    
    wire [W-1:0] p , g ;
    reg [W:0] c ;
    
    assign c[0] = c_in ;   // sabit olmalsi gerekir 
    
    genvar i ;  // Modul sayisini zaten parametrik yapmistik 
    generate 
        for(i=0 ; i<W ; i = i+1) begin
            partial_fa pfa (
                .a      (a_in[i]    ),
                .b      (b_in[i]    ),
                .cin    (c[i]       ),
                .s      (sum_out[i] ),
                .p      (p[i]       ),
                .g      (g[i]       )
            );
        end
    endgenerate 
    
//    genvar x , y ;  // Modul sayisini zaten parametrik yapmistik 
//    generate 
//        for(x=0 ; x<W ; x = x+1) begin
//            assign c[x+1] = g[x] ;

//            for (y=x
//        end
//    endgenerate 
    
    
    reg [W-1:0] j , k ;   // 8 bit yupamak istiyodum   // 8 yazarsam 2^8'den  0 ~ 255 deger
    always @(*) begin  // caarry hespalmaalri icin 
        for (j=0; j<W; j=j+1) begin
            c[j+1] = g[j];
            for (k=j-1; k>=0; k=k-1)
                c[j+1] = c[j+1] | (&p[j:k+1] & g[k]);
            c[j+1] = c[j+1] | (&p[j:0] & c[0]);
        end
    end
    
    
    
    
    
    
////////////////////////////////////////////////////////////////////////////
//    assign c[1] = g[0] | (p[0] & c_in) ;
//    assign c[2] = g[1] | (g[0]&p[1]) | (p[1]&p[0]&c_in);
//    assign c[3] = g[2] | (g[1]&p[2]) | (g[0]&p[2]&p[1]) | (p[2]&p[1]&p[0]&c_in);
//    assign c[4] = g[3] | (g[2]&p[3]) | (g[1]&p[3]&p[2]) | (g[0]&p[3]&p[2]&p[1]) | (p[3]&p[2]&p[1]&p[0]&c_in); 
////////////////////////////////////////////////////////////////////////////


    
    
    
////////////////////////////////////////////////////////////////////////////
//    partial_fa bit0 (
//        .a      (a_in[0] ),
//        .b      (b_in[0] ),
//        .cin    (c_in[0] ),
//        .s      (sum_out[0] ),
//        .p      (p[0] ),
//        .g      (g[0] )
//    );
    
//    partial_fa bit1 (
//        .a      (a_in[1] ),
//        .b      (b_in[1] ),
//        .cin    (c[1]),
//        .s      (sum_out[1] ),
//        .p      (p[1] ),
//        .g      (g[1] )
//    );
    
//    partial_fa bit2 (
//        .a      (a_in[2] ),
//        .b      (b_in[2] ),
//        .cin    (c[2] ),
//        .s      (sum_out[2] ),
//        .p      (p[2] ),
//        .g      (g[2] )
//    );
    
//    partial_fa bit3 (
//        .a      (a_in[3] ),
//        .b      (b_in[3] ),
//        .cin    (c[3]       ),
//        .s      (sum_out[3] ),
//        .p      (p[3]       ),
//        .g      (g[3] )
//    );
////////////////////////////////////////////////////////////////////////////
    
endmodule
