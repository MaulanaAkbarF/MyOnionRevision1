
class TimePenyiramanModel {
  String waktu;
  bool active;

  TimePenyiramanModel({
    required this.waktu,
    required this.active,
  });

  Map<String, dynamic> toMap() {
    return {
      'waktu': waktu,
      'active': active,
    };
  }

  factory TimePenyiramanModel.fromMap(Map<String, dynamic> map) {
    return TimePenyiramanModel(
      waktu: map['waktu'],
      active: map['active'],
    );
  }
}
