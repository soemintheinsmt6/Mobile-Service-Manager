import 'package:intl/intl.dart';

extension DateFormatter on String {
  String get formattedDate {
    try {
      DateTime dateTime = DateTime.parse(this);
      return DateFormat('d MMM yyyy').format(dateTime);
    } catch (e) {
      return this;
    }
  }
}
