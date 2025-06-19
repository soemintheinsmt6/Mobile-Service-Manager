import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AlwaysDisabledFocusNode extends FocusNode {
  @override
  bool get hasFocus => false;
}

final serviceStatus = ['In Progress', 'Done', 'Return', 'Free'];
final deliveryStatus = ['In Store', 'Delivered'];

Color setColor(String status) {
  switch (status) {
    case 'in_progress':
    case 'In Progress':
    case 'in_store':
    case 'In Store':
      return Colors.grey.shade200;

    case 'return':
      return Colors.red.shade300;

    case 'done':
    case 'delivered':
      return Colors.lightGreen.shade300;
  }
  return Colors.grey.shade500;
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

    case 'free':
      return 'Free';
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

    case 'Free':
      return 'free';
  }
  return status;
}

enum Date { specific, from, to }

Future<void> tempDeleteObjectBoxDatabase() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final isDeleted = prefs.getBool('isServiceItemsDeleted');

  if (isDeleted == null || isDeleted == false) {
    final docsDir = await getApplicationDocumentsDirectory();
    final objectBoxDir = Directory(p.join(docsDir.path, "objectbox-db"));

    if (await objectBoxDir.exists()) {
      await objectBoxDir.delete(recursive: true);
    }
    prefs.setBool('isServiceItemsDeleted', true);
  }
}
