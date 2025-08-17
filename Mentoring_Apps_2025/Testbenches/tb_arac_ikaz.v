`timescale 1ns / 1ps


module tb_arac_ikaz ();



reg         motor_durumu_tb            ;          // inputlar reg olarak tb'de tanimlanir
reg         arac_hareket_durumu_tb     ;          // inputlar reg olarak tb'de tanimlanir
reg         emniyet_kemeri_durumu_tb   ;          // inputlar reg olarak tb'de tanimlanir
reg [3:0]   kapi_tb                    ;    // inputlar reg olarak tb'de tanimlanir


wire emniyet_kemeri_lambasi_tb  ;     // outputlar wire olarak tanimlanir 
wire kapi_lambasi_tb            ;     // outputlar wire olarak tanimlanir 
wire emniyet_kemeri_ikaz_tb     ;     // outputlar wire olarak tanimlanir 
wire kapi_ikaz_tb               ;     // outputlar wire olarak tanimlanir 



arac_ikaz arac_ikaz_dut(  // Dut = design under test 
    .motor_durumu           (motor_durumu_tb            ),
    .arac_hareket_durumu    (arac_hareket_durumu_tb     ),
    .emniyet_kemeri_durumu  (emniyet_kemeri_durumu_tb   ),
    .kapi                   (kapi_tb                    ),
    .emniyet_kemeri_lambasi (emniyet_kemeri_lambasi_tb  ),
    .kapi_lambasi           (kapi_lambasi_tb            ),
    .emniyet_kemeri_ikaz    (emniyet_kemeri_ikaz_tb     ),
    .kapi_ikaz              (kapi_ikaz_tb               )
);


initial begin
    #1000;  // 100ns hicbisey ypamadan bekler 
    
    // Baslangic Degerleri Verilir
    motor_durumu_tb          = 0 ;        //    1 bit sinyalin  alabileceði degerler => 0 , 1 , X , Z  
    arac_hareket_durumu_tb   = 0 ;
    emniyet_kemeri_durumu_tb = 0 ;
    kapi_tb                  = 0 ;
    
    #100 ; 
    
    // TEST 1
    motor_durumu_tb = 1 ;  
    arac_hareket_durumu_tb = 0 ;
    emniyet_kemeri_durumu_tb = 0 ;

    #100 ;
    
    
    // TEST 2
    motor_durumu_tb = 1 ;  
    arac_hareket_durumu_tb = 1 ;
    emniyet_kemeri_durumu_tb = 0 ;
    
    #100 ;
    
    // TEST 3
    motor_durumu_tb = 1 ;  
    arac_hareket_durumu_tb = 1 ;
    emniyet_kemeri_durumu_tb = 1 ;

    #100 ; 
    
    // TEST KAPI DURUMU 
    motor_durumu_tb = 1 ;
    arac_hareket_durumu_tb = 1 ; 
    kapi_tb = 4'b1100;  // 'd12
    
    $finish ; 
end





    
    
    
    
    
    
    
    
endmodule
