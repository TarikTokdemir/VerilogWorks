`timescale 1ns/1ps

module top_contrast_stretching_tb;

  parameter DATA_WIDTH = 8;
  parameter RAM_DEPTH  = 76800;
  parameter ADDR_WIDTH = $clog2(RAM_DEPTH);

  reg                     clk;
  reg                     rstn_i_top_contrast;
  reg                     en_i_top_contrast;
  reg  [DATA_WIDTH-1:0]   data_i_top_contrast;
  wire [DATA_WIDTH-1:0]   data_o_top_contrast;
  wire                    done_o_top_contrast;
  wire                    done_process ;
  
  integer i;
  integer file; 

  reg [DATA_WIDTH-1:0] in_mem  [0:RAM_DEPTH-1];
  reg [DATA_WIDTH-1:0] out_mem [0:RAM_DEPTH-1];
  
  top_contrast_stretching #(
    .DATA_WIDTH(DATA_WIDTH),
    .RAM_DEPTH(RAM_DEPTH),
    .ADDR_WIDTH(ADDR_WIDTH)
  ) dut (
    .clk_i_top_contrast(clk),
    .rstn_i_top_contrast(rstn_i_top_contrast),
    .en_i_top_contrast(en_i_top_contrast),
    .data_i_top_contrast(data_i_top_contrast),
    .data_o_top_contrast(data_o_top_contrast),
    .done_process(done_process),
    .done_o_top_contrast(done_o_top_contrast)
  );

  always #5 clk = ~clk;

initial begin
    $readmemb("C:/Users/pc/Desktop/VGA PROJECTS/goruntu_isleme_algoritma/9_kontrast_germe/kontrast_image2.mem", in_mem);
    file = $fopen("C:/Users/pc/Desktop/VGA PROJECTS/goruntu_isleme_algoritma/9_kontrast_germe/kontrast_image2_out.mem", "w");
    if (file == 0) begin
      $display("Dosya acilamadi!");
      $finish;
    end
end
  initial begin
    clk = 0;
    rstn_i_top_contrast = 0;
    en_i_top_contrast = 0;
    data_i_top_contrast = 0;

    #5;
    rstn_i_top_contrast = 1;

    #10;
    en_i_top_contrast = 1;
    #10;

    for (i = 0; i < RAM_DEPTH; i = i + 1) begin
        data_i_top_contrast = in_mem[i];
        #10;
    end //ram1 e yazma bitti

    wait(done_process) ;
    #50;
    
    for (i = 0; i < RAM_DEPTH; i = i + 1) begin
        out_mem[i] = data_o_top_contrast;
        $fdisplay(file, "%b", data_o_top_contrast);
        #10;
    end

//    for (i = 0; i < RAM_DEPTH; i = i + 1) begin
//        $fdisplay(file, "%b", out_mem[i]);
//    end
    
    wait (done_o_top_contrast == 1);
    en_i_top_contrast = 0;

    $fclose(file);
    $stop;
  end

endmodule
