import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:leatheroholics/productscreen.dart';
import 'package:leatheroholics/utils/config.dart';

import 'models/product.dart';
import 'package:http/http.dart' as http;

class ProductListScreen extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return ProductListScreenState();
  }

}

class ProductListScreenState extends State<ProductListScreen>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

        title: Text("Bags"),
        actions: [
          IconButton(icon: Icon(Icons.search), onPressed: ()=>{})
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height-100,
          padding: EdgeInsets.all(10),
          child: FutureBuilder(
              future: _fetchProducts(),
              builder: (context,snapshot){
                return snapshot.data!=null?_item(snapshot.data):Center(child: CircularProgressIndicator(),);
              }
          ),
        ),
      ),
    );
  }

  Future<List<Product>> _fetchProducts() async {
    print("yep");
    var res = null;
    try {
      res = await http.get(Uri.parse(Config.PRODUCTURL));
    } catch (e) {
      print(e);
    }
    print(res.statusCode);
    final jsonRes = jsonDecode(res.body);
    print(res.body + "osm");
    bool success = jsonRes['success'];
    if (success) {
      final pros = jsonRes['data'] as List;
      return pros.map<Product>((json) => Product.fromJson(json)).toList();
    }
  }

  Widget _item(List<Product> pros){
    return GridView.builder(

      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 340,childAspectRatio: 9/13
      ),
      itemCount: pros.length,
      itemBuilder: (context,n){
        return Card(

          child: InkWell(
            child: Container(

              padding: EdgeInsets.all(0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Hero(
                    transitionOnUserGestures:true,
                    //Image.network(Config.BASEURL+"/"+pros[n].imgUrl,height: 200,width: MediaQuery.of(context).size.width,fit: BoxFit.cover,),
                    child: Container(
                      height: 200,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        image: DecorationImage(image: NetworkImage(Config.BASEURL+"/"+pros[n].imgUrl),fit: BoxFit.cover),
                      ),
                    ),
                    tag: pros[n].slug,
                  ),
                  SizedBox(width: 15,),
                  Expanded(child:
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(pros[n].title,style: TextStyle(fontSize: 15,fontWeight: FontWeight.w500),),
                        SizedBox(height: 0,),
                        Text("Rs: "+pros[n].price.toString(),style: TextStyle(color: Theme.of(context).primaryColor),)
                      ],
                    ),
                  )
                  )
                ],
              ),
            ),
            onTap: ()=>{
              Navigator.of(context).push(MaterialPageRoute(builder: (context)=>ProductScreen(product: pros[n],)))
            },
          ),
        );
      },
    );
  }

}