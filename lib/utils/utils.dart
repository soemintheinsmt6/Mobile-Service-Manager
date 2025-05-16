import 'package:flutter/material.dart';

class AlwaysDisabledFocusNode extends FocusNode {
  @override
  bool get hasFocus => false;
}

final deviceStatus = ['In Progress', 'Done', 'Return'];
final deliveryStatus = ['In Store', 'Delivered'];

Color setColor(String status) {
  switch (status) {
    case 'in_progress':
    case 'In Progress':
      return Colors.grey.shade200;

    case 'return':
      return Colors.red.shade300;

    case 'done':
    case 'delivered':
      return Colors.lightGreen.shade300;
  }
  return Colors.grey.shade200;
}

String translate(String status) {
  switch (status) {
    case 'in_progress':
      return 'In Progress';

    case 'in_store':
      return 'In Store';

    case 'delivered':
      return 'Delivered';

    case 'done':
      return 'Done';

    case 'return':
      return 'Return';
  }
  return status;
}

String store(String status) {
  switch (status) {
    case 'In Progress':
      return 'in_progress';

    case 'In Store':
      return 'in_store';

    case 'Delivered':
      return 'delivered';

    case 'Done':
      return 'done';

    case 'Return':
      return 'return';
  }
  return status;
}
