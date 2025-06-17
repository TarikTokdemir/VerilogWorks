import tkinter as tk
import cv2
from PIL import Image, ImageTk  # Bu satırı en üstte import kısmına da eklemeyi unutma
from tkinter import filedialog
import numpy as np
from matplotlib.backends.backend_tkagg import FigureCanvasTkAgg
import matplotlib.pyplot as plt

# WINDOW PARAMETERS #
window_width    = 1500
window_height   = 750
gui_color       = "#BBDDFF"

# CREATE MAIN WINDOW #
main_window = tk.Tk()
main_window.title("GUI for ASIC SIMULATION")
main_window.geometry(f"{window_width}x{window_height}")
main_window.resizable(False, False)
main_window.configure(bg=gui_color)

# RECTANGLE 1 PARAMETERS #
rect1_x0 = 100
rect1_y0 = 560
rect1_x1 = 1400
rect1_y1 = 740
rect1_color = "#eb9a2a"

# CALCULATED WIDTH/HEIGHT #
rect1_width = rect1_x1 - rect1_x0
rect1_height = rect1_y1 - rect1_y0

# CREATE RECTANGLE USING COORDINATES #
frame1 = tk.Frame(main_window, bg=rect1_color, width=rect1_width, height=rect1_height)
frame1.place(x=rect1_x0, y=rect1_y0)

# BUTTON OZELLIKLERI #
button_font_size = 12
button_font = ("Helvetica", button_font_size, "bold")
button_width = 185
button_height = 75

# COLOR DEFINITIONS #
button_color_default = "#c8c8c8"
button_color_active = "#0055FF"
start_default_color = "#00FF00"
start_active_color = "#00AA00"
stop_default_color = "#FF0000"
stop_active_color = "#AA0000"

# BUTTON STATE DICTIONARY #
button_states = {}

def toggle_group_button(selected_name):
    # Prevent changes if transmission is active
    if button_states.get("button7", False):  # Start is active
        return  # Ignore button press

    group_names = ["button1", "button2", "button3", "button4", "button5", "button6"]
    for name in group_names:
        button = buttons[name]
        if name == selected_name:
            button.configure(bg=button_color_active)
            button_states[name] = True
        else:
            button.configure(bg=button_color_default)
            button_states[name] = False

    if processed_image_gray_320x240 is not None:
        selected_algorithm_code = algorithm_button_codes[selected_name]
        processed = apply_opencv_algorithm(processed_image_gray_320x240, selected_algorithm_code)
        img_proc_rgb = cv2.cvtColor(processed, cv2.COLOR_GRAY2RGB)
        img_proc_pil = Image.fromarray(img_proc_rgb)
        img_proc_tk = ImageTk.PhotoImage(img_proc_pil)
        image_label2.configure(image=img_proc_tk)
        image_label2.image = img_proc_tk

        # Kullanıcıya bilgi ver
        log_to_console(f"{algorithm_label[selected_name]} algoritması seçildi ve OPENCV ile islendi")
        log_to_console("Veri gonderme islemi bekleniyor")
        
        buttons["button7"].configure(state="normal")
        buttons["button8"].configure(state="disabled")
        
# --- TOGGLE FUNCTION FOR TRANSMISSION BUTTONS 7-8 --- #
def toggle_transmission_button(selected_name):
    group_names = ["button7", "button8"]
    for name in group_names:
        button = buttons[name]
        if name == selected_name:
            if not button_states.get(name, False):
                new_color = start_active_color if name == "button7" else stop_active_color
                button.configure(bg=new_color)
                button_states[name] = True
        else:
            default_color = start_default_color if name == "button7" else stop_default_color
            button.configure(bg=default_color)
            button_states[name] = False

# --- CREATE BUTTONS AND STORE IN DICTIONARY --- #
buttons = {}

buttons["button1"] = tk.Button(frame1, text="Contrast Stretching", font=button_font, bg=button_color_default,command=lambda: toggle_group_button("button1"), state="disabled")
buttons["button1"].place(x=50, y=30, width=button_width, height=button_height)

