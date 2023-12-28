import time
import firebase_admin
from firebase_admin import credentials, firestore, db

cred = credentials.Certificate("C:/All Programming Pojects/Dart/bawangmerahapp/pythonscript/sendDataDB/credentials/google_credential.json")
firebase_admin.initialize_app(cred, {
    'databaseURL' : 'https://bawangmerahapp1-default-rtdb.asia-southeast1.firebasedatabase.app/'
})

firestore_db = firestore.client()
rt_db = db.reference('sensor_data')

counter = 0

while True:
    try:
        lama_penyiraman_doc = firestore_db.collection('LamaPenyiraman').document('lamapenyiraman1').get()
        # lama_penyiraman_doc2 = firestore_db.collection('LamaPenyiraman').document('lamapenyiraman2').get()
        menit = lama_penyiraman_doc.get('menit')
        # kondisi = lama_penyiraman_doc2.get('condition')

        control_data_ref = db.reference('control_data')
        control_data_ref.child('lamapenyiramanmulai').set({
            'menit': menit
        })

        # control_data_ref.child('lamapenyiramanselesai').set({
        #     'kondisi': kondisi
        # })

        data = rt_db.get()

        doc_ref = firestore_db.collection('Monitoring').document('monitoring1')
        doc_ref.set({
            'kecerahan': data['Kecerahan'],
            'kelembaban': data['Kelembaban'],
            'kelembabantanah': data['Kelembaban_Tanah'],
            'ketinggianair': data['Jarak'],
            'phair': data['pH_Tanah'],
            'suhu': data['Suhu']
        })

        counter += 1
        print("\nData Berhasil Dikirim.\nLog Data:", counter)
    except Exception as e:
        print("Terjadi kesalahan: ", e)

    time.sleep(5)