`timescale 1ns / 1ps
module tb();
reg clk = 0  ;            
reg rst = 0  ;            
reg start = 0  ;          
reg [3:0] bolunen ;  
reg [3:0] bolen ;    
wire [3:0] kalan ;    
wire [3:0] bolum ;    
wire done;       
wire divisor_zero;

bolme dur (
. clk(clk),
. rst (rst) ,
. start (start),
. bolunen (bolunen),
. bolen (bolen),
. kalan (kalan),
. bolum (bolum),
. done  (done),
.divisor_zero (divisor_zero)
);
always #5 clk = ~clk;

initial begin 
#10 ;
rst = 1;
#10 ;
bolunen = 4'd15;
bolen  =  4'd2;
#10 start=1;

#20 start=0;

#20 $finish ;
 
end
endmodule
