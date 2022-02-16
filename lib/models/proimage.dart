class Proimg {
  int id;
  String imgurl;

  Proimg({this.id, this.imgurl});

  factory Proimg.fromJson(Map<String, dynamic> json) {

    return Proimg(id: json['id'], imgurl: json['imgurl']);
  }
}
