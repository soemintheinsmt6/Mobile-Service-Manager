import '../database/object_box.dart';
import '../models/fault.dart';

class FaultRepository {
  final ObjectBox _objectBox;

  FaultRepository(this._objectBox);

  List<Fault> getAllFaults() {
    return _objectBox.getAllFaults();
  }

  int addFault(Fault fault) {
    return _objectBox.insertFault(fault);
  }

  bool deleteFault(int id) {
    return _objectBox.deleteFault(id);
  }

  int updateFault(Fault fault) {
    return _objectBox.insertFault(fault); // Put will update if ID exists
  }

  Fault? getFaultById(int id) {
    return _objectBox.getFault(id);
  }
}
