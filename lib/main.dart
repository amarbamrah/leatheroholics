import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:leatheroholics/loginscreen.dart';
import 'package:leatheroholics/splashscreen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {


  MaterialColor pcolor=MaterialColor(0xffe6ad10, const<int,Color>{

      50:Color(0xffe6ad10),
      100:Color(0xffe6ad10),
      200:Color(0xffe6ad10),
      300:Color(0xffe6ad10),
      400:Color(0xffe6ad10),
      500:Color(0xffe6ad10),
      600:Color(0xffe6ad10),
      700:Color(0xffe6ad10),
      800:Color(0xffe6ad10),
      900:Color(0xffe6ad10),
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Leatheroholics',
      theme: ThemeData(
        primarySwatch: pcolor ,
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme)
      ),
      home: SplashScreen()
    );
  }
}

