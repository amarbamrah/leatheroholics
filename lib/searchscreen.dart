import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_search_bar/flutter_search_bar.dart';
import 'package:leatheroholics/productscreen.dart';
import 'package:leatheroholics/utils/config.dart';
import 'package:http/http.dart' as http;

import 'models/product.dart';

class SearchScreen extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return SearchScreenState();
  }

}

class SearchScreenState extends State<SearchScreen>{

  SearchBar searchBar;
  bool searched=false;
  String query;

  AppBar buildAppBar(BuildContext context){
    return AppBar(
      title: Text("Search"),
      elevation: 0,
      backgroundColor: Colors.transparent,
      actions: [searchBar.getSearchAction(context)],
    );
  }

  SearchScreenState(){
    searchBar=SearchBar(setState: setState, buildDefaultAppBar: buildAppBar,inBar: false,onSubmitted: _search);
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
   

  }

  _search(String query){
    print(query+" jonty bamrah");
    setState(() {
      this.query=query;
      searched=true;
    });
  }
  @override
  Widget build(BuildContext context) {
   return Scaffold(
     appBar: searchBar.build(context),
     body: Container(
       padding: EdgeInsets.symmetric(horizontal: 10),
       child: Column(
         crossAxisAlignment: CrossAxisAlignment.start,
         children: [
           !searched?_searchScreen():
           FutureBuilder<List<Product>>(
               future: _fetchProducts(query),
               builder: (context,snapshot){
                 return snapshot.data!=null?
                 Container(
                   child: Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       SizedBox(height: 5,),
                       Text('Showing '+snapshot.data.length.toString()+' Results based on your search query "'+query+'"',style: TextStyle(fontSize: 13,color: Theme.of(context).primaryColor),),
                       SizedBox(height: 10,),
                       SingleChildScrollView(
                         child: Container(
                           padding: EdgeInsets.all(0),
                           child: _item(snapshot.data),
                         ),
                       ),
                     ],
                   ),
                 )
                 :Center(child: CircularProgressIndicator(),);
               }
           ),

         ],
       ),
     ),
   );
  }


  Future<List<Product>> _fetchProducts(String query) async {
    print(query+"yep");
    var res = null;
    try {
      res = await http.get(Uri.parse(Config.SEARCHURL+"?q="+query));
    } catch (e) {
      print(e);
    }
    print(res.statusCode);
    final jsonRes = jsonDecode(res.body);
    //print(res.body + "osm");
    bool success = jsonRes['success'];
    if (success) {
      final pros = jsonRes['data'] as List;
      return pros.map<Product>((json) => Product.fromJson(json)).toList();
    }
  }

  Widget _searchScreen(){
    return Container(
      height: MediaQuery.of(context).size.height-200,
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
           // Icon(Icons.search,color: Theme.of(context).primaryColor.withOpacity(1),size: 100,),
            SizedBox(height: 20,),
            Text("CLICK ON SEARCH ICON...")
          ],
        ),
      ),
    );
  }

  Widget _item(List<Product> pros){
    return GridView.builder(
      shrinkWrap: true,
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