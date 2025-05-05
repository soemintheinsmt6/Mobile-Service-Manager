import 'package:mobile_service_manager/models/item.dart';
import 'package:objectbox/objectbox.dart';

@Entity()
class Brand implements Item {
  @Id()
  @override
  int id = 0; // ObjectBox will auto-increment this if it's 0

  @override
  String name;

  Brand({
    this.id = 0,
    required this.name,
  });

  // Factory constructor to create a Brand from a Map
  factory Brand.fromJson(Map<String, dynamic> json) {
    return Brand(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String,
    );
  }

  // Convert a Brand to a Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}
