import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:leatheroholics/adssscreen.dart';
import 'package:leatheroholics/models/address.dart';
import 'package:leatheroholics/models/coupan.dart';
import 'package:leatheroholics/utils/config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

import 'models/cart.dart';

class CheckoutScreen extends StatefulWidget{

  Address selAds;

  CheckoutScreen({this.selAds});
  @override
  State<StatefulWidget> createState() {
    return CheckoutState(selAds: selAds);
  }

}


class CheckoutState extends State<CheckoutScreen>{

  Address selAds;

  CheckoutState({this.selAds});
  double total=0;

  double discount=0;

  Coupan coupan=null;

  TextEditingController _coupanController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _coupanController=TextEditingController();
  }
  @override
  Widget build(BuildContext context) {
   return Scaffold(
     appBar: AppBar(
       title: Text("Checkout"),

     ),
     body: FutureBuilder(
       future: _fetchCart(),
       builder: (context,snapshot){
         return Stack(
           children: [
             Container(
               height: MediaQuery.of(context).size.height,
               child: SingleChildScrollView(
                 child: Container(
                   height: MediaQuery.of(context).size.height,
                   padding: EdgeInsets.all(10),
                   child: Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [

                       Container(

                         child:  snapshot.data != null?_cartItemm(snapshot.data): Center(
                               child: CircularProgressIndicator(),
                             )

                       )
                     ],
                   ),
                 ),
               ),
             ),
             Positioned(
               bottom: 0,
               child: Container(
                   padding:
                   EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
                   width: MediaQuery.of(context).size.width,
                   color: Color(0xfff4f4f4),
                   child: Row(
                     children: [
                       Expanded(
                         child: Text(
                           "Rs "+total.toString(),
                           style:
                           TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                         ),
                       ),
                       RawMaterialButton(
                         onPressed: ()=>{_placeOrder()},
                         child: Container(
                           padding:
                           EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                           child: Row(
                             children: [
                               Text(
                                 "Place Order",
                                 style: TextStyle(color: Colors.white),
                               ),
                             ],
                           ),
                         ),
                         fillColor: Theme.of(context).primaryColor,
                       )
                     ],
                   )),
             )
           ],
         );
       },
     )
   );
  }

  Widget _addressBox(){
    return Container(

      child: FutureBuilder<List<Address>>(
        future: _getAdds(),
        builder: (context,snapshot){
          return snapshot.data!=null?snapshot.data.length>0?_addressItem(snapshot.data):Container(
            width: MediaQuery.of(context).size.width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                Text("No Address Found"),
                SizedBox(height: 5,),
                RawMaterialButton(
                  onPressed: ()=>{Navigator.of(context).push(MaterialPageRoute(builder: (context)=>AdsScreen()))},
                  fillColor: Theme.of(context).primaryColor,
                  child: Container(
                    padding: EdgeInsets.all(10),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.home),
                        Text("Add Address"),
                      ],
                    ),
                  ),
                ),

              ],
            ),
          ):Center(child: CircularProgressIndicator(),);
        },
      ),
    );
  }


  Widget _addressItem(List<Address> ads){
    if(selAds==null){
      selAds=ads[0];
    }
        return selAds==null?
        Card(
          child: Container(
            padding: EdgeInsets.all(20),
            width: MediaQuery.of(context).size.width,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Address",style: TextStyle(fontWeight: FontWeight.bold),),
                Text(ads[0].aline1),
                Text(ads[0].aline2),
                Text(ads[0].city),
                Text(ads[0].state+" Pin Code: "+ads[0].picode),
                SizedBox(height: 20,),
                RawMaterialButton(
                  fillColor: Theme.of(context).primaryColor,
                  onPressed: ()=>{Navigator.of(context).push(MaterialPageRoute(builder: (context)=>AdsScreen()))},
                  child: Container(
                    padding: EdgeInsets.all(10),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.home),
                        Text("Add or Change Address"),
                      ],
                    ),
                  ),
                ),

              ],
            ),
          ),
        ):
        Card(
          child: Container(
            padding: EdgeInsets.all(20),
            width: MediaQuery.of(context).size.width,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Address",style: TextStyle(fontWeight: FontWeight.bold),),
                Text(selAds.aline1),
                Text(selAds.aline2),
                Text(selAds.city),
                Text(selAds.state+" Pin Code: "+selAds.picode),
                SizedBox(height: 20,),
                RawMaterialButton(
                  fillColor: Theme.of(context).primaryColor,
                  onPressed: ()=>{Navigator.of(context).push(MaterialPageRoute(builder: (context)=>AdsScreen()))},
                  child: Container(
                    padding: EdgeInsets.all(10),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.home),
                        Text("Add or Change Address"),
                      ],
                    ),
                  ),
                ),

              ],
            ),
          ),
        );

  }


  Future<List<Cart>> _fetchCart() async {
    print("yep");
    total=0;
    var res = null;
    SharedPreferences prefs=await SharedPreferences.getInstance();
    print(prefs.getInt("uid").toString()+" id");
    try {
      res = await http.get(Uri.parse(Config.CARTURL + "?uid="+prefs.getInt("uid").toString()));
    } catch (e) {
      print(e);
    }
    final jsonRes = jsonDecode(res.body);
    print(res.body + "osm");
    bool success = jsonRes['success'];
    if (success) {
      final pros = jsonRes['data'] as List;
      List<Cart> carts=pros.map<Cart>((json) => Cart.fromJson(json)).toList();
      carts.forEach((element) {
        total+=element.pro.price;
      });
      return carts;
    }
  }




  List<Widget> _cartItem(List<Cart> cart) {
    double subtotal=0;
    List<Widget> items=[];
    cart.forEach((element) {
      items.add(
          Card(
            child: Container(
              height: 20,
                padding: EdgeInsets.only(
                    left: 20, right: 20, top: 20, bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,

                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  element.pro.title,
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text("Rs " + element.pro.price.toString())
                              ],
                            )),
                        Image.network(
                          Config.BASEURL + "/" + element.pro.imgUrl,
                          width: 80,
                        )
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      height: 1,
                      color: Colors.black12,
                    ),
                    Center(
                      child: RawMaterialButton(
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          child: Row(
                            children: [
                              Icon(
                                Icons.clear,
                                color: Colors.redAccent,
                              ),
                              Text(
                                "REMOVE",
                                style: TextStyle(color: Colors.redAccent),
                              )
                            ],
                          ),
                        ),
                        onPressed: ()=>{

                        },
                      ),
                    )
                  ],
                )),
          )
      );
    });
    items.add(
        Card(
            child: Container(
              padding: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Price Details",
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      Expanded(child: Text("Subtotal:")),
                      Text(subtotal.toString())
                    ],
                  ),
                  SizedBox(
                    height: 7,
                  ),
                  Row(
                    children: [
                      Expanded(child: Text("Shipping Charges:")),
                      Text("0")
                    ],
                  ),
                  SizedBox(
                    height: 7,
                  ),
                  Row(
                    children: [Expanded(child: Text("Total:",style: TextStyle(fontWeight: FontWeight.bold),)), Text(subtotal.toString(),style: TextStyle(fontWeight: FontWeight.bold),)],
                  )
                ],
              ),
            ))
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

  Widget _cartItemm(List<Cart> cart) {
    double subtotal=0;
    return Container(
      height: MediaQuery.of(context).size.height-150,
      child: ListView.builder(
        itemCount: cart.length + 2,

        itemBuilder: (context, n) {
          if(n==0){
            return _addressBox();
          }else {
            n=n-1;
            n != cart.length ? subtotal += cart[n].pro.price : subtotal += 0;
            total = subtotal;
            return n != cart.length
                ? Card(
              child: Container(

                  padding: EdgeInsets.only(
                      left: 20, right: 20, top: 20, bottom: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,

                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    cart[n].pro.title,
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text("Rs " + cart[n].pro.price.toString())
                                ],
                              )),
                          Image.network(
                            Config.BASEURL + "/" + cart[n].pro.imgUrl,
                            width: 80,
                          )
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        height: 1,
                        color: Colors.black12,
                      ),
                      Center(
                        child: RawMaterialButton(
                          child: Container(
                            width: MediaQuery
                                .of(context)
                                .size
                                .width,
                            child: Row(
                              children: [
                                Icon(
                                  Icons.clear,
                                  color: Colors.redAccent,
                                ),
                                Text(
                                  "REMOVE",
                                  style: TextStyle(color: Colors.redAccent),
                                )
                              ],
                            ),
                          ),
                          onPressed: () =>
                          {
                          },
                        ),
                      )
                    ],
                  )),
            )
                : Column(
              children: [

                Card(
                    child: Container(
                      padding: EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Price Details",
                            style: TextStyle(fontSize: 16),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              Expanded(child: Text("Subtotal:")),
                              Text(subtotal.toString())
                            ],
                          ),
                          SizedBox(
                            height: 7,
                          ),
                          Row(
                            children: [
                              Expanded(child: Text("Coupan:")),
                              RawMaterialButton(
                                onPressed: ()=>{coupanDialog()},
                                child: Container(
                                  child:Text(coupan!=null?coupan.coupan:"Apply Coupan",style: TextStyle(color: Theme.of(context).primaryColor),),
                                ),
                              )
                            ],
                          ),
                          SizedBox(
                            height: 7,
                          ),
                          Row(
                            children: [
                              Expanded(child: Text("Discount:")),
                              Text(discount.toString())
                            ],
                          ),
                          SizedBox(
                            height: 7,
                          ),
                          Row(
                            children: [
                              Expanded(child: Text("Shipping Charges:")),
                              Text("0")
                            ],
                          ),
                          SizedBox(
                            height: 7,
                          ),
                          Row(
                            children: [
                              Expanded(child: Text("Total:",
                                style: TextStyle(fontWeight: FontWeight.bold),)),
                              Text(subtotal.toString(), style: TextStyle(
                                  fontWeight: FontWeight.bold),)
                            ],
                          )
                        ],
                      ),
                    ))
              ],
            );
          }
        },
      ),
    );
  }


  coupanDialog(){
    showDialog(
        context: context,
        builder: (context){
          return Dialog(
            child: Container(
              padding: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _coupanController,
                    decoration: InputDecoration(
                        hintText: "Coupan Code",
                        hintStyle: TextStyle(fontSize: 14)
                    ),
                  ),
                  SizedBox(height: 5,),
                  RawMaterialButton(
                    onPressed: ()=>{_checkCoupan(_coupanController.text)},
                    fillColor: Theme.of(context).primaryColor,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text("Apply Coupan")
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        }
    );
  }

  _placeOrder()async{
    SharedPreferences prefs=await SharedPreferences.getInstance();
    var response = await http.post(Uri.parse(Config.ADDORDERURL),body: {
      'uid': prefs.getInt("uid").toString(),
      'total':total.toString(),
      'discount':discount.toString(),
      'coupan':coupan!=null?coupan.coupan:null,
      'status':'Processing',
      'aid':selAds.id.toString()
    });
    print(response.body);
    final json=jsonDecode(response.body);
    if(json['success']){
      print("order placed");
    }
  }

  _checkCoupan(String code)async{
    var res=await http.get(Uri.parse(Config.CHECKCOUPANURL+"?coupan="+code));
    print(res.body);
    var json=jsonDecode(res.body);
    if(json['success']){
      this.coupan=Coupan.fromJson(json['data']);
      double disc=0;
      if(coupan.type=="per"){
        disc=coupan.amount*total;
        disc=disc/100;
      }else{
        disc=coupan.amount;
      }
      setState(() {
        discount=disc;
      });
      Toast.show("Coupan Code Applied Successfully!!", context);
      Navigator.pop(context);
    }else{
      setState(() {
        coupan=null;
      });
      Toast.show(json['message'], context);
    }
  }


}