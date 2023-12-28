import 'package:bawangmerah/component/list_colours.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DetailKecerahan extends StatelessWidget {
  static String routeName = '/kecerahan';

  String _getCondition(double kecerahan) {
    if (kecerahan < 20) {
      return "Lampu Mati";
    } else {
      return "Lampu Hidup";
    }
  }

  Color _getTextColor(double kecerahan) {
    if (kecerahan < 50 || kecerahan > 65) {
      return Colors.red;
    } else {
      return Colors.black;
    }
  }

  const DetailKecerahan({super.key});
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
                "Kecerahan",
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
                      "${(data['kecerahan'] as num).toDouble()}",
                      style: GoogleFonts.abel(
                        fontSize: 60,
                        color: _getTextColor((data['kecerahan'] as num).toDouble()),
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Text(
                      _getCondition((data['kecerahan'] as num).toDouble()),
                      style: GoogleFonts.abel(
                        color: _getTextColor((data['kecerahan'] as num).toDouble()),
                      ),
                    ),
                    Text(
                      "Pukul 17:00 s/d 18:00, Lampu Hidup",
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
                        "Cahaya lampu menyinari sawah yang gelap. Juga mencegah ",
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