buttons["button2"] = tk.Button(frame1, text="Histogram Equalization", font=button_font, bg=button_color_default, command=lambda: toggle_group_button("button2"), state="disabled")
buttons["button2"].place(x=250, y=30, width=button_width, height=button_height)

buttons["button3"] = tk.Button(frame1, text="Edge Detection", font=button_font, bg=button_color_default,command=lambda: toggle_group_button("button3"), state="disabled")
buttons["button3"].place(x=450, y=30, width=button_width, height=button_height)

buttons["button4"] = tk.Button(frame1, text="Thresholding", font=button_font, bg=button_color_default,command=lambda: toggle_group_button("button4"), state="disabled")
buttons["button4"].place(x=650, y=30, width=button_width, height=button_height)

buttons["button5"] = tk.Button(frame1, text="Otsu Method", font=button_font, bg=button_color_default,command=lambda: toggle_group_button("button5"), state="disabled")
buttons["button5"].place(x=850, y=30, width=button_width, height=button_height)

buttons["button6"] = tk.Button(frame1, text="Kapur Method", font=button_font, bg=button_color_default,command=lambda: toggle_group_button("button6"), state="disabled")
buttons["button6"].place(x=1050, y=30, width=button_width, height=button_height)

buttons["button7"] = tk.Button(frame1, text="Start Transmission", font=button_font, bg=start_default_color,command=lambda: start_transmission(), state="disabled")
buttons["button7"].place(x=100, y=125, width=475, height=50)

buttons["button8"] = tk.Button(frame1, text="Stop Transmission", font=button_font, bg=stop_default_color,command=lambda: toggle_transmission_button("button8"), state="disabled")
buttons["button8"].place(x=700, y=125, width=475, height=50)

# --- LOAD IMAGE USING OPENCV --- #
image_path = r"C:\Users\pc\Desktop\2209_calismalar\2025 GUI\JPEG_background.jpg"
JPEG_background1 = cv2.imread(image_path)
image_rgb = cv2.cvtColor(JPEG_background1, cv2.COLOR_BGR2RGB)
image_resized = cv2.resize(image_rgb, (320, 240))  

# CONVERT TO ImageTk
image_pil1 = Image.fromarray(image_resized)
image_JPEG_background1 = ImageTk.PhotoImage(image_pil1)
image_pil2 = Image.fromarray(image_resized)
image_JPEG_background2 = ImageTk.PhotoImage(image_pil2)
image_pil3 = Image.fromarray(image_resized)
image_JPEG_background3 = ImageTk.PhotoImage(image_pil3)
image_pil4 = Image.fromarray(image_resized)
image_JPEG_background4 = ImageTk.PhotoImage(image_pil4)

image_pil6 = Image.fromarray(image_resized)
image_JPEG_background6 = ImageTk.PhotoImage(image_pil6)
image_pil6 = Image.fromarray(image_resized)
image_JPEG_background6 = ImageTk.PhotoImage(image_pil6)

# KEEP REFERENCES
main_window.image_tk1 = image_JPEG_background1
main_window.image_tk2 = image_JPEG_background2
main_window.image_tk3 = image_JPEG_background3
main_window.image_tk4 = image_JPEG_background4

# DISPLAY IMAGES
image_label1 = tk.Label(main_window, image=main_window.image_tk1)           # islenmemis renkli gorsel
image_label1.place(x=100, y=(window_height-740), width=320, height=240)     
image_label2 = tk.Label(main_window, image=main_window.image_tk2)           # gray donusturulmus gorsel
image_label2.place(x=1100, y=(window_height-740), width=320, height=240)
image_label3 = tk.Label(main_window, image=main_window.image_tk3)           # opencv ciktisi
image_label3.place(x=100, y=(window_height-460), width=320, height=240)  
image_label4 = tk.Label(main_window, image=main_window.image_tk4)           # islenmis fpga ciktisi
image_label4.place(x=1100, y=(window_height-460), width=320, height=240)

