import cv2
import numpy as np

#  Görüntüyü yükle (Renkli)
image_color = cv2.imread("C:/Users/pc/Desktop/VGA PROJECTS/goruntu_isleme_algoritma/4_mean/agac.jpg", cv2.IMREAD_COLOR)
cv2.imshow("MEAN Orijinal Renkli Goruntu", image_color)

#  Gri tonlamaya çevir
image_gray = cv2.cvtColor(image_color, cv2.COLOR_BGR2GRAY)
cv2.imshow("MEAN Gri Tonlu Goruntu", image_gray)

#  320x240 boyutuna küçült
image_resized = cv2.resize(image_gray, (320, 240)) 
cv2.imshow("MEAN Gri 320x240", image_resized)

#  Gri tonlamalı görüntüyü kaydet (320x240)
with open("mean_input_gray.mem", "w") as f:
    for row in image_resized:
        for pixel in row:
            f.write(f"{pixel:08b}\n")  # 8-bit binary formatında yaz

print(" Gri tonlamalı görüntü kaydedildi: mean_input_gray.mem")

# Mean filtresi uygula (3x3 kernel)
mean_blur = cv2.blur(image_resized, (3, 3))

# Çıktı matrisini oluştur (318x238)
output_height = 238
output_width = 318
mean_output = np.zeros((output_height, output_width), dtype=np.uint8)

# 3x3 pencereyi kaydırarak 318x238 çıktıyı oluştur
for i in range(output_height):
    for j in range(output_width):
        mean_output[i, j] = mean_blur[i+1, j+1]  # 3x3 kaydırmalı işlem sonrası merkezi değer alınır

cv2.imshow("MEAN PYTHON Cikti 318x238", mean_output)

#  Mean filtresi sonrası kaydırmalı görüntüyü kaydet (318x238)
with open("mean_python_output.mem", "w") as f:
    for row in mean_output:
        for pixel in row:
            f.write(f"{pixel:08b}\n")  # 8-bit binary formatında yaz

print("Mean filtresi sonrası kaydırmalı görüntü kaydedildi: mean_python_output.mem")

# 📌 Pencereleri kapatmak için 'q' tuşuna basılmasını bekle
while True:
    if cv2.waitKey(1) & 0xFF == ord('q'):
        break

cv2.destroyAllWindows()