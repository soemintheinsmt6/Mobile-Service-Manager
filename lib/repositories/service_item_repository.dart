import '../database/object_box.dart';
import '../models/service_item.dart';

class ServiceItemRepository {
  final ObjectBox _objectBox;
  ServiceItemRepository(this._objectBox);

  List<ServiceItem> getAllServiceItems() => _objectBox.getAllServiceItems();
  int addServiceItem(ServiceItem item) => _objectBox.insertServiceItem(item);
  int updateServiceItem(ServiceItem item) => _objectBox.insertServiceItem(item);
  bool deleteServiceItem(int id) => _objectBox.deleteServiceItem(id);
}
