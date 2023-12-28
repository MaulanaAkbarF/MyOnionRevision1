import 'package:bawangmerah/component/list_colours.dart';
import 'package:bawangmerah/pages/detail/detail_kelembapan.dart';
import 'package:bawangmerah/pages/detail/detail_kecerahan.dart';
import 'package:bawangmerah/pages/detail/detail_kelembaban_tanah.dart';
import 'package:bawangmerah/pages/detail/detail_suhu_udara.dart';
import 'package:bawangmerah/pages/detail/detail_ph_air.dart';
import 'package:bawangmerah/pages/detail/detail_tinggi_air.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';

class PageInformation extends StatelessWidget {
  static String routeName = '/pageinformation';

  const PageInformation({super.key});
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('Monitoring').doc('monitoring1').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 10),
                  Text("Memuat Data"),
                ],
              ),
            );
          }

          if (!snapshot.hasData) {
            return Text("Data tidak ditemukan");
          }
          var data = snapshot.data!.data() as Map<String, dynamic>;

          return Scaffold(
            body: SafeArea(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: 20,
                        ),
                        Text(
                          "INFORMASI KEBUN",
                          style: GoogleFonts.abel(color: Colors.black, fontSize: 24),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Container(
                          decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(20)),
                          child: Padding(
                            padding: const EdgeInsets.all(15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Icon(Icons.location_on),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Text("Nganjuk", style: TextStyle(fontSize: 20),)
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "35°C",
                                      style: GoogleFonts.abel(fontSize: 40),
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Kemarin: 41°C",
                                          style: GoogleFonts.abel(),
                                        ),
                                        Text("Rata-rata: 37°C", style: GoogleFonts.abel())
                                      ],
                                    ),
                                    Image.asset("assets/clouds.png")
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                        boxInformation(
                          title: "Kecerahan",
                          titleValue: "${data['kecerahan']}",
                          condition: "",
                          informationTitle: "Pukul 17:00 s/d 18:00, Lampu Hidup",
                          onIconButtonPressed: () {
                            PersistentNavBarNavigator.pushNewScreenWithRouteSettings(
                              context,
                              //argument dobawah ni bos
                              settings: RouteSettings(name: DetailKecerahan.routeName),
                              screen: const DetailKecerahan(),
                              withNavBar: true,
                              pageTransitionAnimation: PageTransitionAnimation.cupertino,
                            );
                          },
                        ),
                        boxInformation(
                          title: "pH Tanah",
                          titleValue: "${data['phair']}",
                          condition: "",
                          informationTitle: "pH Netral: 5,6-7",
                          onIconButtonPressed: () {
                            PersistentNavBarNavigator.pushNewScreenWithRouteSettings(
                              context,
                              //argument dobawah ni bos
                              settings: RouteSettings(name: DetailPhAir.routeName),
                              screen: const DetailPhAir(),
                              withNavBar: true,
                              pageTransitionAnimation: PageTransitionAnimation.cupertino,
                            );
                          },
                        ),
                        boxInformation(
                          title: "Kelembaban Udara",
                          titleValue: "${data['kelembaban']}%",
                          condition: "",
                          informationTitle: "Kelembaban udara",
                          value: "Netral : 50%-70%",
                          onIconButtonPressed: () {
                            PersistentNavBarNavigator.pushNewScreenWithRouteSettings(
                              context,
                              //argument dobawah ni bos
                              settings: RouteSettings(name: DetailKelembapan.routeName),
                              screen: const DetailKelembapan(),
                              withNavBar: true,
                              pageTransitionAnimation: PageTransitionAnimation.cupertino,
                            );
                          },
                        ),
                        boxInformation(
                          title: "Kelembaban Tanah",
                          titleValue: "${data['kelembabantanah']}%",
                          condition: "",
                          informationTitle: "Kelembaban tanah",
                          value: "Netral : 50%-65%",
                          onIconButtonPressed: () {
                            PersistentNavBarNavigator.pushNewScreenWithRouteSettings(
                              context,
                              //argument dobawah ni bos
                              settings: RouteSettings(name: DetailKelembapanTanah.routeName),
                              screen: const DetailKelembapanTanah(),
                              withNavBar: true,
                              pageTransitionAnimation: PageTransitionAnimation.cupertino,
                            );
                          },
                        ),
                        boxInformation(
                          title: "Suhu Udara",
                          titleValue: "${data['suhu']}%",
                          condition: "",
                          informationTitle: "Suhu Udara",
                          value: "Normal : 25°C-36°C",
                          onIconButtonPressed: () {
                            PersistentNavBarNavigator.pushNewScreenWithRouteSettings(
                              context,
                              //argument dobawah ni bos
                              settings: RouteSettings(name: DetailSuhuUdara.routeName),
                              screen: const DetailSuhuUdara(),
                              withNavBar: true,
                              pageTransitionAnimation: PageTransitionAnimation.cupertino,
                            );
                          },
                        ),
                        boxInformation(
                          title: "Ketinggian Air",
                          titleValue: "${data['ketinggianair']}",
                          condition: "",
                          informationTitle: "Ketinggian Air Normal : 50-60 Cm",
                          onIconButtonPressed: () {
                            PersistentNavBarNavigator.pushNewScreenWithRouteSettings(
                              context,
                              //argument dobawah ni bos
                              settings: RouteSettings(name: DetailTinggirAir.routeName),
                              screen: const DetailTinggirAir(),
                              withNavBar: true,
                              pageTransitionAnimation: PageTransitionAnimation.cupertino,
                            );
                          },
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                      ],
                    ),
                  ),
                )),
          );
        }
    );
  }

  Widget boxInformation({
    String? title,
    String? titleValue,
    String? condition,
    Function()? onIconButtonPressed,
    String? informationTitle,
    String? value,
  }) {
    Color conditionColor = Colors.red;

    if (titleValue != null) {
      double numericValue = double.tryParse(titleValue.replaceAll('%', '')) ?? 0.0;

      if (title == "Kecerahan") {
        if (numericValue < 20) {
          condition = "Lampu Mati";
          conditionColor = Colors.black;
        } else {
          condition = "Lampu Hidup";
          conditionColor = Colors.red;
        }
      } else if (title == "pH Air") {
        if (numericValue < 5.6) {
          condition = "pH Air terlalu asam";
          conditionColor = Colors.red;
        } else if (numericValue > 7) {
          condition = "pH Air terlalu basa";
          conditionColor = Colors.red;
        } else {
          condition = "Baik";
          conditionColor = Colors.black;
        }
      } else if (title == "Kelembaban Udara") {
        if (numericValue < 50) {
          condition = "Udara Kering";
          conditionColor = Colors.red;
        } else if (numericValue > 70) {
          condition = "Udara terlalu basah";
          conditionColor = Colors.red;
        } else {
          condition = "Normal";
          conditionColor = Colors.black;
        }
      } else if (title == "Kelembaban Tanah") {
        if (numericValue < 50) {
          condition = "Tanah Kering";
          conditionColor = Colors.red;
        } else if (numericValue > 65) {
          condition = "Tanah terlalu basah";
          conditionColor = Colors.red;
        } else {
          condition = "Normal";
          conditionColor = Colors.black;
        }
      } else if (title == "Suhu Udara") {
        if (numericValue < 25) {
          condition = "Suhu udara dingin";
          conditionColor = Colors.red;
        } else if (numericValue > 36) {
          condition = "Suhu udara terlalu panas";
          conditionColor = Colors.red;
        } else {
          condition = "Normal";
          conditionColor = Colors.black;
        }
      } else if (title == "Ketinggian Air") {
        if (numericValue < 50) {
          condition = "Air Kering";
          conditionColor = Colors.red;
        } else if (numericValue > 60) {
          condition = "Sawah Tergenang";
          conditionColor = Colors.red;
        } else {
          condition = "Normal";
          conditionColor = Colors.black;
        }
      }
    }

    return Column(
      children: [
        const SizedBox(
          height: 20,
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "$title",
                  style: GoogleFonts.abel(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Text(
                        "$titleValue",
                        style: GoogleFonts.abel(
                          fontSize: 28,
                          color: conditionColor,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2, // Adjust the flex value as needed
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "$condition",
                            style: GoogleFonts.abel(
                              fontSize: 16,
                              color: conditionColor,
                            ),
                          ),
                          Text(
                            "$informationTitle",
                            style: GoogleFonts.abel(
                              color: ColoursList.grenn,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          value != null
                              ? Text(
                            value,
                            style: GoogleFonts.abel(
                              color: ColoursList.grenn,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                              : const Text(""),
                        ],
                      ),
                    ),
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(360),
                        color: Colors.green.shade200,
                      ),
                      child: IconButton(
                        onPressed: onIconButtonPressed,
                        icon: const Icon(
                          Icons.arrow_forward,
                          size: 14,
                          color: ColoursList.grenn,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget BoxHistory({String? date, String? time}) {
    return Column(
      children: [
        const SizedBox(
          height: 10,
        ),
        Container(
          decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(15)),
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "$date",
                  style: GoogleFonts.abel(),
                ),
                Text(
                  "$time",
                  style: GoogleFonts.abel(
                      color: ColoursList.grenn, fontWeight: FontWeight.bold),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}
