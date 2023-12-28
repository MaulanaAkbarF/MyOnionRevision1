import 'package:bawangmerah/component/list_colours.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DetailKelembapanTanah extends StatelessWidget {
  static String routeName = '/kelembabantanah';

  String _getCondition(double Kelembabantanah) {
    if (Kelembabantanah < 50) {
      return "Tanah Kering";
    } else if (Kelembabantanah > 65) {
      return "Tanah terlalu basah";
    } else {
      return "Normal";
    }
  }

  Color _getTextColor(double Kelembabantanah) {
    if (Kelembabantanah < 50 || Kelembabantanah > 65) {
      return Colors.red;
    } else {
      return Colors.black;
    }
  }

  const DetailKelembapanTanah({super.key});
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
                "Kelembapan Tanah",
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
                      "${(data['kelembabantanah'] as num).toDouble()}",
                      style: GoogleFonts.abel(
                        fontSize: 60,
                        color: _getTextColor((data['kelembabantanah'] as num).toDouble()),
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Text(
                      _getCondition((data['kelembabantanah'] as num).toDouble()),
                      style: GoogleFonts.abel(
                        color: _getTextColor((data['kelembabantanah'] as num).toDouble()),
                      ),
                    ),
                    Text(
                      "Kelembapan Tanah Netral: 50-70%",
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
                        "Kelembaban tanah memiliki peran krusial dalam pertumbuhan tanaman bawang merah. Tanaman ini membutuhkan kondisi tanah yang cukup lembab untuk mendukung perkembangan umbi yang optimal. Kelembaban tanah yang sesuai memfasilitasi penyerapan nutrisi dan air oleh akar tanaman, memungkinkan proses fotosintesis, dan memicu aktivitas mikroorganisme tanah yang mendukung keseimbangan ekosistem tanah. Namun, kelembaban yang berlebihan dapat menyebabkan masalah seperti penyakit akar dan pembusukan akar, sementara kekurangan kelembaban dapat menghambat pertumbuhan dan mengurangi hasil panen. Oleh karena itu, pengelolaan kelembaban tanah yang tepat sangat penting untuk mencapai produksi bawang merah yang optimal",
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
