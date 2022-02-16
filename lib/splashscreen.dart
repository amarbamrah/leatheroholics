import 'dart:async';
import 'dart:math';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'homescreen.dart';
import 'loginscreen.dart';
import 'nointscreen.dart';

class SplashScreen extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return  SplashState();
  }

}

class SplashState extends State<SplashScreen>{
  bool login=false;

  int roleid=0;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getCredential();
    _startTime();
  }

  _getCredential() async{
    SharedPreferences prefs=await SharedPreferences.getInstance();
    login=prefs.getBool("login");
    if(login==null){
      prefs.setBool("login", false);
      login=false;
    }
    roleid=int.parse(prefs.getString("role_id"));
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
//        decoration: BoxDecoration(gradient: LinearGradient(
//            begin: Alignment.topLeft,
//            end: Alignment.bottomRight,
//            colors: [Colors.blue,Colors.blueAccent])),
        child: Center(
            child: Container(


              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  Container(
                    height: MediaQuery.of(context).size.height-400,
                    child: Center(

                      child:Image.asset("assets/logo.png",width: 150,),

                    ),
                  ),
                  Positioned(
                    child:Column(
                      children: [

                        SizedBox(height: 100,),
                        CircularProgressIndicator(backgroundColor: Colors.white,),
                      ],
                    ),

                    bottom: 50,


                  ),
                ],
              ),
            )
        ),
      ),

    );
  }

  _startTime() async{
    return new Timer(Duration(seconds: 2),_checkConnectivity);
  }

  _navigatePage(res){
    bool connected=true;
    switch(res){
      case ConnectivityResult.none:connected=false;break;
    }

    print(roleid);
    if(connected) {
      if (login) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => HomeScreen()));
      } else {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => LoginScreen()));
      }
    }else{
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => NointScreen()));
    }


  }

  _checkConnectivity(){
    ConnectivityResult res=null;
    Connectivity().checkConnectivity().then((value) => res=value).whenComplete(() => _navigatePage(res));
  }

}