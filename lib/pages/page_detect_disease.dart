import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'detail/hasil_deteksi.dart';

class PageDetectPenyakit extends StatefulWidget {
  const PageDetectPenyakit({super.key});

  @override
  State<PageDetectPenyakit> createState() => _PageDetectPenyakitState();
}

enum UploadStatus { idle, uploading, success, error }

class _PageDetectPenyakitState extends State<PageDetectPenyakit> {
  File? _image;
  final picker = ImagePicker();
  String imageName = '';
  String imagePath = '';
  UploadStatus _uploadStatus = UploadStatus.idle;
  OverlayEntry? _overlayEntry;
  String hasilPrediksiText = '';
  String penyebabText = '';

  Future<void> getImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(
      source: source,
    );

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        imageName = pickedFile.name ?? '';
        imagePath = pickedFile.path ?? '';
      }
    });
  }

  Future<String?> uploadImageToFirebase() async {
    if (_image == null) {
      return null;
    }

    try {
      String uniqueFileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference referenceRoot = FirebaseStorage.instance.ref();
      Reference referenceDirImages = referenceRoot.child('images');
      Reference referenceImageToUpload = referenceDirImages.child('$uniqueFileName.jpg');

      try {
        await referenceImageToUpload.delete();
      } catch (e) {
        print('File does not exist, no need to delete.');
      }

      if (kIsWeb || Platform.isLinux || Platform.isMacOS || Platform.isWindows) {
        List<int> imageData = await _image!.readAsBytes();
        UploadTask task = referenceImageToUpload.putData(Uint8List.fromList(imageData));
        TaskSnapshot snapshot = await task.whenComplete(() => null);
        String imageUrl = await snapshot.ref.getDownloadURL();

        print('Image uploaded successfully. URL: $imageUrl');

        return imageUrl;
      } else {
        await referenceImageToUpload.putFile(_image!);
        String imageUrl = await referenceImageToUpload.getDownloadURL();

        print('Image uploaded successfully. URL: $imageUrl');

        return imageUrl;
      }
    } catch (error) {
      print('Error uploading image: $error');
      return null;
    }
  }

  Future<void> saveImageUrlToDatabase(String imageUrl) async {
    DatabaseReference databaseReference = FirebaseDatabase.instance.reference().child('control_data');

    await databaseReference.update({
      'urlgambar': imageUrl
    });
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getDetectionResult() async {
    try {
      return await FirebaseFirestore.instance.collection('Deteksi').doc('deteksi1').get();
    } catch (error) {
      print('Error fetching data: $error');
      throw error;
    }
  }

  void _navigateToHasilDeteksi(String imageUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HasilDeteksiPage(
          imageUrl: imageUrl,
        ),
      ),
    );
  }

  bool isAutoWatering = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Hasil Deteksi",
          style: GoogleFonts.abel(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _image == null
                  ? Container(
                height: 300,
                decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(10)),
              )
                  : Container(
                height: 300,
                decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    image: DecorationImage(
                        image: FileImage(_image!), fit: BoxFit.cover),
                    borderRadius: BorderRadius.circular(20)),
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => getImage(ImageSource.camera),
                      style: ElevatedButton.styleFrom(primary: Colors.red),
                      child: Text("Kamera"),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => getImage(ImageSource.gallery),
                      style: ElevatedButton.styleFrom(primary: Colors.green),
                      child: Text("Galeri"),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                imageName.isNotEmpty
                    ? "Nama File Gambar: $imageName"
                    : "Nama File Gambar: -",
                style: GoogleFonts.abel(fontSize: 18),
              ),
              Text(
                imagePath.isNotEmpty
                    ? "Jalur Gambar: $imagePath"
                    : "Jalur Gambar: -",
                style: GoogleFonts.abel(fontSize: 14),
              ),
              const SizedBox(
                height: 40,
              ),
              Align(
                alignment: Alignment.center,
                child: ElevatedButton(
                  onPressed: () async {
                    _showOverlay();

                    String? imageUrl = await uploadImageToFirebase();
                    if (imageUrl != null) {
                      await saveImageUrlToDatabase(imageUrl);

                      setState(() {
                        _uploadStatus = UploadStatus.success;
                      });

                      _removeOverlay();

                      _navigateToHasilDeteksi(imageUrl);
                    } else {
                      setState(() {
                        _uploadStatus = UploadStatus.error;
                      });

                      _removeOverlay();
                    }
                  },
                  child: _buildButtonChild(),
                ),
              ),
              SizedBox(height: 10), // Tambahkan spasi di antara button dan teks hasil deteksi
              Text(
                hasilPrediksiText,
                style: TextStyle(
                  fontSize: 18,
                  color: hasilPrediksiText.contains('Segar') ? Colors.green : Colors.red,
                ),
              ),
              Text(
                penyebabText,
                style: TextStyle(
                  fontSize: 18,
                  color: hasilPrediksiText.contains('Segar') ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildButtonChild() {
    switch (_uploadStatus) {
      case UploadStatus.idle:
        return Text("Mulai Deteksi Penyakit");
      case UploadStatus.uploading:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 10),
            Text("Mengirim Data"),
          ],
        );
      case UploadStatus.success:
        return Text("Pengunggahan Sukses");
      case UploadStatus.error:
        return Text("Pengunggahan Gagal");
    }
  }
  void _showOverlay() {
    OverlayState? overlayState = Overlay.of(context);
    _overlayEntry = OverlayEntry(
      builder: (BuildContext context) {
        double screenWidth = MediaQuery.of(context).size.width;
        double screenHeight = MediaQuery.of(context).size.height;

        return Positioned(
          top: screenHeight * 0.5 - 40,
          left: screenWidth * 0.5 - 100,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 10),
                  Text("Mengirim Data", style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
          ),
        );
      },
    );
    overlayState.insert(_overlayEntry!);
  }
  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}
