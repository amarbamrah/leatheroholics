import 'package:leatheroholics/models/product.dart';

class Cart {
  int id;
  Product pro;
  String variation;

  Cart({this.id, this.pro,this.variation});

  factory Cart.fromJson(Map<String, dynamic> json) {
    print(json['product']);
    return Cart(id: json['id'],variation: json['variation'], pro: Product.fromJson(json['product']));
  }
}
