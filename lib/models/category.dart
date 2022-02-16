class Category {
  int id;
  String title;
  String imgUrl;

  Category({this.id, this.title, this.imgUrl});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(id: json['id'], title: json['title']);
  }
}
