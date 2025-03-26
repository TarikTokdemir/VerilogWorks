import numpy as np
import cv2

# 📌 Dosya yolları (Kendi yollarını gir)
verilog_mem_path = "C:/Users/pc/Desktop/VGA PROJECTS/goruntu_isleme_algoritma/5_median/median_output_verilog.mem"
python_mem_path = "C:/Users/pc/Desktop/VGA PROJECTS/goruntu_isleme_algoritma/5_median/median_python_output.mem"
farklar_txt_path = "C:/Users/pc/Desktop/VGA PROJECTS/goruntu_isleme_algoritma/5_median/median_farklar.txt"

# 📌 Çıktı boyutları
output_width = 318
output_height = 238

total_pixels = output_width * output_height  # 318 * 238 = 75684

# 📌 Python Median Çıktısını Oku ve Görüntüye Çevir
with open(python_mem_path, "r") as f:
    python_data = [line.strip() for line in f if line.strip()]
python_median = np.array([int(line, 2) for line in python_data], dtype=np.uint8).reshape((output_height, output_width))

# 📌 Verilog Median Çıktısını Oku ve Görüntüye Çevir
with open(verilog_mem_path, "r") as f:
    verilog_data = [line.strip() for line in f if line.strip()]
verilog_median = np.array([int(line, 2) for line in verilog_data], dtype=np.uint8).reshape((output_height, output_width))

# 📌 **Farkları Doğru Hesapla (uint8 taşmasını önle)**
farklar = np.abs(verilog_median.astype(np.int16) - python_median.astype(np.int16))

# 📌 Görselleri Ekranda Göster
cv2.imshow("Python Median Ciktisi (318x238)", python_median)
cv2.imshow("Verilog Median Ciktisi (318x238)", verilog_median)

# 📌 Farklı Olan Pikselleri Dosyaya Yaz
with open(farklar_txt_path, "w") as f:
    f.write("İndeks | Python Değeri | Verilog Değeri | Fark\n")
    f.write("-" * 50 + "\n")
    
    indeks = 0  # Piksel sırası için indeks
    farkli_piksel_sayisi = 0
    
    for i in range(output_height):
        for j in range(output_width):
            if farklar[i, j] != 0:  # Sadece farklı olanları kaydet
                f.write(f"{indeks:5d} | {python_median[i, j]:3d} | {verilog_median[i, j]:3d} | {farklar[i, j]:3d}\n")
                farkli_piksel_sayisi += 1
            indeks += 1  # Her piksel için artır

# 📌 Toplam Farklı Piksel Sayısını Yazdır
print(f"Median Filtresi - Farklı piksel sayısı: {farkli_piksel_sayisi}")
print(f"Farklar dosyasına kaydedildi: {farklar_txt_path}")

# 📌 Pencereleri kapatmak için 'q' tuşuna basılmasını bekle
while True:
    if cv2.waitKey(1) & 0xFF == ord('q'):
        break

cv2.destroyAllWindows()
