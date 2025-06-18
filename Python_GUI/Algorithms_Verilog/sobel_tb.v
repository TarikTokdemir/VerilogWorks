// Create Date: 18.06.2025 17:03:20
`timescale 1ns / 1ps
module sobel_tb;

    parameter KERNEL_MxM     = 3;
    parameter Numb_of_Data   = KERNEL_MxM**2;

    reg clk_i_s;
    reg rstn_i_s;
    reg en_i_s;
    reg [7:0] data_i_s;

    // Çýkýþlar
    wire [7:0] data_o_s;
    wire      sobel_done;

    // DUT instance
    sobel #(
        .KERNEL_MxM(KERNEL_MxM),
        .Numb_of_Data(Numb_of_Data)
    ) dut (
        .clk_i_s        (clk_i_s        ),
        .rstn_i_s       (rstn_i_s       ),
        .en_i_s         (en_i_s         ),
        .data_i_s       (data_i_s       ),
        .data_o_s        (data_o_s        ),
        .sobel_done     (sobel_done     )
    );

    always #5 clk_i_s = ~clk_i_s;

    initial begin
        clk_i_s      = 0;
        rstn_i_s     = 0;
        en_i_s       = 0;
        data_i_s  = 8'd0;

        #20;
        rstn_i_s = 1;


        #10;
        en_i_s = 1;
        @(posedge clk_i_s) ;
        @(posedge clk_i_s) ;
        repeat (9) begin
            data_i_s = $random % 256;
            #10;
        end
        
        wait (sobel_done);
        en_i_s = 0;
        
            #10;
            en_i_s = 1;
            @(posedge clk_i_s) ;
            @(posedge clk_i_s) ;
            repeat (9) begin
                data_i_s = $random % 256;
                #10;
            end
            
            wait (sobel_done);
            en_i_s = 0;
            
                #10;
                en_i_s = 1;
                @(posedge clk_i_s) ;
                @(posedge clk_i_s) ;
                repeat (9) begin
                    data_i_s = $random % 256;
                    #10;
                end
                
                wait (sobel_done);
                en_i_s = 0;
        
        #200;
        $finish;
    end

endmodule

