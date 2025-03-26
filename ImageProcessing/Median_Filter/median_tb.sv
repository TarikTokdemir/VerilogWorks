`timescale 1ns / 1ps
module median_tb;

  parameter WIDTH  = 320; // Görüntü geniþliði
  parameter HEIGHT = 240; // Görüntü yüksekliði

  reg  clk = 0;
  reg  rst = 0;
  reg  en  = 0;
  reg  [7:0] data_in [0:8];
  
  wire [7:0] data_out;
  wire done;
  
  median uut (
      .clk_i_median    (clk), .rst_i_median    (rst), .en_i_median       (en),
      .data_i_0   (data_in[0]), .data_i_1   (data_in[1]), .data_i_2   (data_in[2]),
      .data_i_3   (data_in[3]), .data_i_4   (data_in[4]), .data_i_5   (data_in[5]),
      .data_i_6   (data_in[6]), .data_i_7   (data_in[7]), .data_i_8   (data_in[8]),
      .data_o     (data_out), .sonuc_done (done)
  );

  integer file_median, file_x, file_y;
  reg [7:0] Mem_array [0:WIDTH*HEIGHT-1]; 
  integer r, c;
  always #5 clk = ~clk;
  int x_result, y_result, gradient;
  
   function automatic int abs_func(input int value);
      begin
          if (value < 0)
              abs_func = -value; // Negatifse iþaretsiz deðeri al
          else
              abs_func = value; // Pozitifse deðeri olduðu gibi al
      end
  endfunction 
    
  initial begin
    $readmemb("C:/Users/pc/Desktop/VGA PROJECTS/goruntu_isleme_algoritma/5_median/median_input_gray.mem", Mem_array);
    $display("Goruntu dosyasi yuklendi.");
    #100;
    file_median   = $fopen("C:/Users/pc/Desktop/VGA PROJECTS/goruntu_isleme_algoritma/5_median/median_output_verilog.mem", "w"); // Toplam sonuc

    rst = 1;
    en  = 1;
    
    for (r = 0; r <= HEIGHT - 3; r = r + 1) begin
      for (c = 0; c <= WIDTH - 3; c = c + 1) begin
        en = 1;
        data_in[0] = Mem_array[r * WIDTH + c];
        data_in[1] = Mem_array[r * WIDTH + (c+1)];
        data_in[2] = Mem_array[r * WIDTH + (c+2)];
        data_in[3] = Mem_array[(r+1) * WIDTH + c];
        data_in[4] = Mem_array[(r+1) * WIDTH + (c+1)];
        data_in[5] = Mem_array[(r+1) * WIDTH + (c+2)];
        data_in[6] = Mem_array[(r+2) * WIDTH + c];
        data_in[7] = Mem_array[(r+2) * WIDTH + (c+1)];
        data_in[8] = Mem_array[(r+2) * WIDTH + (c+2)];
        #1;
//        x_result =  (data_in[0] * -1) + (data_in[1] * uut.kernel_sobel_x[1]) + (data_in[2] * uut.kernel_sobel_x[2]) +
//                    (data_in[3] * -2) + (data_in[4] * uut.kernel_sobel_x[4]) + (data_in[5] * uut.kernel_sobel_x[5]) +
//                    (data_in[6] * -1) + (data_in[7] * uut.kernel_sobel_x[7]) + (data_in[8] * uut.kernel_sobel_x[8]);
                    
//        y_result =  (data_in[0] * 1 ) + (data_in[1] * 2 ) + (data_in[2] * 1 ) +
//                    (data_in[3] * 0 ) + (data_in[4] * 0 ) + (data_in[5] * 0 ) +
//                    (data_in[6] * -1) + (data_in[7] * -2) + (data_in[8] * -1);
        #1;
//        gradient = abs_func(x_result) + abs_func(y_result);
//        #1;
//        if (gradient < 0 ) begin
//            gradient = 0 ; 
//        end
//        if (x_result < 0 ) begin
//            x_result = -x_result; //pzitife cevir
//        end
//        if (y_result < 0 ) begin
//            y_result = -y_result ; // pozitife cevir
//        end
        
        
//      $display(" %0d  %0d  %0d   ///   INDEX: [%2d x%2d ]  [%2d x%2d ]  [%2d x%2d ]   ///   MEM[%2d] MEM[%2d] MEM[%2d]  ///   X: %0d  Y: %0d  Gradient: %0d",
//                data_in[0] , data_in[1], data_in[2],  
//                r, c,   r, c+1,   r, c+2,   
//                r*WIDTH + c, r*WIDTH + (c+1), r*WIDTH + (c+2),
//                x_result, y_result, gradient);

//      $display(" %0d  %0d  %0d   ///   INDEX: [%2d x%2d ]  [%2d x%2d ]  [%2d x%2d ]   ///   MEM[%2d] MEM[%2d] MEM[%2d]  ///   X: %0d  Y: %0d  Gradient: %0d",
//                data_in[3], data_in[4], data_in[5],  
//                r+1, c,   r+1, c+1,   r+1, c+2, 
//                (r+1)*WIDTH + c, (r+1)*WIDTH + (c+1), (r+1)*WIDTH + (c+2),
//                x_result, y_result, gradient);

//      $display(" %0d  %0d  %0d   ///   INDEX: [%2d x%2d ]  [%2d x%2d ]  [%2d x%2d ]   ///   MEM[%2d] MEM[%2d] MEM[%2d]  ///   X: %0d  Y: %0d  Gradient: %0d ",
//                data_in[6], data_in[7], data_in[8],  
//                r+2, c,   r+2, c+1,   r+2, c+2, 
//                (r+2)*WIDTH + c, (r+2)*WIDTH + (c+1), (r+2)*WIDTH + (c+2),
//                x_result, y_result, gradient);
//        #1;
        wait(done);
//        $display (" Algoritma x sonucu=%0d\n" , uut.sonuc_x  );
        $fwrite(file_median, "%08b\n", data_out[7:0]);
//        $fwrite(file_median, "%08b\n", gradient[8:0]);
        #10;
      end
    end
    $fclose(file_median);

    $finish;
  end
  
endmodule