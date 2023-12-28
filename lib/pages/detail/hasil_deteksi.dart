import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:google_fonts/google_fonts.dart';

class HasilDeteksiPage extends StatelessWidget {
  final String imageUrl;

  HasilDeteksiPage({
    required this.imageUrl,
  });

  late String hasilPrediksiText = "None";
  late String penyebabText = "Unknown";

  Future<DocumentSnapshot<Map<String, dynamic>>> getDetectionResult() async {
    try {
      return await FirebaseFirestore.instance.collection('Deteksi').doc('deteksi1').get();
    } catch (error) {
      print('Error fetching data: $error');
      throw error;
    }
  }

  Future<Map<String, dynamic>> _simulateProcessing() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> result = await getDetectionResult();
      hasilPrediksiText = result['hasilprediksi'];
      penyebabText = result['penyebab'];
      await Future.delayed(Duration(seconds: 10));
      return {
        'hasilprediksi': hasilPrediksiText,
        'penyebab': penyebabText,
      };
    } catch (error) {
      print('Error fetching data: $error');
      return {
        'hasilprediksi': 'Error',
        'penyebab': 'Error fetching data',
      };
    }
  }

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
          child: FutureBuilder(
            future: _simulateProcessing(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return _buildLoadingWidget();
              } else if (snapshot.hasError) {
                return _buildErrorWidget(snapshot.error);
              } else {
                hasilPrediksiText = snapshot.data!['hasilprediksi'];
                penyebabText = snapshot.data!['penyebab'];

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 300,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        image: DecorationImage(
                          image: NetworkImage(imageUrl),
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Hasil: $hasilPrediksiText",
                      style: TextStyle(
                        fontSize: 18,
                        color: hasilPrediksiText.contains('Segar') ? Colors.green : Colors.red,
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      "Penyebab: $penyebabText",
                      style: TextStyle(
                        fontSize: 18,
                        color: hasilPrediksiText.contains('Segar') ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                );
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 300,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          "Memproses Gambar...",
          style: TextStyle(
            fontSize: 18,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorWidget(Object? error) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 300,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 50,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          "Error: $error",
          style: TextStyle(
            fontSize: 18,
            color: Colors.red,
          ),
        ),
      ],
    );
  }
}
