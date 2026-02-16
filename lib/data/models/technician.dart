import 'package:objectbox/objectbox.dart';

import 'item.dart';

@Entity()
class Technician implements Item {
  @Id()
  @override
  int id = 0; // ObjectBox will auto-increment this if it's 0

  @override
  String name;

  Technician({
    this.id = 0,
    required this.name,
  });

  // Factory constructor to create a Technician from a Map
  factory Technician.fromJson(Map<String, dynamic> json) {
    return Technician(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String,
    );
  }

  // Convert a Technician to a Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}
