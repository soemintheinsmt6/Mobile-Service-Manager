import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/object_box.dart';

// StateProvider to hold and update the ObjectBox instance
final objectBoxProvider = Provider<ObjectBox>(
  (ref) => throw UnimplementedError('ObjectBox must be overridden'),
);
