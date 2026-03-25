import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';

import 'data/datasources/product_remote_datasource.dart';
import 'data/repositories/product_repository_impl.dart';
import 'domain/usecases/get_product_usecase.dart';
import 'presentation/controllers/product_controller.dart';
import 'presentation/pages/product_page.dart';

void main() {
  // 1. Instanciar o Dio
  final dio = Dio();
  
  // 2. Instanciar as camadas (de fora para dentro)
  final datasource = ProductRemoteDatasource(dio);
  final repository = ProductRepositoryImpl(datasource);
  final usecase = GetProductUseCase(repository);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ProductController(usecase),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Prova Flutter',
      home: const ProductPage(),
    );
  }
}