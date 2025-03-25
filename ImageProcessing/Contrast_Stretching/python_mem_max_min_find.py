def find_min_max(filename):
    values = []
    with open(filename, "r") as file:
        for line in file:
            line = line.strip()  # Satır sonlarındaki boşlukları temizle
            if line:            # Boş satırları atla
                # Binary stringi tamsayıya çevir (base=2)
                try:
                    value = int(line, 2)
                    values.append(value)
                except ValueError:
                    print(f"Geçersiz binary değer bulundu: {line}")
    if not values:
        raise ValueError("Dosyada okunabilir veri bulunamadı.")
    return min(values), max(values)

if __name__ == "__main__":
    filename = "C:/Users/pc/Desktop/VGA PROJECTS/goruntu_isleme_algoritma/9_kontrast_germe/kontrast_image2.mem"  # Dosya adını ve yolunu düzenleyin
    try:
        min_value, max_value = find_min_max(filename)
        print("Minimum değer:", min_value)
        print("Maksimum değer:", max_value)
    except Exception as e:
        print("Hata:", e)
