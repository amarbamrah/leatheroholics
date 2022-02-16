import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:leatheroholics/cartscreen.dart';
import 'package:leatheroholics/models/product.dart';
import 'package:leatheroholics/models/review.dart';
import 'package:leatheroholics/utils/config.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';


class ProductScreen extends StatefulWidget{
  Product product;



  ProductScreen({this.product});
  @override
  State<StatefulWidget> createState() {
    return ProductScreenState(product: product);
  }

}

class ProductScreenState extends State<ProductScreen>{
  Product product;
  String selSize="";
  List<dynamic> values;

  ProductScreenState({this.product}){
    if(product.variation!=null) {
      var json = jsonDecode(product.variation);
      values = json[0]['values'];
      selSize = values[0];
    }else{
      values=[];
    }
  }

  TextEditingController _desccontroller=TextEditingController();



  Widget _topSlider(){
    List<String> imgList=[];
    product.images. forEach((element) {
      imgList.add(Config.BASEURL+"/"+element.imgurl);
    });
    return CarouselSlider(
        items: imgList.map((e) => Container(
          child:Container(
            decoration: BoxDecoration(
               image: DecorationImage(image: NetworkImage(e),fit: BoxFit.cover),
                borderRadius: BorderRadius.only(bottomRight: Radius.circular(20),bottomLeft: Radius.circular(20))
            ),
          )

        )).toList(),
        options: CarouselOptions(
          aspectRatio: 16/9,
          viewportFraction: 1.0,
          enlargeCenterPage: false,
          height: 500,
          autoPlay: false
        )
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<bool>(
        future: _checkInCart(),
        builder: (context,snapshot){
          return snapshot.data!=null?Stack(
            children: [
              Container(
                  color: Color(0xfff4f4f4),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        //Image.network(Config.BASEURL+"/"+product.imgUrl,height: 500,width: MediaQuery.of(context).size.width,fit: BoxFit.cover,alignment: Alignment.center,),

                        Hero(tag: product.slug, child: Container(
                          height: 500,
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                              image: DecorationImage(image: NetworkImage(Config.BASEURL+"/"+product.imgUrl,),fit: BoxFit.cover),
                              borderRadius: BorderRadius.only(bottomRight: Radius.circular(20),bottomLeft: Radius.circular(20))
                          ),
                          child: _topSlider(),
                        ),transitionOnUserGestures: true,),
                        Container(
                            width: MediaQuery.of(context).size.width,
                            padding: EdgeInsets.all(10),
                            child: Card(
                              elevation: 0,
                                color: Colors.transparent,
                                child: Container(
                                  padding: EdgeInsets.all(10),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(product.title,style: TextStyle(fontSize: 20),),
                                      Text("Rs "+product.price.toString(),style: TextStyle(fontSize: 18,color: Theme.of(context).primaryColor),),
                                      SizedBox(height: 10,),
                                      _sizeBoxes(product),
                                      SizedBox(height: 10,),
                                      Text("Description:",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),),
                                      Html(data: product.desc),
                                      SizedBox(height: 0,)
                                    ],
                                  ),
                                )
                            )
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          padding: EdgeInsets.all(10),
                          child: Card(
                              child: Container(
                                padding: EdgeInsets.all(10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(child: Text("Reviews",style: TextStyle(fontWeight: FontWeight.bold),),),
                                        InkWell(child: Text("Write a Review",style: TextStyle(color: Theme.of(context).primaryColor),),
                                        onTap: ()=>{
                                          showDialog(context: context, builder: (context){
                                            return _reviewBox();
                                          })
                                        },)
                                      ],
                                    ),
                                    SizedBox(height: 10,),
                                    FutureBuilder(
                                      future: _getReviews(),
                                      builder: (context,snapshot){
                                        return snapshot.data!=null?_reviewItem(snapshot.data):Center(child: CircularProgressIndicator(),);
                                      },
                                    )
                                  ],
                                ),
                              )
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(10),
                          child: Card(
                              child: Container(
                                padding: EdgeInsets.all(10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Similar Products",style: TextStyle(fontWeight: FontWeight.bold),),
                                    SizedBox(height: 10,),
                                    _simPro(),

                                  ],
                                ),
                              )
                          ),
                        ),
                        SizedBox(height: 50,)
                      ],
                    ),
                  )
              ),
              Positioned(
                bottom: 0,
                child: Container(
                    width: MediaQuery.of(context).size.width,
                    child: Row(
                      children: [
                        Expanded(
                          child: snapshot.data?RawMaterialButton(

                            fillColor: Color(0xff777777),
                            child: Container(
                              padding: EdgeInsets.all(15),
                              child: Text("Go To Cart",style: TextStyle(color: Colors.white)),
                            ),
                            onPressed: ()=>{_goToCart()},
                          ):RawMaterialButton(

                            fillColor: Color(0xff777777),
                            child: Container(
                              padding: EdgeInsets.all(15),
                              child: Text("Add To Cart",style: TextStyle(color: Colors.white)),
                            ),
                            onPressed: ()=>{_addToCart()},
                          ),
                        ),
                        Expanded(
                          child: RawMaterialButton(
                            fillColor: Theme.of(context).primaryColor,
                            child: Container(
                              padding: EdgeInsets.all(15),
                              child: Text("Buy Now",style: TextStyle(color: Colors.white),),
                            ),
                          ),
                        ),
                      ],
                    )),
              )
            ],
          ):Center(child: CircularProgressIndicator(),);
        },
      )
    );
  }


  Widget _sizeBoxes(Product pro){
    return SingleChildScrollView(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: _sizeBtns(),
      ),
      scrollDirection: Axis.horizontal,
    );
  }

  List<Widget> _sizeBtns(){
    List<Widget> btns=[];
    int j=1;
    values.forEach((element) {
      btns.add(
       InkWell(
         child: Container(
           margin: EdgeInsets.only(right: 10),
           padding: EdgeInsets.symmetric(horizontal: 15,vertical: 2),
           decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                border: Border.all(color:selSize==element?Colors.transparent:Colors.black45),
                color: selSize==element?Theme.of(context).primaryColor:Colors.transparent,
           ),
           child: Text(element,style: TextStyle(color: selSize==element?Colors.white:Colors.black87),),

         ),
         onTap: ()=>{
           _changeSize(element)
         },
       )
      );
      j++;
    });
    return btns;
  }

  _changeSize(String size){
    print("size="+size);
    setState(() {
      selSize=size;

    });
  }

  Widget _simPro() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 190,
      child: FutureBuilder(
          future: _fetchProducts(),
          builder: (context, snapshot) {
            print(snapshot.data);
            return snapshot.data != null ? _item(snapshot.data) : Container();
          }),
    );



  }

  Widget _item(List<Product> pros) {
    return ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: pros.length,
        itemBuilder: (context, n) {
          return InkWell(
            child: Card(
              elevation: 0,
              color: Colors.transparent,
              child: Container(
                padding: EdgeInsets.all(10),
                width: 100,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.network(
                      Config.BASEURL + "/" + pros[n].imgUrl,
                      width: 90,
                      height: 110,
                      fit: BoxFit.cover,
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      pros[n].title,
                      softWrap: true,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12),
                    ),
                    SizedBox(
                      height: 2,
                    ),
                    Text(
                      "₹ " + pros[n].price.toString(),
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor),
                    )
                  ],
                ),
              ),
            ),
            onTap: ()=>{
              Navigator.of(context).push(MaterialPageRoute(builder: (context)=>ProductScreen(product: pros[n],)))
            },
          );
        });
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

  _addToCart() async{
    SharedPreferences prefs=await SharedPreferences.getInstance();
    var res=await http.post(Uri.parse(Config.CARTURL),body: {
      'pid':product.id.toString(),
      'size':selSize,
      'uid':prefs.getInt("uid").toString()
    });
    final result=jsonDecode(res.body);
    bool success=result['success'];
    if(success){

        Toast.show("Product Added Successfully to Cart", context);
        Navigator.of(context).push(MaterialPageRoute(builder: (context)=>CartScreen()));

    }
  }

  _goToCart() async{

      Navigator.of(context).push(MaterialPageRoute(builder: (context)=>CartScreen()));


  }

  Future<bool>_checkInCart()async{
    SharedPreferences prefs=await SharedPreferences.getInstance();
    var res=await http.post(Uri.parse(Config.CHECKINCARTURL),body: {
      'pid':product.id.toString(),
      'size':selSize,
      'uid':prefs.getInt("uid").toString()
    });
    final result=jsonDecode(res.body);
    bool success=result['success'];
    if(success){
      return result['isadded'];
    }
  }


  Widget _reviewBox(){
    return Dialog(

      child: Container(
        padding: EdgeInsets.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Form(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Write a review",style: TextStyle(fontSize: 17,fontWeight: FontWeight.bold),),
                  TextFormField(
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: "Description"
                    ),
                    controller: _desccontroller,
                  ),
                  SizedBox(height: 10,),
                  RawMaterialButton(
                    fillColor: Theme.of(context).primaryColor,
                    child: Container(
                      child: Text("SUBMIT"),
                    ),
                    onPressed: ()=>{
                      _addReview()
                    },
                  )
                ],
              )
            )
          ],
        ),
      ),
    );
  }


  Future<List<Review>> _getReviews()async{
    var res = null;
    try {
      res = await http.get(Uri.parse(Config.GETREVIEWSURL+"?pid="+product.id.toString()));
    } catch (e) {
      print(e);
    }
   // print(res.statusCode);
    final jsonRes = jsonDecode(res.body);
    bool success = jsonRes['success'];
    if (success) {
      final pros = jsonRes['data'] as List;
      return pros.map<Review>((json) => Review.fromJson(json)).toList();
    }
  }

  Widget _reviewItem(List<Review> reviews){
    return ListView.builder(
      itemCount: reviews.length,

      shrinkWrap: true,
      itemBuilder: (context,n){
        return Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    child: Icon(Icons.person),
                  ),
                  SizedBox(width: 10,),
                  Text(reviews[n].user.name)
                ],
              ),
              SizedBox(height: 10,),
              Text(reviews[n].desc,style: TextStyle(fontSize: 13),),
              SizedBox(height: 10,),
              Container(height: 1,color: Colors.black12,),
              SizedBox(height: 20,)
            ],
          ),
        );
      },
    );
  }


  _addReview()async{
    SharedPreferences prefs=await SharedPreferences.getInstance();
    var response=await http.post(Uri.parse(Config.REVIEWSSURL),body: {
      'uid' : prefs.getInt("uid").toString(),
      'pid' : product.id.toString(),
      'desc':_desccontroller.text
    });
    print(response.body);
    final res=jsonDecode(response.body);
    print(res);
    if(res['success']){
      Toast.show("Review Submit Successfully", context);
      Navigator.pop(context);
    }
  }

}