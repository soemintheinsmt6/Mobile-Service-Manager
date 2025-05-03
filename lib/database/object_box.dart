import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../models/brand.dart';
import '../models/technician.dart';
import '../objectbox.g.dart';

class ObjectBox {
  late final Store _store;
  late final Box<Brand> brandBox;
  late final Box<Technician> technicianBox;

  String dbPath = '';

  ObjectBox._create(this._store) {
    brandBox = Box<Brand>(_store);
    technicianBox = Box<Technician>(_store);
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

  int insertBrand(Brand brand) => brandBox.put(brand);
  Brand? getBrand(int id) => brandBox.get(id);
  List<Brand> getAllBrands() => brandBox.getAll();
  bool deleteBrand(int id) => brandBox.remove(id);

  int insertTechnician(Technician technician) => technicianBox.put(technician);
  Technician? getTechnician(int id) => technicianBox.get(id);
  List<Technician> getAllTechnicians() => technicianBox.getAll();
  bool deleteTechnician(int id) => technicianBox.remove(id);

  void closeStore() => _store.close();
}
