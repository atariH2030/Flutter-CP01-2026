import '../entities/product_entity.dart';
import '../repositories/product_repository.dart';

class GetProductUseCase {
  final ProductRepository repository;

  GetProductUseCase(this.repository);

  Future<List<ProductEntity>> call() async {
    return await repository.getProducts();
  }
}