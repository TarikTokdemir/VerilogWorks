`timescale 1ns/1ps

module tb_ALU_8bit;
    localparam N = 8;
    
    reg  [N-1:0] A, B;
    reg          Cin, Bin;
    reg  [1:0]   sel;
    wire [(2*N)-1:0] Y;
    wire Cout, Bout, gr, le, eq;

    ALU_8bit #(.DATA_WIDTH(N)) dut (
        .A(A), .B(B),
        .Cin(Cin), .Bin(Bin),
        .sel(sel),
        .Y(Y),
        .Cout(Cout), .Bout(Bout),
        .gr(gr), .le(le), .eq(eq)
    );

    integer i;
    initial begin
        for (i=0; i<10; i=i+1) begin
            A   = $random;
            B   = $random;
            Cin = $random;
            Bin = $random;
            sel = $random % 4;   // 0:ADD, 1:SUB, 2:CMP, 3:SQR
            #10;
            $display("sel=%0d A=%0d B=%0d | Y=%0d Cout=%b Bout=%b gr=%b le=%b eq=%b",
                     sel, A, B, Y, Cout, Bout, gr, le, eq);
            A   = 254;    
            B   = 255;    
            Cin = 0;    
            Bin = 0;    
            sel = 1;
            #10;  
            
            A   = 254;                
            B   = 255;    
            Cin = 1;    
            Bin = 1;    
            sel = 1;
            #10;              
            
            
        end
        $finish;
    end
endmodule
