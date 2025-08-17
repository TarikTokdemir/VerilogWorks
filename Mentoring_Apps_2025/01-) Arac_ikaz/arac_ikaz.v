`timescale 1ns / 1ps

module arac_ikaz(
    input       motor_durumu            , // 1 => motor calisyor    , 0 motor calismiyor
    input       arac_hareket_durumu     ,
    input       emniyet_kemeri_durumu   , // 1 ise kemer takili  , 0 ise kemer takili deðil 
    input [3:0] kapi                    , 
    
    output wire emniyet_kemeri_lambasi  ,
    output wire kapi_lambasi            ,
    output wire emniyet_kemeri_ikaz     , 
    output wire kapi_ikaz
    );
    
    assign emniyet_kemeri_lambasi = motor_durumu & ~emniyet_kemeri_durumu ;
    assign emniyet_kemeri_ikaz    = (motor_durumu) & (arac_hareket_durumu) & (~emniyet_kemeri_durumu) ;
    
    assign kapi_lambasi  = motor_durumu & (kapi[3] | kapi[2] | kapi[1] | kapi[0]) ;
    assign kapi_ikaz     = motor_durumu & arac_hareket_durumu & (|kapi)  ;
    
    
endmodule
