import 'package:mobile_service_manager/data/models/technician.dart';
import 'package:objectbox/objectbox.dart';

import 'brand.dart';
import 'fault.dart';

@Entity()
class ServiceItem {
  @Id()
  int id;

  int invoiceId;
  String customerName;
  String phoneNumber;

  final brand = ToOne<Brand>();
  String model;
  String imei;
  String issueDate;
  String? deliveryDate;

  final faults = ToMany<Fault>();

  final technician = ToOne<Technician>();

  int? expense;
  int? servicePrice;
  bool simIncluded;
  bool sdIncluded;
  String? remark;

  String status;
  String location;

  String get simAndSd {
    if (!simIncluded && !sdIncluded) {
      return 'N/A';
    } else if (simIncluded && sdIncluded) {
      return 'SIM & SD';
    } else if (simIncluded) {
      return 'SIM';
    } else {
      return 'SD';
    }
  }

  @Index()
  bool isTrash;

  ServiceItem({
    this.id = 0,
    required this.invoiceId,
    required this.customerName,
    required this.phoneNumber,
    required this.model,
    required this.imei,
    required this.issueDate,
    this.deliveryDate,
    this.expense,
    this.servicePrice,
    this.simIncluded = false,
    this.sdIncluded = false,
    this.remark,
    this.status = 'in_progress',
    this.location = 'in_store',
    this.isTrash = false,
  });

  void setFaults(List<Fault> newFaults) {
    faults.clear();
    faults.addAll(newFaults);
  }
}

extension ServiceItemJson on ServiceItem {
  Map<String, dynamic> toJson() => {
        'id': id,
        'invoiceId': invoiceId,
        'customerName': customerName,
        'phoneNumber': phoneNumber,
        'brandId': brand.target?.id,
        'model': model,
        'imei': imei,
        'issueDate': issueDate,
        'deliveryDate': deliveryDate,
        'faultIds': faults.map((f) => f.id).toList(),
        'technicianId': technician.target?.id,
        'expense': expense,
        'servicePrice': servicePrice,
        'simIncluded': simIncluded,
        'sdIncluded': sdIncluded,
        'remark': remark,
        'status': status,
        'location': location,
        'isTrash': isTrash,
      };
}
