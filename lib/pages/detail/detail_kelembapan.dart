import 'package:bawangmerah/component/list_colours.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DetailKelembapan extends StatelessWidget {
  static String routeName = '/kelembaban';

  String _getCondition(double Kelembaban) {
    if (Kelembaban < 50) {
      return "Udara Kering";
    } else if (Kelembaban > 70) {
      return "Udara terlalu basah";
    } else {
      return "Normal";
    }
  }

  Color _getTextColor(double Kelembaban) {
    if (Kelembaban < 50 || Kelembaban > 70) {
      return Colors.red;
    } else {
      return Colors.black;
    }
  }

  const DetailKelembapan({super.key});
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
          "Kelembapan",
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
                "${(data['kelembaban'] as num).toDouble()}",
                style: GoogleFonts.abel(
                  fontSize: 60,
                  color: _getTextColor((data['kelembaban'] as num).toDouble()),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              Text(
                _getCondition((data['kelembaban'] as num).toDouble()),
                style: GoogleFonts.abel(
                  color: _getTextColor((data['kelembaban'] as num).toDouble()),
                ),
              ),
              Text(
                "Kelembapan Netral: 50-70%",
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
                  "Kelembaban udara memiliki pengaruh signifikan terhadap pertumbuhan dan produksi tanaman bawang merah. Bawang merah membutuhkan kondisi kelembaban yang tepat untuk mengoptimalkan pertumbuhannya. Kelembaban udara yang rendah dapat menyebabkan penguapan air yang berlebihan dari daun tanaman, mengakibatkan kekeringan dan stres pada tanaman bawang merah. Sebaliknya, kelembaban udara yang tinggi dapat menyebabkan peningkatan risiko penyakit jamur, seperti busuk daun dan layu. Oleh karena itu, pemeliharaan kelembaban udara yang seimbang di sekitar tanaman bawang merah menjadi kritis untuk memastikan kondisi lingkungan yang optimal bagi pertumbuhan dan hasil panen yang maksimal",
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
