const admin = require('firebase-admin');
const express = require('express');
const axios = require('axios');
const cv = require('opencv4nodejs');
const { KNeighborsClassifier } = require('machinelearn/knn');
const { accuracy_score } = require('machinelearn/metrics');

admin.initializeApp({
  credential: admin.credential.cert(require('./sendDataDB/credentials/google_credential.json')),
  databaseURL: 'https://bawangmerahapp1-default-rtdb.asia-southeast1.firebasedatabase.app/',
});

const app = express();

async function listenForChanges() {
  try {
    while (true) {
      await sleep(1000);

      const imageUrl = await getImageUrl();
      if (imageUrl) {
        console.log(`Processing image from URL: ${imageUrl}`);
        await processImageData(imageUrl);
      } else {
        console.log("No image URL available.");
      }
    }
  } catch (error) {
    console.error(`Error in listenForChanges: ${error}`);
  }
}

function sleep(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

async function getImageUrl() {
  try {
    const ref = admin.database().ref('control_data/urlgambar');
    const data = (await ref.once('value')).val();
    console.log(data);

    if (data !== null) {
      if (typeof data === 'string') {
        return data;
      } else {
        console.log("Invalid image URL: Data is not a string.");
      }
    } else {
      console.log("Invalid image URL: Data is null.");
    }

    return null;
  } catch (error) {
    console.error(`Error getting image URL: ${error}`);
    return null;
  }
}

async function extractImageValues(imageUrl) {
  try {
    console.log("Downloading image...");
    const response = await axios.get(imageUrl, { responseType: 'arraybuffer' });

    const imageArray = new Uint8Array(response.data);
    const image = cv.imdecode(imageArray, cv.IMREAD_COLOR);

    const grayImage = image.cvtColor(cv.COLOR_BGR2GRAY);
    const edgeDetectionValue = grayImage.canny(30, 100);
    const redValue = image.at(0).mean().z;
    const greenValue = image.at(0).mean().y;
    const blueValue = image.at(0).mean().x;

    return [edgeDetectionValue.mean(), redValue, greenValue, blueValue];
  } catch (error) {
    console.error(`Error processing image: ${error}`);
    return null;
  }
}

async function processImageData(imageUrl) {
  const newImageValues = await extractImageValues(imageUrl);

  if (newImageValues) {
    const [edgeDetection, redValue, greenValue, blueValue] = newImageValues;
    console.log(`\nEdge Detection Value: ${edgeDetection}`);
    console.log(`Red Value: ${redValue}`);
    console.log(`Green Value: ${greenValue}`);
    console.log(`Blue Value: ${blueValue}`);

    const newImageDf = pd.DataFrame([newImageValues], ['Edge Detection', 'Red', 'Green', 'Blue']);
    const predictedResult = knnModel.predict(newImageDf);

    const resultLabels = { 1: 'Layu', 2: 'Segar' };
    const penyebabLabels = {
      1: 'Dapat Dikarenakan Kurang atau Lebihnya Kelembapan Tanah, Cahaya Matahari, Suhu dan Ketersediaan Air',
      2: 'Tanaman segar. Pertahankan kesegaran ini',
    };

    const resultPredictionStr = resultLabels[predictedResult[0]];
    const penyebabPredictionStr = penyebabLabels[predictedResult[0]];

    const db = admin.firestore();
    const docRef = db.collection('Deteksi').doc('deteksi1');
    await docRef.set({
      hasilprediksi: resultPredictionStr,
      penyebab: penyebabPredictionStr,
    });

    console.log(`\nPrediction Result for New Image: ${resultPredictionStr}`);
    console.log(`Cause: ${penyebabPredictionStr}`);

    const accuracy = accuracy_score(y_test, y_pred);
    console.log(`Model Accuracy: ${accuracy}`);

    await deleteUrl();
  } else {
    console.log('Failed to get Edge Detection, Red, Green, and Blue values.');
  }
}

async function deleteUrl() {
  try {
    const ref = admin.database().ref('control_data/urlgambar');
    await ref.set('');
  } catch (error) {
    console.error(`Error deleting 'urlgambar': ${error}`);
  }
}

if (require.main === module) {
  try {
    const currentDir = __dirname;

    const credPath = path.join(currentDir, 'sendDataDB', 'credentials', 'google_credential.json');
    const trainDataPath = path.join(currentDir, 'OnionLeafDetection', 'datatrain.xlsx');

    const cred = require(credPath);
    admin.initializeApp({ credential: admin.credential.cert(cred), databaseURL: 'https://bawangmerahapp1-default-rtdb.asia-southeast1.firebasedatabase.app/' });

    const trainData = pd.read_excel(trainDataPath);
    const X = trainData[['Edge Detection', 'Red', 'Green', 'Blue']];
    const y = trainData['Hasil'];
    const { X_train, X_test, y_train, y_test } = train_test_split(X, y, 0.2, 42);

    const knnModel = new KNeighborsClassifier(7, 'uniform', 'auto');
    knnModel.fit(X_train, y_train);
    const yPred = knnModel.predict(X_test);

    listenForChanges();
  } catch (error) {
    console.error(`Error: ${error}`);
  }
}

module.exports = app;
