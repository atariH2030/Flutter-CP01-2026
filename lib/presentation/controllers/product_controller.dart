import 'package:flutter/material.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/usecases/get_product_usecase.dart';

class ProductController extends ChangeNotifier {
  final GetProductUseCase usecase;

  ProductController(this.usecase);

  List<ProductEntity> products = [];
  bool isLoading = false;
  String? error;

  Future<void> fetchProducts() async {
    isLoading = true;
    error = null;
    notifyListeners(); // Avisa a tela para mostrar o "loading"

    try {
      products = await usecase();
    } catch (e) {
      error = e.toString();
    }

    isLoading = false;
    notifyListeners(); // Avisa a tela para atualizar com os dados ou o erro
  }
}