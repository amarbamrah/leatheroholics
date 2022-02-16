import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:leatheroholics/cartscreen.dart';
import 'package:leatheroholics/loginscreen.dart';
import 'package:leatheroholics/models/cart.dart';
import 'package:leatheroholics/models/category.dart';
import 'package:leatheroholics/models/product.dart';
import 'package:leatheroholics/orderscreen.dart';
import 'package:leatheroholics/productlistscreen.dart';
import 'package:leatheroholics/productscreen.dart';
import 'package:leatheroholics/searchscreen.dart';
import 'package:leatheroholics/utils/config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

import 'models/user.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return HomeScreenState();
  }
}

class HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  //final AnimationController _acon =
  //  AnimationController(vsync: this, duration: Duration(seconds: 1));
  int currentTab = 0;

  double boyx = 0;
  double girlx = 0;

  String catType = "male";

  SharedPreferences prefs;
  TabController tabController;
  HomeScreenState();
  @override
  void initState() {
    _getPrefs();
    // TODO: implement initState
    super.initState();
    tabController = new TabController(length: 4, vsync: this);
  }

  _getPrefs() async {
    prefs =
        await SharedPreferences.getInstance().whenComplete(() => _refresh());
  }

  _refresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: _appBar(),
        drawer: _drawer(),
        bottomNavigationBar: ConvexAppBar(
          style: TabStyle.react,
          controller: tabController,
          items: [
            TabItem(
                icon: Icon(
              Icons.home,
              color: Colors.black,
            )),
            TabItem(
                icon: Icon(
              Icons.category,
              color: Colors.black,
            )),
            TabItem(
                icon: Icon(
              Icons.shopping_cart,
              color: Colors.black,
            )),
            TabItem(
                icon: Icon(
              Icons.person,
              color: Colors.black,
            ))
          ],
          backgroundColor: Theme.of(context).primaryColor,
          color: Colors.black87,
          activeColor: Colors.white,
          initialActiveIndex: currentTab,
          onTap: (n) {
            if (n == 2) {
              print("osm");
              if (tabController.previousIndex == 0) {
                setState(() {
                  tabController.animateTo(1);
                });
              }
              _gotoCart();
            } else {
              setState(() {
                currentTab = n;
              });
            }
          },
        ),
        body: currentTab == 0
            ? _mainScreen()
            : currentTab == 1
                ? _categories()
                : _profileScreen());
  }

  Widget _mainScreen() {
    return SingleChildScrollView(
      child: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: EdgeInsets.all(10),
              child: Text(
                "Deals of the day",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            _slideshow(),
            SizedBox(
              height: 20,
            ),
            Padding(
              padding: EdgeInsets.all(10),
              child: Text(
                "New Arrival",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 20),
              child: _newP(),
            ),
            SizedBox(
              height: 20,
            ),
            _cats(),
            SizedBox(
              height: 20,
            ),
            Padding(
              padding: EdgeInsets.all(10),
              child: Text(
                "Trending Products",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 20),
              child: _newP(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _newP() {
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

  Widget _appBar() {
    return AppBar(
      title: Image.asset(
        'assets/logo.png',
        width: 140,
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: IconThemeData(color: Theme.of(context).primaryColor),
      actions: [
        IconButton(
            icon: Icon(Icons.search),
            onPressed: () => {
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => SearchScreen()))
                })
      ],
    );
  }

  Widget _drawer() {
    return Drawer(
        child: Container(
      color: Colors.transparent,
      child: ListView(
        children: [
          DrawerHeader(
            child: Row(
              children: [
                CircleAvatar(),
                SizedBox(
                  width: 10,
                ),
                Text(prefs.getString("uname"))
              ],
            ),
          ),
          ListTile(
            title: Text("Home"),
            leading: Icon(Icons.home),
            selected: true,
          ),
          ListTile(
            title: Text("Sign out"),
            leading: Icon(Icons.exit_to_app),
            onTap: () => {_logout()},
          )
        ],
      ),
    ));
  }

  _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.setBool("login", false);
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => LoginScreen()));
    });
  }

  Widget _slideshow() {
    return CarouselSlider(items: [
      Image.asset(
        'assets/img1.jpeg',
        fit: BoxFit.cover,
      )
    ], options: CarouselOptions(aspectRatio: 16 / 7, enlargeCenterPage: true));
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
            onTap: () => {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => ProductScreen(
                        product: pros[n],
                      )))
            },
          );
        });
  }

  Widget _cats() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(10),
      height: 75,
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              child: Card(
                child: Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    Container(
                        height: 75,
                        alignment: Alignment.centerLeft,
                        decoration: BoxDecoration(color: Colors.yellow.shade50),
                        child: Padding(
                          child: Text("Bags"),
                          padding: EdgeInsets.only(left: 10),
                        )),
                    Positioned(
                      child: Image.network(
                        Config.BASEURL + "/storage\/products\/1619624011.jpg",
                        width: 45,
                      ),
                      right: 10,
                    )
                  ],
                ),
              ),
              onTap: () => {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => ProductListScreen()))
              },
            ),
          ),
          SizedBox(
            width: 10,
          ),
          Expanded(
              child: Card(
            shape: RoundedRectangleBorder(
                side: BorderSide(color: Colors.white70, width: 1),
                borderRadius: BorderRadius.circular(10)),
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                Container(
                    height: 75,
                    alignment: Alignment.centerLeft,
                    decoration: BoxDecoration(
                      color: Colors.yellow.shade50,
                    ),
                    child: Padding(
                      child: Text("Bags"),
                      padding: EdgeInsets.only(left: 10),
                    )),
                Positioned(
                  child: Image.network(
                    Config.BASEURL + "/storage\/products\/1619624011.jpg",
                    width: 45,
                  ),
                  right: 10,
                )
              ],
            ),
          )),
        ],
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

  Widget _categories() {
    return Container(
        child: Stack(
      children: [
        Container(
          height: MediaQuery.of(context).size.height,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 20,
              ),
              Text(
                catType == "male" ? "Male Wardrobe" : "Female Wardrobe",
                style: TextStyle(fontSize: 25),
              ),
              SizedBox(
                height: 20,
              ),
              Center(
                child: FutureBuilder(
                  future: _fetchCats(),
                  builder: (context, snapshot) {
                    return snapshot.data != null
                        ? _catItem(snapshot.data)
                        : CircularProgressIndicator();
                  },
                ),
              )
            ],
          ),
        ),
        Row(
          children: [
            Expanded(
                child: AnimatedContainer(
              width: MediaQuery.of(context).size.width / 2,
              transform: Matrix4.translationValues(boyx, 0, 0),
              duration: Duration(milliseconds: 220),
              child: InkWell(
                child: Stack(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width / 2,
                      decoration: BoxDecoration(
                          image: DecorationImage(
                              image: AssetImage('assets/boy.jpg'),
                              fit: BoxFit.cover)),
                    ),
                    Container(
                      decoration:
                          BoxDecoration(color: Colors.black.withOpacity(0.3)),
                    ),
                    Positioned(
                      child: Center(
                        child: Text(
                          "Boys",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 25),
                        ),
                      ),
                      left: 0,
                      top: 10,
                      right: 0,
                    )
                  ],
                ),
                onTap: () => {_openWardrobe("male")},
              ),
            )),
            Expanded(
                child: AnimatedContainer(
              width: MediaQuery.of(context).size.width / 2,
              transform: Matrix4.translationValues(girlx, 0, 0),
              duration: Duration(milliseconds: 220),
              child: InkWell(
                child: Stack(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width / 2,
                      decoration: BoxDecoration(
                          image: DecorationImage(
                              image: AssetImage('assets/girl.jpg'),
                              fit: BoxFit.cover)),
                    ),
                    Container(
                      decoration:
                          BoxDecoration(color: Colors.black.withOpacity(0.3)),
                    ),
                    Positioned(
                      child: Center(
                        child: Text(
                          "Girls",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 25),
                        ),
                      ),
                      left: 0,
                      top: 10,
                      right: 0,
                    )
                  ],
                ),
                onTap: () => {_openWardrobe("female")},
              ),
            ))
          ],
        ),
      ],
    ));
  }

  _openWardrobe(String type) {
    setState(() {
      catType = type;
      if (boyx == 0) {
        boyx = -150;
        girlx = 150;
      } else {
        boyx = 0;
        girlx = 0;
      }
    });
  }

  Future<List<Category>> _fetchCats() async {
    print("yep");
    var res = null;
    try {
      res = await http.get(Uri.parse(Config.CATURL));
    } catch (e) {
      print(e);
    }
    print(res.statusCode);
    final jsonRes = jsonDecode(res.body);
    print(res.body + "osm");
    bool success = jsonRes['success'];
    if (success) {
      final pros = jsonRes['data'] as List;
      return pros.map<Category>((json) => Category.fromJson(json)).toList();
    }
  }

  Widget _catItem(List<Category> cats) {
    print(cats[0].title);
    return ListView.builder(
      shrinkWrap: true,
      itemCount: cats.length,
      itemBuilder: (context, n) {
        return Container(

          padding: EdgeInsets.symmetric(vertical: 10),
          child: Container(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.navigate_next,color: Theme.of(context).primaryColor,),
                    SizedBox(width: 1,),
                    Text(cats[n].title),
                  ],
                )

          )
        );
      },
    );
  }

  _gotoCart() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => CartScreen()))
        .then((value) => _goBack());
  }

  _goBack() {
    setState(() {
      print("changing" + currentTab.toString());
      setState(() {
        tabController.animateTo(currentTab);
      });
    });
  }

  Widget _profileScreen() {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(20),
        width: MediaQuery.of(context).size.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 20,
            ),
            CircleAvatar(
                radius: 60, backgroundImage: AssetImage("assets/boy.jpg")),
            SizedBox(
              height: 5,
            ),
            Text(
              prefs.getString("uname"),
              style: TextStyle(fontSize: 17),
            ),
            Text(prefs.getString("umail")),
            SizedBox(
              height: 30,
            ),
            InkWell(
              onTap: ()=>{Navigator.of(context).push(MaterialPageRoute(builder: (context)=>OrderScreen()))},
              child: Card(
                  child: Container(
                      padding: EdgeInsets.all(10),
                      child: Row(
                        children: [
                          Icon(Icons.reorder),
                          SizedBox(
                            width: 20,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "My Orders",
                                  style: TextStyle(fontSize: 17),
                                ),
                                Text(
                                  "See your orders",
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.black54),
                                )
                              ],
                            ),
                          ),
                          Icon(
                            Icons.arrow_right,
                            color: Theme.of(context).primaryColor,
                          ),
                        ],
                      ))),
            ),
            SizedBox(
              height: 5,
            ),
            Card(
                child: Container(
                    padding: EdgeInsets.all(10),
                    child: Row(
                      children: [
                        Icon(Icons.lock),
                        SizedBox(
                          width: 20,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Change Password",
                                style: TextStyle(fontSize: 17),
                              ),
                              Text(
                                "Change your password",
                                style: TextStyle(
                                    fontSize: 12, color: Colors.black54),
                              )
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_right,
                          color: Theme.of(context).primaryColor,
                        ),
                      ],
                    ))),
            SizedBox(
              height: 5,
            ),
            Card(
                child: Container(
                    padding: EdgeInsets.all(10),
                    child: Row(
                      children: [
                        Icon(Icons.question_answer),
                        SizedBox(
                          width: 20,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "FAQ",
                                style: TextStyle(fontSize: 17),
                              ),
                              Text(
                                "Frequently Asked Questions",
                                style: TextStyle(
                                    fontSize: 12, color: Colors.black54),
                              )
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_right,
                          color: Theme.of(context).primaryColor,
                        ),
                      ],
                    ))),
            SizedBox(
              height: 30,
            ),
            Text("Member Since 6 Nov 2020")
          ],
        ),
      ),
    );
  }
}
