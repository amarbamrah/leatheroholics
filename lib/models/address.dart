

class Address {
  int id;
  String aline1,aline2,city,state,picode,label;


  Address({this.id, this.aline1,this.aline2,this.city,this.picode,this.state,this.label});

  factory Address.fromJson(Map<String, dynamic> json) {
    print(json['product']);
    return Address(
        id: json['id'],
        aline1: json['aline1'],
      aline2: json['aline2'],
      state: json['State'],
      city: json['city'],
      picode: json['pincode'],
      label: json['label']
    );
  }
}
