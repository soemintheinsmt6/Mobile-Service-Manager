import 'dart:io';
import 'package:mobile_service_manager/models/fault.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../models/brand.dart';
import '../models/service_item.dart';
import '../models/technician.dart';
import '../objectbox.g.dart';

class ObjectBox {
  late final Store _store;
  late final Box<Brand> brandBox;
  late final Box<Technician> technicianBox;
  late final Box<Fault> faultBox;
  late final Box<ServiceItem> serviceItemBox;

  String dbPath = '';

  ObjectBox._create(this._store) {
    brandBox = Box<Brand>(_store);
    technicianBox = Box<Technician>(_store);
    faultBox = Box<Fault>(_store);
    serviceItemBox = Box<ServiceItem>(_store);
  }

  static Future<ObjectBox> create() async {
    final docsDir = await getApplicationDocumentsDirectory();
    final databaseDir = Directory(p.join(docsDir.path, "objectbox-db"));

    if (!databaseDir.existsSync()) {
      databaseDir.createSync(recursive: true);
    }

    final store = await openStore(directory: databaseDir.path);
    return ObjectBox._create(store);
  }

  /// Brand
  int insertBrand(Brand brand) => brandBox.put(brand);
  Brand? getBrand(int id) => brandBox.get(id);
  List<Brand> getAllBrands() => brandBox.getAll();
  bool deleteBrand(int id) => brandBox.remove(id);

  /// Technician
  int insertTechnician(Technician technician) => technicianBox.put(technician);
  Technician? getTechnician(int id) => technicianBox.get(id);
  List<Technician> getAllTechnicians() => technicianBox.getAll();
  bool deleteTechnician(int id) => technicianBox.remove(id);

  /// Fault
  int insertFault(Fault fault) => faultBox.put(fault);
  Fault? getFault(int id) => faultBox.get(id);
  List<Fault> getAllFaults() => faultBox.getAll();
  bool deleteFault(int id) => faultBox.remove(id);

  /// Service Item
  int insertServiceItem(ServiceItem item) => serviceItemBox.put(item);

  List<ServiceItem> getAllServiceItems() {
    return serviceItemBox
        .query(ServiceItem_.isTrash.equals(false))
        .build()
        .find();
  }

  List<ServiceItem> getTrashServiceItems() {
    return serviceItemBox
        .query(ServiceItem_.isTrash.equals(true))
        .build()
        .find();
  }

  bool deleteServiceItem(int id) => serviceItemBox.remove(id);

  void closeStore() => _store.close();
}
