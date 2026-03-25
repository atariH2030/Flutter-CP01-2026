import '../../domain/entities/product_entity.dart';

class ProductModel extends ProductEntity {
  ProductModel({required int id, required String title}) 
      : super(id: id, title: title);

  // Mágica para converter o JSON da API no nosso objeto
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      title: json['title'] ?? 'Sem título',
    );
  }
}