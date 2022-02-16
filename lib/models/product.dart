import 'package:leatheroholics/models/proimage.dart';

class Product {
  int id;
  String title, desc;
  double price;
  String imgUrl;
  String slug;
  String variation;
  List<Proimg> images;
  Product({this.id, this.title, this.price, this.desc, this.imgUrl,this.slug,this.images,this.variation});

  factory Product.fromJson(Map<String, dynamic> json) {
    if(json['images']==null){
      return Product(id: json['id'], title: json['title'],price: double.parse(json['price'].toString()), imgUrl: json['fimg'],desc: json['desc'],slug: json['slug'],variation: json['attrs']);

    }else{
      final  res = json['images'] as List;
      return Product(id: json['id'], title: json['title'],price: double.parse(json['price'].toString()), imgUrl: json['fimg'],desc: json['desc'],slug: json['slug'],variation: json['attrs'],images:res.map<Proimg>((json) => Proimg.fromJson(json)).toList());

    }
    }
}
