import os
import cv2
import pandas as pd
import requests
import numpy as np
from sklearn.model_selection import train_test_split
from sklearn.neighbors import KNeighborsClassifier
from sklearn.metrics import accuracy_score
import firebase_admin
from firebase_admin import credentials, firestore, db
import time

def listen_for_changes():
    while True:
        time.sleep(6)

        image_url = get_image_url()
        if image_url:
            print(f"Processing image from URL: {image_url}")
            process_image_data(image_url)
        else:
            print("No image URL available.")

def get_image_url():
    try:
        ref = db.reference("control_data/urlgambar")
        data = ref.get()
        print(data)

        if data is not None:
            if isinstance(data, str):
                return data
            else:
                print("Invalid image URL: Data is not a string.")
        else:
            print("Invalid image URL: Data is None.")
        
        return None
    except Exception as e:
        print(f"Error getting image URL: {e}")
        return None

def process_image_data(image_url):
    new_image_values = extract_image_values(image_url)
    new_image_df = pd.DataFrame([new_image_values], columns=["Edge Detection", "Red", "Green", "Blue"])
    predicted_result = knn_model.predict(new_image_df)

    result_labels = {1: "Layu", 2: "Segar"}
    penyebab_labels = {1: "Dapat Dikarenakan Kurang Atau Lebihnya Kelembapan Tanah, Cahaya Matahari, Suhu dan Ketersediaan Air",
                       2: "Tanaman segar. Pertahankan kesegaran ini"}
    result_prediction_str = result_labels[predicted_result[0]]
    penyebab_prediction_str = penyebab_labels[predicted_result[0]]

    db = firestore.client()
    doc_ref = db.collection("Deteksi").document("deteksi1")
    doc_ref.set({
        "hasilprediksi": result_prediction_str,
        "penyebab": penyebab_prediction_str
    })

    print(f"\nHasil Prediksi untuk Gambar Baru: {result_prediction_str}")
    print(f"Penyebab: {penyebab_prediction_str}")
    
    accuracy = accuracy_score(y_test, y_pred)
    print(f'Akurasi model: {accuracy}')

    delete_url()
    
def extract_image_values(image_url):
    try:
        print("Downloading image...")
        response = requests.get(image_url, stream=True)
        response.raise_for_status()

        image_array = np.asarray(bytearray(response.content), dtype=np.uint8)
        image = cv2.imdecode(image_array, cv2.IMREAD_COLOR)

        gray_image = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
        edge_detection_value = cv2.Canny(gray_image, threshold1=30, threshold2=100)
        red_value = image[:, :, 2].mean()
        green_value = image[:, :, 1].mean()
        blue_value = image[:, :, 0].mean()

        return [edge_detection_value.mean(), red_value, green_value, blue_value]

    except Exception as e:
        print(f"Error processing image: {e}")
        return None
    
def delete_url():
    try:
        ref = db.reference("control_data/urlgambar")
        ref.set("")
    except Exception as e:
        print(f"Error deleting 'urlgambar': {e}")

if __name__ == "__main__":
    try:
        current_dir = os.path.dirname(os.path.realpath(__file__))

        cred_path = os.path.join(current_dir, "sendDataDB", "credentials", "google_credential.json")
        train_data_path = os.path.join(current_dir, "OnionLeafDetection", "datatrain.xlsx")

        cred = credentials.Certificate(cred_path)
        firebase_admin.initialize_app(cred, {'databaseURL' : 'https://bawangmerahapp1-default-rtdb.asia-southeast1.firebasedatabase.app/'})

        train_data = pd.read_excel(train_data_path)
        X = train_data[['Edge Detection', 'Red', 'Green', 'Blue']]
        y = train_data['Hasil']
        X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

        knn_model = KNeighborsClassifier(n_neighbors=3)
        knn_model.fit(X_train, y_train)
        y_pred = knn_model.predict(X_test)

        listen_for_changes()

    except Exception as e:
        print(f"Error: {e}")
