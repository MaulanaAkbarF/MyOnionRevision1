import 'package:bawangmerah/component/list_colours.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DetailSuhuUdara extends StatelessWidget {
  static String routeName = '/suhu';

  String _getCondition(double suhu) {
    if (suhu < 25) {
      return "Suhu udara dingin";
    } else if (suhu > 36) {
      return "Suhu udara terlalu panas";
    } else {
      return "Normal";
    }
  }

  Color _getTextColor(double suhu) {
    if (suhu < 25 || suhu > 36) {
      return Colors.red;
    } else {
      return Colors.black;
    }
  }

  const DetailSuhuUdara({super.key});
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
                "Suhu Udara",
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
                      "${(data['suhu'] as num).toDouble()}",
                      style: GoogleFonts.abel(
                        fontSize: 60,
                        color: _getTextColor((data['suhu'] as num).toDouble()),
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Text(
                      _getCondition((data['suhu'] as num).toDouble()),
                      style: GoogleFonts.abel(
                        color: _getTextColor((data['suhu'] as num).toDouble()),
                      ),
                    ),
                    Text(
                      "Suhu Udara Normal: 25°C-36°C",
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
                        "Suhu udara memainkan peran krusial dalam pertumbuhan tanaman bawang merah. Tanaman ini memerlukan suhu yang optimal untuk proses fotosintesis, perkembangan akar, dan pembentukan umbi. Suhu rendah dapat menghambat pertumbuhan dan menyebabkan kerugian hasil karena menghambat aktivitas enzim yang diperlukan untuk metabolisme tanaman. Di sisi lain, suhu tinggi juga dapat berdampak negatif, menghambat pertumbuhan akar, dan menyebabkan stres panas. Oleh karena itu, menjaga suhu udara dalam kisaran yang cocok untuk tanaman bawang merah, sekitar 20-25 derajat Celsius, dapat meningkatkan hasil panen dan kesehatan tanaman secara keseluruhan. Faktor ini perlu diperhatikan dalam pengelolaan pertanian untuk mencapai produksi yang optimal",
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
