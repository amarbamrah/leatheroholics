import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:leatheroholics/homescreen.dart';
import 'package:leatheroholics/models/user.dart';
import 'package:leatheroholics/utils/config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return LoginScreenState();
  }
}

class LoginScreenState extends State<LoginScreen> {
  bool isLoggingin = false;
  final userController = new TextEditingController();
  final pwdController = new TextEditingController();

  final _formKey = GlobalKey<FormState>();


  @override
  void initState(){
    // TODO: implement initState
    super.initState();

    _getPreferences();


  }

  _getPreferences() async{
    SharedPreferences prefs=await SharedPreferences.getInstance();
    if(prefs.getBool("login")){
      _alreadyLogin();
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Container(
              height: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage('assets/loginbg.jpg'), fit: BoxFit.cover),
                  color: Colors.yellow.withOpacity(0.5)),
            ),
            Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              color: Colors.white.withOpacity(0.7),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  bigText(),
                  Padding(padding: EdgeInsets.all(20),child:Text("Login using your email and password")),
                  loginCard(context)

                ],
              ),
            ),
          ],
        ),
      )
    );
  }

  //email box widget
  Widget emailBox() {
    return TextFormField(
      validator: (value) {
        if (value.isEmpty) {
          return "Please enter username";
        }
        return null;
      },
      controller: userController,
      decoration: InputDecoration(
          hintStyle: TextStyle(fontSize: 14),
          labelStyle: TextStyle(fontSize: 14),
          prefixIcon: Icon(Icons.person),
          hintText: "Enter username",
          labelText: "Username"),
    );
  }

  //password box widget
  Widget passwordBox() {
    return TextFormField(
      validator: (value) {
        if (value.isEmpty) {
          return "Please enter Password ";
        }
        return null;
      },
      controller: pwdController,
      decoration: InputDecoration(
          hintStyle: TextStyle(fontSize: 14),
          labelStyle: TextStyle(fontSize: 14),
          prefixIcon: Icon(Icons.lock),
          hintText: "Enter Password",
          labelText: "Password"),
      obscureText: true,
    );
  }

  Widget bigText() {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Text(
        "Welcome back User",
        style: TextStyle(
            fontSize: 45, fontWeight: FontWeight.w900, color: Color(0xff777777)),
      ),
    );
  }

  //LOGIN CARD DESIGN
  Widget loginCard(BuildContext ctx) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(

          child: Card(
            elevation: 3,
            margin: EdgeInsets.all(10),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20))),
            child: Container(
                height: 250,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      emailBox(),
                      SizedBox(
                        height: 10,
                      ),
                      passwordBox(),
                      SizedBox(
                        height: 40,
                      ),
                    ],
                  ),
                )),
          ),
        ),
        Positioned(
            bottom: -10,
            left: 0,
            right: 0,
            child: Stack(
              children: <Widget>[
                Container(
                  alignment: Alignment.center,
                  child: Center(
                      child: isLoggingin
                          ? CircularProgressIndicator()
                          : loginBtn(ctx)),
                )
              ],
            ))
      ],
    );
  }

  //LOGIN BUTTON DESIGN
  Widget loginBtn(BuildContext cxt) {
    return RawMaterialButton(
      shape: StadiumBorder(),
      onPressed: () => login(cxt),
      fillColor: Color(0xffe6ad10),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 50),
        child: Text(
          "Login",
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  login(context) async{
    if(_formKey.currentState.validate()) {
      setState(() {
        isLoggingin=true;
        _loginUsingApi();
      });

    }
  }

  _loginUsingApi() async{
    SharedPreferences prefs=await SharedPreferences.getInstance();
    isLoggingin=true;
    String email = userController.text;
    String password = pwdController.text;
    var res = await http.post(Uri.parse(Config.LOGINURL), body: {
      'email': email,
      "password": password
    });
    final result = jsonDecode(res.body);
    if (result['success']) {
      prefs.setString("uname", result['user']['name']);
      prefs.setInt("uid", result['user']['id']);
      prefs.setString("umail", result['user']['email']);
      prefs.setBool("login", true);
      User user=User.fromJson(result['user']);
      initFire();

    } else {
      setState(() {
        isLoggingin=false;
      });
      Toast.show("Incorrect Username or Password", context);
    }

  }

  initFire() async{
    await Firebase.initializeApp();
    FirebaseMessaging firebaseMessaging=FirebaseMessaging.instance;
    String token="";
    firebaseMessaging.getToken().then((value) => token=value).whenComplete(() => regToken(token));
    firebaseMessaging.subscribeToTopic("all");
  }


  regToken(token) async{
    SharedPreferences prefs=await SharedPreferences.getInstance();
    var res = await http.post(Uri.parse(Config.TOKENREG), body: {
    'token': token,
    "uid": prefs.getInt("uid").toString(),
    });
    final result = jsonDecode(res.body);
    if(result['success']){
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => HomeScreen()));
    }

  }





  _alreadyLogin(){
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => HomeScreen()));
  }
}
