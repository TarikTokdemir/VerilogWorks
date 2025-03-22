import numpy as np

# Sabitler
pixel_count = 76800
min_val = 28
max_val = 223

# Rastgele 8-bitlik veriler üret (28–223 arası)
random_data = np.random.randint(min_val, max_val + 1, pixel_count)

# Dosya yolu
file_path = "C:/Users/pc/Desktop/VGA PROJECTS/goruntu_isleme_algoritma/9_kontrast_germe/min_max_datas.mem"

# Dosyaya 8-bit binary formatta yaz
with open(file_path, "w") as f:
    for val in random_data:
        f.write(f"{val:08b}\n")

print("min_max_datas.mem başarıyla oluşturuldu.")
