`timescale 1ns / 1ps

module gauss_tb;
 // Görüntü boyutlarý
  parameter WIDTH  = 320; // genislik
  parameter HEIGHT = 240; // uzunluk
  

    reg  clk = 0            ;
    reg  rst = 0            ;
    reg  en  = 0            ;
    reg  [7:0] data_in [0:8];
    
    wire [7:0] data_out     ;
    wire done               ;
    
    integer i               ;
    
    gauss uut (
        .clk_i_g    (clk)       ,
        .rst_i_g    (rst)       ,
        .en_i_g       (en)        ,
        .data_i_0   (data_in[0]),
        .data_i_1   (data_in[1]),
        .data_i_2   (data_in[2]),
        .data_i_3   (data_in[3]),
        .data_i_4   (data_in[4]),
        .data_i_5   (data_in[5]),
        .data_i_6   (data_in[6]),
        .data_i_7   (data_in[7]),
        .data_i_8   (data_in[8]),
        .data_o     (data_out)  ,
        .sonuc_done (done)
    );

integer file_gauss;

reg [7:0] Mem_array [0:WIDTH*HEIGHT-1]; 
 integer r, c; // pencere baslangic koordinatlari: row satýr (r) ve column sutun (c)
  
    always #5 clk = ~clk;

    initial begin
        
        // Dosya, her satýrda 8-bit binary (ör. "10101010") içermelidir.
        $readmemb("C:/Users/pc/Desktop/VGA PROJECTS/goruntu_isleme_algoritma/3_gauss/gauss_input_gray.mem", Mem_array);
        $display("Goruntu dosyasi yuklendi.");
        #100;
        
        file_gauss = $fopen("C:/Users/pc/Desktop/VGA PROJECTS/goruntu_isleme_algoritma/3_gauss/gauss_output_verilog.mem", "w"); // Dosyayý yazma modunda aç
        
        clk = 0;
        rst = 0;
        en  = 1;
        
        #10 ;
        rst = 1; //calisabilir durumda
            
        for (r = 0; r <= HEIGHT - 3; r = r + 1) begin
            for (c = 0; c <= WIDTH - 3; c = c + 1) begin
                en = 1;
                // 3x3 pencereyi mem'den alip diizye yerlestiriyorum                            2.basamak 1 ile baþlar ( r = 1 )
                data_in[0] = Mem_array[r      * WIDTH + c       ];  // satir * genislik + stun = 1*320 + 0 = 320
                data_in[1] = Mem_array[r      * WIDTH + (c+1)   ];  // satir * genislik + stun = 1*320 + 1 = 321
                data_in[2] = Mem_array[r      * WIDTH + (c+2)   ];  // satir * genislik + stun = 1*320 + 2 = 322
                                                                    
                data_in[3] = Mem_array[(r+1)  * WIDTH + c       ];  // satir * genislik + stun = 1*320 + 0 = 320
                data_in[4] = Mem_array[(r+1)  * WIDTH + (c+1)   ];  // satir * genislik + stun = 1*320 + 1 = 320
                data_in[5] = Mem_array[(r+1)  * WIDTH + (c+2)   ];  // satir * genislik + stun = 1*320 + 2 = 320
                                                                    
                data_in[6] = Mem_array[(r+2)  * WIDTH + c       ];  // satir * genislik + stun = 1*320 + 0 = 320
                data_in[7] = Mem_array[(r+2)  * WIDTH + (c+1)   ];  // satir * genislik + stun = 1*320 + 0 = 320
                data_in[8] = Mem_array[(r+2)  * WIDTH + (c+2)   ];  // satir * genislik + stun = 1*320 + 0 = 320
                                                                    
                en = 1; // pencere verilerini module gondder ve aktf et
                #10   ;
                en = 1; 
                wait(done); //  done bekle 
                $display("Window starting at (%0d,%0d) -> Output: %d", r, c, data_out);  // otomatik bir alt satira gececek
                $display("  %0d  %0d  %0d", r*WIDTH+c,     r*WIDTH+c+1,     r*WIDTH+c+2);
                $display("  %0d  %0d  %0d", (r+1)*WIDTH+c, (r+1)*WIDTH+c+1, (r+1)*WIDTH+c+2);
                $display("  %0d  %0d  %0d", (r+2)*WIDTH+c, (r+2)*WIDTH+c+1, (r+2)*WIDTH+c+2);
                
                $fwrite(file_gauss, "%08b\n", data_out[7:0]);
                #10; // Bir clock bekle, sonra sonraki pencereye geç
            end
        end
        $fclose (file_gauss);
        $finish;
    end
    
endmodule