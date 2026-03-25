import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_remote_datasource.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDatasource datasource;

  ProductRepositoryImpl(this.datasource);

  @override
  Future<List<ProductEntity>> getProducts() async {
    // Retorna a lista recebida do datasource
    return await datasource.getProductsFromApi();
  }
}