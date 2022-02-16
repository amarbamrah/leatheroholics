class Coupan {
  int id;
  String coupan;
  String type;
  double amount;

  Coupan({this.id, this.coupan,this.type,this.amount});

  factory Coupan.fromJson(Map<String, dynamic> json) {
    return Coupan(id: json['id'], coupan: json['title'],type: json['type'],amount: double.parse(json['amount'].toString()));
  }
}
