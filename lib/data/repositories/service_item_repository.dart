import '../../objectbox.g.dart';
import '../database/object_box.dart';
import '../models/brand.dart';
import '../models/fault.dart';
import '../models/service_item.dart';
import '../models/technician.dart';

class PagedResult<T> {
  final List<T> items;
  final int totalCount;

  PagedResult({
    required this.items,
    required this.totalCount,
  });
}

class ServiceItemRepository {
  final ObjectBox _objectBox;

  ServiceItemRepository(this._objectBox);

  List<ServiceItem> getAllServiceItems() {
    return _objectBox.getAllServiceItems();
  }

  List<ServiceItem> getTrashServiceItems() {
    return _objectBox.getTrashServiceItems();
  }

  List<ServiceItem> getTodayServiceItems() {
    return _objectBox.getTodayServiceItems();
  }

  PagedResult<ServiceItem> getTodayServiceItemsPaged({
    required int limit,
    required int offset,
  }) {
    final now = DateTime.now();
    final todayDateString = now.toString().split(' ')[0];

    final query = _objectBox.serviceItemBox
        .query(ServiceItem_.isTrash
            .equals(false)
            .and(ServiceItem_.issueDate.startsWith(todayDateString)))
        .build();

    final total = query.count();
    query.limit = limit;
    query.offset = offset;
    final items = query.find();
    query.close();

    return PagedResult<ServiceItem>(items: items, totalCount: total);
  }

  PagedResult<ServiceItem> getTrashServiceItemsPaged({
    required int limit,
    required int offset,
  }) {
    final query = _objectBox.serviceItemBox
        .query(ServiceItem_.isTrash.equals(true))
        .build();

    final total = query.count();
    query.limit = limit;
    query.offset = offset;
    final items = query.find();
    query.close();

    return PagedResult<ServiceItem>(items: items, totalCount: total);
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

  List<ServiceItem> searchServiceItems({
    String? invoiceId,
    String? customerName,
    String? phoneNumber,
    Brand? brand,
    Fault? fault,
    Technician? technician,
    String? deviceStatus,
    String? deliveryStatus,
    DateTime? specificDate,
    DateTime? fromDate,
    DateTime? toDate,
  }) {
    // Start with a query for non-trash items
    final query =
        _objectBox.serviceItemBox.query(ServiceItem_.isTrash.equals(false));

    // For brand relationship
    if (brand != null) {
      query.link(ServiceItem_.brand, Brand_.id.equals(brand.id));
    }

    // For technician relationship
    if (technician != null) {
      query.link(ServiceItem_.technician, Technician_.id.equals(technician.id));
    }

    // Build and execute the query to get initial results
    List<ServiceItem> results = query.build().find();

    // Filter by invoiceId
    if (invoiceId != null && invoiceId.isNotEmpty) {
      results = results.where((item) {
        // Try to match as number first, then as string if that fails
        try {
          final invoiceIdInt = int.parse(invoiceId);
          return item.invoiceId == invoiceIdInt;
        } catch (e) {
          return item.invoiceId
              .toString()
              .toLowerCase()
              .contains(invoiceId.toLowerCase());
        }
      }).toList();
    }

    // Filter by customer name
    if (customerName != null && customerName.isNotEmpty) {
      results = results
          .where((item) => item.customerName
              .toLowerCase()
              .contains(customerName.toLowerCase()))
          .toList();
    }

    // Filter by phone number
    if (phoneNumber != null && phoneNumber.isNotEmpty) {
      results = results
          .where((item) => item.phoneNumber
              .toLowerCase()
              .contains(phoneNumber.toLowerCase()))
          .toList();
    }

    // Filter by fault
    if (fault != null) {
      results = results
          .where((item) => item.faults.any((f) => f.id == fault.id))
          .toList();
    }

    // Filter by status
    if (deviceStatus != null) {
      results = results.where((item) => item.status == deviceStatus).toList();
    }

    // Filter by location
    if (deliveryStatus != null) {
      results =
          results.where((item) => item.location == deliveryStatus).toList();
    }

    // Filter by specific date
    if (specificDate != null) {
      final dateString =
          specificDate.toString().split(' ')[0]; // Get only the date part
      results = results.where((item) {
        final itemDateString =
            item.issueDate.split(' ')[0]; // Extract date part from stored item
        return itemDateString == dateString;
      }).toList();
    }

    // Filter by date range
    else if (fromDate != null && toDate != null) {
      final fromString = fromDate.toString().split(' ')[0];
      final toString = toDate.toString().split(' ')[0];

      results = results.where((item) {
        final itemDateString =
            item.issueDate.split(' ')[0]; // Extract date part from stored item
        return itemDateString.compareTo(fromString) >= 0 &&
            itemDateString.compareTo(toString) <= 0;
      }).toList();
    }

    results.sort((a, b) {
      DateTime dateA = DateTime.parse(a.issueDate);
      DateTime dateB = DateTime.parse(b.issueDate);

      int dateCompare = dateA.compareTo(dateB);
      if (dateCompare != 0) {
        return dateCompare;
      } else {
        return a.invoiceId
            .compareTo(b.invoiceId); // sort by invoiceID if dates are equal
      }
    });

    return results;
  }
}
