from PIL import Image
import numpy as np
import cv2
import matplotlib.pyplot as plt

# 1. Gerçek görüntüyü yükle, griye çevir ve 320x240 boyutuna getir.
image_path = "C:/Users/pc/Desktop/VGA PROJECTS/goruntu_isleme_algoritma/9_kontrast_germe/image2.jpg"
real_image = Image.open(image_path)
gray_image = real_image.convert("L")
resized_gray = gray_image.resize((320, 240), Image.LANCZOS)
resized_gray_np = np.array(resized_gray)

# Gerçek gri görüntüyü pencere içinde göster
cv2.imshow("Original Grayscale", resized_gray_np)

# 2. OpenCV ile kontrast germe (normalize) işlemi
opencv_processed = cv2.normalize(resized_gray_np, None, alpha=0, beta=255, norm_type=cv2.NORM_MINMAX)
cv2.imshow("OpenCV Processed", opencv_processed)

# 3. Verilog'dan gelen mem dosyasını oku (her satır 8 bitlik binary string içermektedir)
mem_filename = "kontrast_image2_out.mem"  # Dosya yolunu güncelleyin
with open(mem_filename, "r") as f:
    mem_lines = [line.strip() for line in f if line.strip() != ""]

# Her bir binary stringi int'e çevir (base=2)
verilog_pixels = [int(line, 2) for line in mem_lines]

# Beklenen piksel sayısı: 320 x 240 = 76800
expected_pixels = 320 * 240
if len(verilog_pixels) < expected_pixels:
    verilog_pixels.extend([0] * (expected_pixels - len(verilog_pixels)))
elif len(verilog_pixels) > expected_pixels:
    verilog_pixels = verilog_pixels[:expected_pixels]

# 76800 pikseli 240 satır, 320 sütunluk matris haline getir
verilog_image = np.array(verilog_pixels, dtype=np.uint8).reshape((240, 320))
cv2.imshow("Verilog Processed", verilog_image)

# 4. OpenCV ve Verilog işlenmiş görüntülerin histogramlarını çizelim
plt.figure(figsize=(12, 5))

plt.subplot(1, 2, 1)
plt.hist(opencv_processed.flatten(), bins=256, range=(0, 255), color='gray')
plt.title("Histogram - OpenCV Processed")
plt.xlabel("Piksel Değeri")
plt.ylabel("Frekans")

plt.subplot(1, 2, 2)
plt.hist(verilog_image.flatten(), bins=256, range=(0, 255), color='gray')
plt.title("Histogram - Verilog Processed")
plt.xlabel("Piksel Değeri")
plt.ylabel("Frekans")

plt.tight_layout()
plt.show()

# 5. Tüm 3 görüntüyü karşılaştırmalı olarak matplotlib ile gösterelim
plt.figure(figsize=(15, 5))

plt.subplot(1, 3, 1)
plt.imshow(resized_gray_np, cmap='gray')
plt.title("Original Grayscale")
plt.axis('off')

plt.subplot(1, 3, 2)
plt.imshow(opencv_processed, cmap='gray')
plt.title("OpenCV Processed")
plt.axis('off')

plt.subplot(1, 3, 3)
plt.imshow(verilog_image, cmap='gray')
plt.title("Verilog Processed")
plt.axis('off')

plt.tight_layout()
plt.show()

# 6. Her piksel için: satır numarası, OpenCV işlenmiş görüntü decimal değeri,
#    Verilog decimal değeri ve aradaki farkı (OpenCV - Verilog) hesaplayıp txt dosyasına yazalım.
output_txt = "pixel_comparison.txt"
with open(output_txt, "w") as f_out:
    total_pixels = opencv_processed.size  # 76800
    # Her iki görüntüyü flatten edelim
    opencv_flat = opencv_processed.flatten()
    verilog_flat = verilog_image.flatten()
    for i in range(total_pixels):
        opencv_val = int(opencv_flat[i])
        verilog_val = int(verilog_flat[i])
        diff = opencv_val - verilog_val
        f_out.write(f"{i}\t{opencv_val}\t{verilog_val}\t{diff}\n")

print(f"Pixel karşılaştırması '{output_txt}' dosyasına yazıldı.")

# cv2 pencerelerinin gösterilebilmesi için bir tuşa basılması beklenir.
cv2.waitKey(0)
cv2.destroyAllWindows()
