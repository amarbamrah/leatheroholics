
import 'package:leatheroholics/models/user.dart';

class Review {
  int id;
  String desc;
  User user;

  Review({this.id, this.desc,this.user});

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(id: json['id'], user: User.fromJson(json['user']),desc: json['desc']);
  }
}
