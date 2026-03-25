import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/product_controller.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({Key? key}) : super(key: key);

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  @override
  void initState() {
    super.initState();
    // Assim que a tela abrir, pede para buscar os dados
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductController>().fetchProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Produtos')),
      // O Consumer "escuta" o ProductController
      body: Consumer<ProductController>(
        builder: (context, controller, child) {
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (controller.error != null) {
            return Center(child: Text('Erro: ${controller.error}'));
          }
          if (controller.products.isEmpty) {
            return const Center(child: Text('Nenhum produto encontrado.'));
          }

          return ListView.builder(
            itemCount: controller.products.length,
            itemBuilder: (context, index) {
              final product = controller.products[index];
              return ListTile(
                title: Text(product.title),
                subtitle: Text('ID: ${product.id}'),
              );
            },
          );
        },
      ),
    );
  }
}