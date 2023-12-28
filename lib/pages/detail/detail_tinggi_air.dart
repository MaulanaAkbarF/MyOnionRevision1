import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../component/list_colours.dart';

class DetailTinggirAir extends StatelessWidget {
  static String routeName = '/ketinggianair';

  String _getCondition(int KetinggianAir) {
    if (KetinggianAir < 50) {
      return "Air Kering";
    } else if (KetinggianAir > 60) {
      return "Sawah Tergenang";
    } else {
      return "Normal";
    }
  }

  Color _getTextColor(int KetinggianAir) {
    if (KetinggianAir < 50 || KetinggianAir > 60) {
      return Colors.red;
    } else {
      return Colors.black;
    }
  }

  const DetailTinggirAir({super.key});
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
          "Ketinggian Air",
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
                "${data['ketinggianair']}",
                style: GoogleFonts.abel(
                  fontSize: 60,
                  color: _getTextColor(data['ketinggianair']),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              Text(
                _getCondition(data['ketinggianair']),
                style: GoogleFonts.abel(
                  color: _getTextColor(data['ketinggianair']),
                ),
              ),
              Text(
                "Ketinggian Normal: 50-60Cm",
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
                  "Volume air memiliki pengaruh signifikan terhadap pertumbuhan tanaman bawang merah. Tanaman bawang merah sangat membutuhkan pasokan air yang cukup untuk mendukung perkembangan akar, penyerapan nutrisi, dan proses fotosintesis. Jika volume air tidak mencukupi, tanaman bawang merah dapat mengalami stres kekeringan yang menghambat pertumbuhan dan mengurangi hasil panen. Sebaliknya, peningkatan volume air yang sesuai dengan kebutuhan tanaman dapat meningkatkan produksi dan kualitas bawang merah. Pengaturan yang tepat pada pola penyiraman dan manajemen volume air menjadi kunci dalam memastikan pertumbuhan optimal dan hasil panen yang memuaskan pada tanaman bawang merah",
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
