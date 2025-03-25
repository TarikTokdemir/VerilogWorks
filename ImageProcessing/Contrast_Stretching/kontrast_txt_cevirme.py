from PIL import Image
import numpy as np
import cv2

# Görüntüyü yükle
image = Image.open("C:/Users/pc/Desktop/VGA PROJECTS/goruntu_isleme_algoritma/9_kontrast_germe/image2.jpg")

# Görüntüyü 320x240 boyutuna yeniden boyutlandır ve grayscale yap
resized_image = image.resize((320, 240), Image.LANCZOS).convert('L')

# NumPy dizisine dönüştür
data = np.array(resized_image)

# Görüntüyü mem dosyasına alt alta decimal olarak kaydet
with open("kontrast_image2.mem", "w") as f:
    for pixel in data.flatten():
        f.write(f"{pixel:08b}\n")

# Görüntüyü göster ("q" ile kapatılır)
cv2.imshow("320x240 Goruntu", data)

while True:
    if cv2.waitKey(1) & 0xFF == ord('q'):
        break

cv2.destroyAllWindows()
