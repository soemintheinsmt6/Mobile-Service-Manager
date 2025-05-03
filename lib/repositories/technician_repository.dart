import '../database/object_box.dart';
import '../models/technician.dart';

class TechnicianRepository {
  final ObjectBox _objectBox;

  TechnicianRepository(this._objectBox);

  // Get all technicians
  List<Technician> getAllTechnicians() {
    return _objectBox.getAllTechnicians();
  }

  // Add a new technician
  int addTechnician(Technician technician) {
    return _objectBox.insertTechnician(technician);
  }

  // Delete a technician
  bool deleteTechnician(int id) {
    return _objectBox.deleteTechnician(id);
  }

  // Update a technician
  int updateTechnician(Technician technician) {
    return _objectBox
        .insertTechnician(technician); // Put will update if ID exists
  }

  // Get a technician by ID
  Technician? getTechnicianById(int id) {
    return _objectBox.getTechnician(id);
  }
}
