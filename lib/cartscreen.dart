import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:leatheroholics/checkoutscreen.dart';
import 'package:leatheroholics/models/user.dart';
import 'package:leatheroholics/searchscreen.dart';
import 'package:leatheroholics/utils/config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'models/cart.dart';

class CartScreen extends StatefulWidget{

  @override
  State<StatefulWidget> createState() {
    return CartScreenState();
  }

}

class CartScreenState extends State<CartScreen>{

  double total=0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Cart"),

        actions: [
          IconButton(icon: Icon(Icons.search), onPressed: ()=>{Navigator.of(context).push(MaterialPageRoute(builder: (context)=>SearchScreen()))})
        ],
      ),
      body: _cartScreen(),
    );
  }

  //cart
  Widget _cartScreen() {
    return FutureBuilder<List<Cart>>(
      future: _fetchCart(),
      builder: (context,snapshot){
        return Stack(
          children: [
            Container(
              height: MediaQuery.of(context).size.height,
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              child: Column(
                children: [
                  Container(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:[
                        snapshot.data!=null?_cartItem(snapshot.data):Center(child: CircularProgressIndicator(),)
                      ],
                    ),
                  )
                ],
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
                        onPressed: ()=>{
                          snapshot.data.length>0?
                          Navigator.of(context).push(MaterialPageRoute(builder: (context)=>CheckoutScreen(selAds: null,))):null
                        },
                        child: Container(
                          padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          child: Row(
                            children: [
                              Text(
                                "Checkout",
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
    );
  }


  Widget _cartItem(List<Cart> cart) {
    double subtotal=0;
    if(cart.length>0){
      return Container(
        height: MediaQuery.of(context).size.height-175,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: cart.length + 1,
          itemBuilder: (context, n) {
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
                                    cart[n].variation==null?cart[n].pro.title:cart[n].pro.title +"\n"+cart[n].variation,
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
                            removeCartItem(cart[n])
                          },
                        ),
                      )
                    ],
                  )),
            )
                : Card(
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
                          Text(total.toString())
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
                        children: [Expanded(child: Text("Total:",style: TextStyle(fontWeight: FontWeight.bold),)), Text(total.toString(),style: TextStyle(fontWeight: FontWeight.bold),)],
                      )
                    ],
                  ),
                ));
          },
        ),
      );
    }else{
      return Container(
        height: MediaQuery.of(context).size.height-200,
        child: Center(
          child:Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("No Items in the cart"),
            ],
          )
        ),
      );
    }
  }

  Future<List<Cart>> _fetchCart() async {
    total=0;
    print("yep");
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
      print(pros.length);
      List<Cart> carts=pros.map<Cart>((json) => Cart.fromJson(json)).toList();
      carts.forEach((element) {
        total+=element.pro.price;
      });
      return carts;
    }
  }

  Future removeCartItem(Cart cart)async{
    var res = null;
    try {
      res = await http.delete(Uri.parse(Config.CARTURL + "/"+cart.id.toString()));
    } catch (e) {
      print(e);
    }
    final jsonRes = jsonDecode(res.body);
    print(res.body + "osm");
    bool success = jsonRes['success'];
    if (success) {
      Toast.show(jsonRes['message'], context);
    }
    setState(() {

    });
  }

}