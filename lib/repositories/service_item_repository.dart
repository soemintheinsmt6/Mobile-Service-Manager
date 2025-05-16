import '../database/object_box.dart';
import '../models/service_item.dart';

class ServiceItemRepository {
  final ObjectBox _objectBox;
  ServiceItemRepository(this._objectBox);

  List<ServiceItem> getAllServiceItems() {
    List<ServiceItem> allItems = _objectBox.getAllServiceItems();
    return allItems.where((item) => !item.isTrash).toList();
  }

  List<ServiceItem> getTrashServiceItems() {
    List<ServiceItem> allItems = _objectBox.getTrashServiceItems();
    return allItems.where((item) => item.isTrash).toList();
  }

  int addServiceItem(ServiceItem item) => _objectBox.insertServiceItem(item);
  int updateServiceItem(ServiceItem item) => _objectBox.insertServiceItem(item);

  bool deleteServiceItem(int id) {
    // Instead of actual deletion, mark as trash
    final item = _objectBox.serviceItemBox.get(id);
    if (item != null) {
      item.isTrash = true;
      _objectBox.insertServiceItem(item);
      return true;
    }
    return false;
  }

  bool permanentlyDeleteServiceItem(int id) {
    // For when you really want to delete
    return _objectBox.deleteServiceItem(id);
  }

  bool restoreServiceItem(int id) {
    // Restore from trash
    final item = _objectBox.serviceItemBox.get(id);
    if (item != null && item.isTrash) {
      item.isTrash = false;
      _objectBox.insertServiceItem(item);
      return true;
    }
    return false;
  }
}
