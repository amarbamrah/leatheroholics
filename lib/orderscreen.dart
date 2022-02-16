import 'package:flutter/material.dart';

class OrderScreen extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return OrderScreenState();
  }

}

class OrderScreenState extends State<OrderScreen>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Orders"),
      ),
    );
  }

}