import cv2
import os
import pandas as pd
import numpy as np
import requests
from sklearn.neighbors import KNeighborsRegressor
import tkinter as tk
from tkinter import messagebox
from matplotlib.backends.backend_tkagg import FigureCanvasTkAgg
import matplotlib.pyplot as plt
import firebase_admin
from firebase_admin import credentials, firestore, db

# Load the image
current_dir = os.path.dirname(os.path.realpath(__file__))
cred_path = os.path.join(current_dir, "sendDataDB", "credentials", "google_credential.json")
cred = credentials.Certificate(cred_path)
firebase_admin.initialize_app(cred, {'databaseURL' : 'https://bawangmerahapp1-default-rtdb.asia-southeast1.firebasedatabase.app/'})

ref = db.reference("control_data/urlgambar")
data = ref.get()

response = requests.get(data)
img_data = response.content

temp_img_path = "temp_image.jpg"
with open(temp_img_path, "wb") as temp_img:
    temp_img.write(img_data)

citraminum = cv2.imread(temp_img_path)

os.remove(temp_img_path)

gray = cv2.cvtColor(citraminum, cv2.COLOR_BGR2GRAY)
ratagray = np.mean(gray)

train_data_path = os.path.join(current_dir, "OnionLeafDetection", "datatrain.xlsx")
dataminum = pd.read_csv(train_data_path)
print(dataminum.columns)
X = dataminum[['Edge Detection']]
Y = dataminum['Keterangan']

# Metode KNN
knn = KNeighborsRegressor(n_neighbors=3)
knn.fit(X, Y)
data = [ratagray]

# Hasil Prediksi Dari Gambar Yang di Uji
hasilprediksi = knn.predict([data])
hasilprediksi = float(hasilprediksi)

# Klasifikasi dari hasil prediksi
if hasilprediksi >= 2:
    judul = "layu"
else:
    judul = "segar"

# Create Tkinter window
root = tk.Tk()
root.title("Hasil Klasifikasi")

# Display result in messagebox
messagebox.showinfo("Hasil Klasifikasi", judul)

# Display image and result using matplotlib in Tkinter
fig, axs = plt.subplots(nrows=1, ncols=2, figsize=(10, 5))

# Display original image
axs[0].set_title("Citra Asli")
axs[0].imshow(cv2.cvtColor(citraminum, cv2.COLOR_BGR2RGB))
axs[0].axis('off')

# Display grayscale image
axs[1].set_title("Citra Gray")
axs[1].imshow(gray, cmap='gray')
axs[1].axis('off')

# Draw the figure on the canvas
canvas = FigureCanvasTkAgg(fig, master=root)
canvas.draw()
canvas.get_tk_widget().pack()

# Start Tkinter main loop
root.mainloop()