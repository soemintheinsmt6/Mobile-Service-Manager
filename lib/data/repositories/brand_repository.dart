import '../database/object_box.dart';
import '../models/brand.dart';

class BrandRepository {
  final ObjectBox _objectBox;

  BrandRepository(this._objectBox);

  // Get all brands
  List<Brand> getAllBrands() {
    return _objectBox.getAllBrands();
  }

  // Add a new brand
  int addBrand(Brand brand) {
    return _objectBox.insertBrand(brand);
  }

  // Delete a brand
  bool deleteBrand(int id) {
    return _objectBox.deleteBrand(id);
  }

  // Update a brand
  int updateBrand(Brand brand) {
    return _objectBox.insertBrand(brand); // Put will update if ID exists
  }

  // Get a brand by ID
  Brand? getBrandById(int id) {
    return _objectBox.getBrand(id);
  }
}
