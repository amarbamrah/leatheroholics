import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:leatheroholics/checkoutscreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/address.dart';

import 'package:http/http.dart' as http;
import 'utils/config.dart';

class AdsScreen extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return AdsScreenState();
  }

}


class AdsScreenState extends State<AdsScreen>{

  Address selAds=null;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Addresses"),
      ),
      body: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height,
            child: FutureBuilder<List<Address>>(
              future: _getAdds(),
              builder: (context,snaphot){
                return snaphot.data!=null?_adItem(snaphot.data):Center(child: CircularProgressIndicator(),);
              },
            ),
          ),
          _btnBar()
        ],
      )
    );
  }


  Future<List<Address>> _getAdds()async{
    SharedPreferences prefs=await SharedPreferences.getInstance();
    print(prefs.getInt("uid").toString()+" id");
    var res=null;
    try {
      res = await http.get(Uri.parse(Config.ADDRESSURL + "?uid="+prefs.getInt("uid").toString()));
    } catch (e) {
      print(e);
    }
    final jsonRes = jsonDecode(res.body);
    if(jsonRes['success']){
      final pros = jsonRes['data'] as List;
      print(pros.length);
      return pros.map<Address>((json) => Address.fromJson(json)).toList();
    }
  }

  Widget _btnBar(){
    return Positioned(
      bottom: 0,
      child: Container(
      
          width: MediaQuery.of(context).size.width,
          color: Color(0xfff4f4f4),
          child: Row(
            children: [
              Expanded(child: RawMaterialButton(
                onPressed: ()=>{Navigator.of(context).push(MaterialPageRoute(builder: (context)=>CheckoutScreen()))},
                child: Container(
                  padding:
                  EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Row(
                    children: [
                      Text(
                        "Add new Address",
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
                fillColor: Colors.black87,
              )),
              Expanded(child: RawMaterialButton(
                onPressed: ()=>{Navigator.of(context).push(MaterialPageRoute(builder: (context)=>CheckoutScreen(selAds: selAds,)))},
                child: Container(
                  padding:
                  EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Row(
                    children: [
                      Text(
                        "Use this Address",
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
                fillColor: Theme.of(context).primaryColor,
              ))
            ],
          )),
    );
  }

  _adItem(List<Address> ads){
    if(selAds==null) {
      selAds = ads[0];
    }
    return ListView.builder(
      itemCount: ads.length,
      itemBuilder: (context,n){
        return InkWell(
          onTap: (){setState(() {
            selAds=ads[n];
          });},
          child: Container(
            margin: EdgeInsets.all(10),
            decoration: BoxDecoration(
              border: Border.all(color: selAds.id==ads[n].id?Theme.of(context).primaryColor:Colors.black87,width: selAds.id==ads[n].id?2:1),
            ),
            padding: EdgeInsets.all(20),
            width: MediaQuery.of(context).size.width,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(ads[n].label,style: TextStyle(fontWeight: FontWeight.bold),),
                Text(ads[n].aline1),
                Text(ads[n].aline2),
                Text(ads[n].city),
                Text(ads[n].state+" Pin Code: "+ads[0].picode),
              ],
            ),

          ),
        );
      },
    );
  }

}