import '../database/object_box.dart';
import '../models/service_item.dart';

class ServiceItemRepository {
  final ObjectBox objectBox;
  ServiceItemRepository(this.objectBox);

  List<ServiceItem> getAllItems() => objectBox.getAllServiceItems();
  int addItem(ServiceItem item) => objectBox.insertServiceItem(item);
  bool deleteItem(int id) => objectBox.deleteServiceItem(id);
}
