import numpy as np
import cv2

#  Dosya yolları (Kendi yollarını gir)
verilog_mem_path = "C:/Users/pc/Desktop/VGA PROJECTS/goruntu_isleme_algoritma/4_mean/mean_output_verilog.mem"
python_mem_path = "C:/Users/pc/Desktop/VGA PROJECTS/goruntu_isleme_algoritma/4_mean/mean_python_output.mem"
farklar_txt_path = "C:/Users/pc/Desktop/VGA PROJECTS/goruntu_isleme_algoritma/4_mean/farklar.txt"

#  Çıktı boyutları
output_width = 318
output_height = 238

total_pixels = output_width * output_height  # 318 * 238 = 75684

#  Python Mean Çıktısını Oku ve Görüntüye Çevir
with open(python_mem_path, "r") as f:
    python_data = [line.strip() for line in f if line.strip()]
python_mean = np.array([int(line, 2) for line in python_data], dtype=np.uint8).reshape((output_height, output_width))

#  Verilog Mean Çıktısını Oku ve Görüntüye Çevir
with open(verilog_mem_path, "r") as f:
    verilog_data = [line.strip() for line in f if line.strip()]
verilog_mean = np.array([int(line, 2) for line in verilog_data], dtype=np.uint8).reshape((output_height, output_width))

#  **Farkları Doğru Hesapla (uint8 taşmasını önle)**
farklar = np.abs(verilog_mean.astype(np.int16) - python_mean.astype(np.int16))

#  Görselleri Ekranda Göster
cv2.imshow("Python Mean Ciktisi (318x238)", python_mean)
cv2.imshow("Verilog Mean Ciktisi (318x238)", verilog_mean)

#  Farklı Olan Pikselleri Dosyaya Yaz
with open(farklar_txt_path, "w") as f:
    f.write("İndeks | Python Değeri | Verilog Değeri | Fark\n")
    f.write("-" * 50 + "\n")
    
    indeks = 0  # Piksel sırası için indeks
    farkli_piksel_sayisi = 0
    
    for i in range(output_height):
        for j in range(output_width):
            if farklar[i, j] != 0:  # Sadece farklı olanları kaydet
                f.write(f"{indeks:5d} | {python_mean[i, j]:3d} | {verilog_mean[i, j]:3d} | {farklar[i, j]:3d}\n")
                farkli_piksel_sayisi += 1
            indeks += 1  # Her piksel için artır

#  Toplam Farklı Piksel Sayısını Yazdır
print(f"Farklı piksel sayısı: {farkli_piksel_sayisi}")
print(f"Farklar dosyasına kaydedildi: {farklar_txt_path}")

image_color = cv2.imread("C:/Users/pc/Desktop/VGA PROJECTS/goruntu_isleme_algoritma/4_mean/agac.jpg", cv2.IMREAD_COLOR)
cv2.imshow("MEAN Orijinal Renkli Goruntu", image_color)

#  Gri tonlamaya çevir
image_gray = cv2.cvtColor(image_color, cv2.COLOR_BGR2GRAY)
cv2.imshow("MEAN Gri Tonlu Goruntu", image_gray)


#  Pencereleri kapatmak için 'q' tuşuna basılmasını bekle
while True:
    if cv2.waitKey(1) & 0xFF == ord('q'):
        break

cv2.destroyAllWindows()
