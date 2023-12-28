import 'package:bawangmerah/pages/detail/detail_kelembapan.dart';
import 'package:bawangmerah/pages/detail/detail_ph_air.dart';
import 'package:bawangmerah/pages/detail/detail_tinggi_air.dart';
import 'package:bawangmerah/pages/page_information.dart';
import 'package:bawangmerah/pages/page_navbar.dart';
import 'package:bawangmerah/pages/page_splash_screen.dart';
import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bawang Merah',
      initialRoute: SplashScreen.routeName,
      debugShowCheckedModeBanner: false,
      routes: {
        SplashScreen.routeName: (context) => const SplashScreen(),
        BottomNavBar.routeName: (context) => const BottomNavBar(),
        PageInformation.routeName: (context) => const PageInformation(),
        DetailPhAir.routeName: (context) => const DetailPhAir(),
        DetailTinggirAir.routeName: (context) => const DetailTinggirAir(),
        DetailKelembapan.routeName: (context) => const DetailKelembapan()
      },
    );
  }
}