# --- LABELS UNDER IMAGES --- #
label_left_text = tk.Label(main_window, text="320x240 Original Image", font=("Helvetica", 10, "bold"), bg=gui_color)
label_left_text.place(x=100+90, y=250)           # islenmemis renkli gorsel

label_right_text = tk.Label(main_window, text="320x240 Gray Image", font=("Helvetica", 10, "bold"), bg=gui_color)
label_right_text.place(x=100+90, y=530)          # gray donusturulmus gorsel

label_left_text = tk.Label(main_window, text="320x240 Opencv Processed Image", font=("Helvetica", 10, "bold"), bg=gui_color)
label_left_text.place(x=1160 , y=250)            # opencv ciktisi

label_right_text = tk.Label(main_window, text="320x240 FPGA Processed Image", font=("Helvetica", 10, "bold"), bg=gui_color)
label_right_text.place(x=1160 , y=530)   # islenmis fpga ciktisi
# --- GLOBAL STORAGE FOR PROCESSED IMAGE --- #
processed_image_gray_320x240 = None
processed_image_display = None
preview_label = None

# --- FUNCTION TO SELECT AND PROCESS IMAGE --- #
def select_and_process_image():
    global processed_image_gray_320x240, processed_image_display, preview_label

    file_path = filedialog.askopenfilename(filetypes=[("Image Files", "*.jpg;*.png;*.bmp")])
    if not file_path:
        log_to_console("Görüntü seçimi iptal edildi.")
        return

    log_to_console("Görüntü yükleniyor...")
    img_bgr = cv2.imread(file_path)
    if img_bgr is None:
        log_to_console("Hata: Görüntü yüklenemedi.")
        return

    # Resize to 320x240
    img_resized = cv2.resize(img_bgr, (320, 240))
    img_gray = cv2.cvtColor(img_resized, cv2.COLOR_BGR2GRAY)
    processed_image_gray_320x240 = img_gray.copy()

    # Orijinal renkli göster (Label1)
    img_color_rgb = cv2.cvtColor(img_resized, cv2.COLOR_BGR2RGB)
    img_color_pil = Image.fromarray(img_color_rgb)
    img_color_tk = ImageTk.PhotoImage(img_color_pil)
    image_label1.configure(image=img_color_tk)
    image_label1.image = img_color_tk

    # Gri göster (Label3)
    img_gray_rgb = cv2.cvtColor(img_gray, cv2.COLOR_GRAY2RGB)
    img_gray_pil = Image.fromarray(img_gray_rgb)
    img_gray_tk = ImageTk.PhotoImage(img_gray_pil)
    image_label3.configure(image=img_gray_tk)
    image_label3.image = img_gray_tk

    log_to_console("Görüntü başarıyla yüklendi. Algoritma seçimi bekleniyor...")

    # Algoritma seçili mi kontrol et
    selected_algorithm_code = None
    selected_button_name = None
    for name, is_active in button_states.items():
        if name in algorithm_button_codes and is_active:
            selected_algorithm_code = algorithm_button_codes[name]
            selected_button_name = name  
            break

    if selected_algorithm_code is not None:
        log_to_console(f"{algorithm_label[selected_button_name]} algoritması seçildi. İşleniyor...")

        processed = apply_opencv_algorithm(img_gray, selected_algorithm_code)
        img_proc_rgb = cv2.cvtColor(processed, cv2.COLOR_GRAY2RGB)
        img_proc_pil = Image.fromarray(img_proc_rgb)
        img_proc_tk = ImageTk.PhotoImage(img_proc_pil)
        image_label2.configure(image=img_proc_tk)
        image_label2.image = img_proc_tk

        log_to_console("Gri görüntü ve OpenCV çıktısı oluşturuldu.")
    else:
        log_to_console("Not: Henüz bir algoritma seçilmedi.")

    # --- Algoritma butonlarını etkinleştir --- #
    for name in ["button1", "button2", "button3", "button4", "button5", "button6"]:
        buttons[name].configure(state="normal")

    show_histogram(img_gray, hist_frame_gray, color='blue', title='Gray Image Histogram')
    
