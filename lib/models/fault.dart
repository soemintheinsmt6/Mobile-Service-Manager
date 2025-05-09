import 'package:mobile_service_manager/models/item.dart';
import 'package:mobile_service_manager/models/service_item.dart';
import 'package:objectbox/objectbox.dart';

@Entity()
class Fault implements Item {
  @Id()
  @override
  int id = 0;

  @override
  String name;

  final serviceItem = ToOne<ServiceItem>();

  Fault({
    this.id = 0,
    required this.name,
  });

  factory Fault.fromJson(Map<String, dynamic> json) {
    return Fault(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}
