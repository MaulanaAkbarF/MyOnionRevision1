import 'package:bawangmerah/component/list_colours.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DetailPhAir extends StatelessWidget {
  static String routeName = '/detailphair';

  String _getCondition(double phValue) {
    if (phValue < 5.6) {
      return "pH Tanah terlalu asam";
    } else if (phValue > 7.0) {
      return "pH Tanah terlalu basa";
    } else {
      return "pH Tanah Normal";
    }
  }

  Color _getTextColor(double phValue) {
    if (phValue < 5.6 || phValue > 7.0) {
      return Colors.red;
    } else {
      return Colors.black; // atau warna lain sesuai kebutuhan
    }
  }

  const DetailPhAir({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('Monitoring').doc(
            'monitoring1').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const CircularProgressIndicator(); // or some loading indicator
          }

          var data = snapshot.data!.data() as Map<String, dynamic>;

          return Scaffold(
            appBar: AppBar(
              title: Text(
                "pH Tanah Dan Air",
                style: GoogleFonts.abel(color: Colors.black),
              ),
              leading: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.black,
                  )),
              backgroundColor: Colors.white,
              elevation: 0,
            ),
            body: SafeArea(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "${(data['phair'] as num).toDouble()}",
                      style: GoogleFonts.abel(
                        fontSize: 60,
                        color: _getTextColor((data['phair'] as num).toDouble()),
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Text(
                      _getCondition((data['phair'] as num).toDouble()),
                      style: GoogleFonts.abel(
                        color: _getTextColor((data['phair'] as num).toDouble()),
                      ),
                    ),
                    Text(
                      "pH Netral: 5,6-7",
                      style: GoogleFonts.abel(color: ColoursList.grenn),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40),
                      child: Divider(
                        thickness: 0.5,
                        color: Colors.black,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        "Pastikan pH Air dan Tanah Anda dalam kondisi Netral karena berpengaruh dalam Tanaman anda, jika pH turun anda dapat menambahkan volumen penyiraman dan juga pemupukan begitupun sebaliknya",
                        style: GoogleFonts.abel(),
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        }
    );
  }
}