def apply_opencv_algorithm(gray_img, algorithm_code):
    if algorithm_code == 0b00000001:  # Contrast Stretching
        min_val, max_val = np.min(gray_img), np.max(gray_img)
        if max_val > min_val:
            stretched = ((gray_img - min_val) * 255.0 / (max_val - min_val)).astype(np.uint8)
        else:
           stretched = np.zeros_like(gray_img)  # veya gray_img.copy()  → minimum fark olur ama siyah olmaz
        return stretched

    elif algorithm_code == 0b00000010:  # Histogram Equalization
        return cv2.equalizeHist(gray_img)

    elif algorithm_code == 0b00000100:  # Edge Detection (Gaussian + Sobel)
        blurred = cv2.GaussianBlur(gray_img, (3, 3), 0)
        sobel_x = cv2.Sobel(blurred, cv2.CV_64F, 1, 0, ksize=3)
        sobel_y = cv2.Sobel(blurred, cv2.CV_64F, 0, 1, ksize=3)
        sobel_combined = np.sqrt(sobel_x**2 + sobel_y**2)
        sobel_normalized = np.clip((sobel_combined / np.max(sobel_combined) * 255), 0, 255).astype(np.uint8)
        return sobel_normalized

    elif algorithm_code == 0b00001000:  # Sabit Thresholding
        _, thresh = cv2.threshold(gray_img, 127, 255, cv2.THRESH_BINARY)
        return thresh

    elif algorithm_code == 0b00010000:  # Otsu Thresholding
        _, otsu = cv2.threshold(gray_img, 0, 255, cv2.THRESH_BINARY + cv2.THRESH_OTSU)
        return otsu

    elif algorithm_code == 0b00100000:  # Kapur Thresholding (gerçek)
        hist = cv2.calcHist([gray_img], [0], None, [256], [0, 256]).ravel()
        hist = hist / hist.sum()  # normalize histogram
        cum_hist = np.cumsum(hist)

        entropy_bg = np.zeros(256)
        entropy_fg = np.zeros(256)

        for t in range(256):
            # Arka plan (0..t)
            if cum_hist[t] > 0:
                prob_bg = hist[:t+1] / cum_hist[t]
                entropy_bg[t] = -np.sum(prob_bg * np.log(prob_bg + 1e-10))

            # Ön plan (t+1..255)
            if cum_hist[t] < 1:
                prob_fg = hist[t+1:] / (1.0 - cum_hist[t])
                entropy_fg[t] = -np.sum(prob_fg * np.log(prob_fg + 1e-10))

        kapur_scores = entropy_bg + entropy_fg
        best_thresh = np.argmax(kapur_scores)
        _, kapur_thresh = cv2.threshold(gray_img, best_thresh, 255, cv2.THRESH_BINARY)
        return kapur_thresh

    else:
        return gray_img  # fallback

# --- BUTTON TO SELECT IMAGE --- #
select_button = tk.Button(main_window, text="Select Image", font=("Helvetica", 12, "bold"),
                          command=select_and_process_image, bg="#dddddd")
