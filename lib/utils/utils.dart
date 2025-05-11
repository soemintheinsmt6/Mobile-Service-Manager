import 'package:flutter/material.dart';

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
