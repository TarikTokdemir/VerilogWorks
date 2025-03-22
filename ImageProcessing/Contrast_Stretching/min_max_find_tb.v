`timescale 1ns / 1ps

module min_max_find_tb;

parameter DATA_WIDTH = 8;
parameter RAM_DEPTH  = 76800; 
parameter ADDR_WIDTH = $clog2(RAM_DEPTH);

reg                   clk_i_min_max;
reg                   rstn_i_min_max;
reg                   en_i_min_max;
reg  [DATA_WIDTH-1:0] data_i_min_max;
reg                   last_i_min_max;

wire [DATA_WIDTH-1:0] data_o_min_value;
wire [DATA_WIDTH-1:0] data_o_max_value;
wire                  done_o_min_max;

min_max_find #(
    .DATA_WIDTH(DATA_WIDTH),
    .RAM_DEPTH(RAM_DEPTH),
    .ADDR_WIDTH(ADDR_WIDTH)
) uut (
    .clk_i_min_max(clk_i_min_max),
    .rstn_i_min_max(rstn_i_min_max),
    .en_i_min_max(en_i_min_max),
    .data_i_min_max(data_i_min_max),
    .last_i_min_max(last_i_min_max),
    .data_o_min_value(data_o_min_value),
    .data_o_max_value(data_o_max_value),
    .done_o_min_max(done_o_min_max)
);

always #5 clk_i_min_max = ~clk_i_min_max;



integer i;
reg [DATA_WIDTH-1:0] min_max_datas [0:RAM_DEPTH];

initial begin
    $readmemb("C:/Users/pc/Desktop/VGA PROJECTS/goruntu_isleme_algoritma/9_kontrast_germe/min_max_datas.mem", min_max_datas) ;
    //min value = 28 and max value = 223 of memory
    clk_i_min_max   = 0;
    rstn_i_min_max  = 0;
    en_i_min_max    = 0;
    data_i_min_max  = 0;
    last_i_min_max  = 0;

    #10;
    rstn_i_min_max = 1;
    en_i_min_max   = 1;
    
    for (i = 0; i < RAM_DEPTH; i = i + 1) begin
        data_i_min_max = min_max_datas[i];
        last_i_min_max = (i == RAM_DEPTH-1) ? 1'b1 : 1'b0;
        #10;
    end

    wait(done_o_min_max);
    #10;

    $display("Minimum Deðer: %d", data_o_min_value);
    $display("Maksimum Deðer: %d", data_o_max_value);

    if (data_o_min_value == 28 && data_o_max_value == 223)
        $display("Test Baþarýlý!");
    else
        $display("Test Baþarýsýz!");

    #10;
    $finish;
end

endmodule