select_button.place(x=(window_width - 150) // 2, y=20, width=150, height=40)

algorithm_button_codes = {
    "button1": 0b00000001,  # Contrast Stretching
    "button2": 0b00000010,  # Histogram Equalization
    "button3": 0b00000100,  # Edge Detection
    "button4": 0b00001000,  # Thresholding
    "button5": 0b00010000,  # Otsu Method
    "button6": 0b00100000   # Kapur Method
}

# --- UART Ayarları --- #
import serial

uart_port = 'COM8'            # Kendi portunu buraya yaz (örnek: 'COM4', '/dev/ttyUSB0')
uart_baudrate = 115200        # Baud rate (FPGA ile aynı olmalı)
uart_timeout = 1              # Timeout saniye cinsinden

# --- Görüntüyü UART ile Gönder --- #
def send_image_over_uart():
    global processed_image_gray_320x240

    if processed_image_gray_320x240 is None:
        log_to_console("Uyarı: Henüz bir görüntü seçilmedi.")
        return False

    selected_algorithm_code = None
    for name, is_active in button_states.items():
        if name in algorithm_button_codes and is_active:
            selected_algorithm_code = algorithm_button_codes[name]
            break

    if selected_algorithm_code is None:
        log_to_console("Uyarı: Algoritma seçilmedi.")
        return False

    try:
        ser = serial.Serial(port=uart_port, baudrate=uart_baudrate, timeout=uart_timeout)
        log_to_console("UART bağlantısı açıldı.")
        ser.write(bytes([selected_algorithm_code]))
        log_to_console(f"Algoritma kodu gönderildi: {selected_algorithm_code:08b}")

        flat_pixels = processed_image_gray_320x240.flatten()
        for pixel in flat_pixels:
            ser.write(bytes([pixel]))

        log_to_console("Görüntü UART üzerinden gönderildi.")
        ser.close()
        log_to_console("UART bağlantısı kapatıldı.")
        return True

    except serial.SerialException as e:
        log_to_console(f"UART Hatası: {e}")
        return False
        
        
import threading

rx_ready_flag = False  # Alıcı kontrol bayrağı

def start_transmission():
    global rx_ready_flag

    if processed_image_gray_320x240 is None:
        log_to_console("Uyarı: Henüz bir görüntü seçilmedi.")
        return

    selected_algorithm_code = None
    for name, is_active in button_states.items():
        if name in algorithm_button_codes and is_active:
            selected_algorithm_code = algorithm_button_codes[name]
            break

    if selected_algorithm_code is None:
        log_to_console("Uyarı: Algoritma seçilmedi.")
        return

    toggle_transmission_button("button7")  # Butonu aktif yap
    log_to_console("Veri gönderiliyor...")
    buttons["button7"].configure(bg=start_default_color, state="normal")
    button_states["button7"] = False

    success = send_image_over_uart()

    if success:
        rx_ready_flag = True
        log_to_console("RX başlatıldı, veri bekleniyor...")
        buttons["button8"].configure(state="normal")  # Stop butonunu aktif et
        rx_thread = threading.Thread(target=receive_image_from_uart)
        rx_thread.daemon = True
        rx_thread.start()
    else:
        log_to_console("RX başlatılmadı, çünkü UART iletim başarısız oldu.")

        # Butonu pasif duruma geri al
        buttons["button7"].configure(bg=start_default_color)
        button_states["button7"] = False

received_image_array_fpga = None  # RX ile alınan son görüntü burada saklanacak
def receive_image_from_uart():
    global rx_ready_flag, received_image_array_fpga

    try:
        ser = serial.Serial(port=uart_port, baudrate=uart_baudrate, timeout=uart_timeout)
        log_to_console("RX UART bağlantısı açıldı.")

        while rx_ready_flag:
            if ser.in_waiting >= 1:
                marker = ser.read(1)
                if marker == bytes([0xAA]):
                    log_to_console("FPGA'dan işlenmiş veri geliyor...")

                    received_bytes = bytearray()
                    expected_bytes = 320 * 240

                    while len(received_bytes) < expected_bytes and rx_ready_flag:
                        chunk = ser.read(expected_bytes - len(received_bytes))
                        received_bytes.extend(chunk)

                    if not rx_ready_flag:
                        log_to_console("Veri alımı kullanıcı tarafından iptal edildi.")
                        break

                    # Görüntüyü 320x240 dizisine çevir
                    img_array_fpga = np.frombuffer(received_bytes, dtype=np.uint8).reshape((240, 320))

                    # GLOBAL olarak sakla
                    received_image_array_fpga = img_array_fpga.copy()

                    # Görüntüyü tkinter label üzerinde göster
                    img_rgb = cv2.cvtColor(img_array_fpga, cv2.COLOR_GRAY2RGB)
                    img_pil = Image.fromarray(img_rgb)
                    img_tk = ImageTk.PhotoImage(img_pil)

                    image_label4.configure(image=img_tk)
                    image_label4.image = img_tk

                    # Histogram çizimi
                    show_histogram(img_array_fpga, hist_frame_fpga, color='green', title='FPGA Output Histogram')

                    rx_ready_flag = False
                    break
            else:
                if not rx_ready_flag:
                    log_to_console("Kullanıcı tarafından RX iptal edildi.")
                    break

        if ser.is_open:
            ser.close()
            log_to_console("RX UART bağlantısı kapatıldı.")

    except serial.SerialException as e:
        log_to_console(f"UART Hatası (RX): {e}")
        rx_ready_flag = False
        
def save_rx_image():
    if received_image_array_fpga is not None:
        cv2.imwrite("received_fpga_image.png", received_image_array_fpga)
        log_to_console("RX görüntüsü 'received_fpga_image.png' olarak kaydedildi.")
    else:
        log_to_console("Henüz RX verisi alınmadı, kayıt yapılmadı.")
        
def stop_transmission():
    global rx_ready_flag

    rx_ready_flag = False
    log_to_console("Veri alımı kullanıcı tarafından durduruldu.")

    # Buton durumlarını sıfırla
    buttons["button8"].configure(bg=stop_default_color, state="disabled")
    button_states["button8"] = False

    # UART bağlantısını güvenli şekilde kapat
    try:
        temp_ser = serial.Serial(port=uart_port, baudrate=uart_baudrate, timeout=uart_timeout)
        if temp_ser.is_open:
            temp_ser.close()
            log_to_console("UART hattı manuel olarak sıfırlandı.")
    except serial.SerialException as e:
        log_to_console(f"UART sıfırlama hatası: {e}")


# --- Stop butonuna özel handler ekle --- #
buttons["button8"].configure(command=stop_transmission)
        
# --- CONSOLE OUTPUT AREA (TEXT WIDGET) --- #
# --- CONSOLE OUTPUT AREA (TEXT WIDGET) --- #
console_text = tk.Text(
    main_window,
    height=8,                   # Satır sayısı (dilersen değiştir)
    width=75,                  # Karakter cinsinden genişlik
    font=("Consolas", 10),      # Yazı tipi
    bg="black",                 # Arka plan rengi siyah
    fg="white",                 # Yazı rengi beyaz
    insertbackground="white",  # İmleç rengi beyaz
    bd=2,                       # Kenarlık kalınlığı
    relief="sunken"             # Kenar görünümü
)
console_text.place(x=500, y=70)  # Select Image butonunun hemen altı

# --- Console'a Yazı Yazma Fonksiyonu --- #
def log_to_console(message):
    console_text.insert(tk.END, f"> {message}\n")
    console_text.see(tk.END)  # En alta kaydır
log_to_console("Lütfen bir resim seçin.")

algorithm_label = {
    "button1": "Contrast Stretching",
    "button2": "Histogram Equalization",
    "button3": "Sobel Edge Detection",
    "button4": "Thresholding",
    "button5": "Otsu Thresholding",
    "button6": "Kapur Thresholding"
}

# Histogram canvas frame'leri
hist_frame_gray = tk.Frame(main_window, bg="white", width=250, height=200)
hist_frame_gray.place(x=500, y=250)  # Gray görüntü histogramı

hist_frame_fpga = tk.Frame(main_window, bg="white", width=250, height=200)
hist_frame_fpga.place(x=780, y=250)  # FPGA'dan alınan görüntü histogramı

def show_histogram(image_array, frame, color='blue', title='Histogram'):
    for widget in frame.winfo_children():
        widget.destroy()

    fig, ax = plt.subplots(figsize=(2.5, 2.0), dpi=100)
    ax.hist(image_array.ravel(), bins=256, range=(0, 256), color=color)
    ax.set_title(title, fontsize=9)
    ax.set_xlim(0, 256)
    ax.tick_params(axis='both', labelsize=6)

    plt.tight_layout()  # Taşmaları ve üst üste binmeleri önler

    canvas = FigureCanvasTkAgg(fig, master=frame)
    canvas.draw()
    canvas.get_tk_widget().pack(fill=tk.BOTH, expand=True)

# MAIN LOOP #
main_window.mainloop()
