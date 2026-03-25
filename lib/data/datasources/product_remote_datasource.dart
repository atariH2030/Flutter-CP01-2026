import 'package:dio/dio.dart';
import '../models/product_model.dart';

class ProductRemoteDatasource {
  final Dio dio;

  ProductRemoteDatasource(this.dio);

  Future<List<ProductModel>> getProductsFromApi() async {
    try {
      final response = await dio.get('https://sua-api.com/products');
      
      // Converte a lista recebida em uma lista de ProductModel
      final list = response.data as List;
      return list.map((item) => ProductModel.fromJson(item)).toList();
      
    } on DioException catch (e) {
      throw Exception('Erro na API: ${e.message}');
    }
  }
}