
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:leatheroholics/splashscreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

class NointScreen extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return NointScreenState();
  }

}

class NointScreenState extends State<NointScreen>{



  bool login;
  int roleid;
  var subs;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    subs=Connectivity().onConnectivityChanged.listen((event) {
      _refresh(event);
    });
  }


  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    subs.cancel();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Image.asset("assets/noint.png",width: 200,),
            SizedBox(height: 20,),
            Text("OOPS...",style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold)),
            SizedBox(height: 10,),
            Text("There is no internet connection available!!"),
            SizedBox(height: 15,),
            RawMaterialButton(
              onPressed: _checkConnectivity,
              child: Container(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text("Refresh",style: TextStyle(fontSize: 17),),
                  )
              ),
              shape: StadiumBorder(side: BorderSide(color: Colors.black87)),
            )
          ],
        ),
      ),
    );
  }

  _checkConnectivity(){
    ConnectivityResult res=null;
    Connectivity().checkConnectivity().then((value) => res=value).whenComplete(() => _refresh(res));
  }

  _refresh(ConnectivityResult res){
    bool connected=true;
    switch(res){
      case ConnectivityResult.none:connected=false;break;
    }
    if(!connected){
      Toast.show("No Internet available", context,duration: Toast.LENGTH_SHORT);
    }else {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => SplashScreen()));
    }
  }



}
