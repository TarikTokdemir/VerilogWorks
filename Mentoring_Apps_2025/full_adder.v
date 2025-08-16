module full_adder(
    input wire  a   ,
    input wire  b   , 
    input wire  cin ,
    output wire sum , 
    output wire cout
);
    wire sum1 , carry1 , carry2 ;
    
    half_adder ha1 (
        //  atama y�n� sola do�ru <--
        .a    (a        ) ,
        .b    (b        ) ,
        // --> y�n sa�a 
        .sum  (sum1     )  ,   //outputtu alt modulde
        .carry(carry1   )    //outputtu alt modulde
    );
    
    half_adder ha2 (
        .a (sum1)        ,
        .b (cin)         ,
        
        .sum   (sum)     ,
        .carry (carry2)
    );
    
    assign cout = carry1  |  carry2  ;
endmodule