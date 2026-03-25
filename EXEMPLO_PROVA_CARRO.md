# 🚗 EXEMPLO REAL: PROVA DE FLUTTER (TEMA CARRO)

> **CENÁRIO DA PROVA SIMULADO:**
> **Tema:** Catálogo de Carros
> **API (Base URL):** `https://api-prova-fiap.com.br/v1`
> **Endpoint:** GET `/carros`
> **Campos do JSON:** `id` (int), `modelo` (String), `marca` (String), `ano` (int).

---

## 🚀 PASSO 1: CONFIGURAÇÃO INICIAL (pubspec.yaml)
Adicione as dependências e rode `flutter pub get`.

```yaml
dependencies:
  flutter:
    sdk: flutter
  dio: ^5.9.2
  provider: ^6.1.5+1


  _________________________________________________________________


  📁 PASSO 2: ESTRUTURA DE PASTAS (lib/)

  lib/
 ┣ core/               
 ┣ data/               
 ┃ ┣ datasources/
 ┃ ┣ models/
 ┃ ┗ repositories/
 ┣ domain/             
 ┃ ┣ entities/
 ┃ ┣ repositories/
 ┃ ┗ usecases/
 ┣ presentation/       
 ┃ ┣ controllers/
 ┃ ┗ pages/
 ┗ main.dart


 __________________________________________________________________


 🧠 PASSO 3: FLUXO DE CÓDIGO (APLICADO AO TEMA "CARRO")

🟢 1. CAMADA CORE (Acesso à Internet)
Local: lib/core/http_client.dart
A URL base mudou para a da prova.

import 'package:dio/dio.dart';

class HttpClient {
  final Dio dio;
  HttpClient() : dio = Dio(
    BaseOptions(
      baseUrl: '[https://api-prova-fiap.com.br/v1](https://api-prova-fiap.com.br/v1)', // URL DA PROVA AQUI
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );
}

___________________________________________________________________


🔵 2. CAMADA DOMAIN (A Regra de Negócio)

👉 A. Entity
Local: lib/domain/entities/carro_entity.dart
Criamos os atributos exatos que o professor pediu no JSON.

class CarroEntity {
  final int id;
  final String modelo;
  final String marca;
  final int ano;

  CarroEntity({
    required this.id, 
    required this.modelo, 
    required this.marca, 
    required this.ano,
  });
}


👉 B. Repository (Interface)
Local: lib/domain/repositories/carro_repository.dart
O contrato devolve uma lista de Carros.

import '../entities/carro_entity.dart';

abstract class CarroRepository {
  Future<List<CarroEntity>> getCarros();
}


👉 C. UseCase
Local: lib/domain/usecases/get_carros_usecase.dart

import '../entities/carro_entity.dart';
import '../repositories/carro_repository.dart';

class GetCarrosUseCase {
  final CarroRepository repository;
  GetCarrosUseCase(this.repository);

  Future<List<CarroEntity>> call() async {
    return await repository.getCarros();
  }
}


___________________________________________________________________


🟠 3. CAMADA DATA (Conversão e API)

👉 A. Model
Local: lib/data/models/carro_model.dart
Mapeando as chaves JSON exatas da prova.

import '../../domain/entities/carro_entity.dart';

class CarroModel extends CarroEntity {
  CarroModel({
    required int id, 
    required String modelo, 
    required String marca, 
    required int ano,
  }) : super(id: id, modelo: modelo, marca: marca, ano: ano);

  factory CarroModel.fromJson(Map<String, dynamic> json) {
    return CarroModel(
      id: json['id'],
      modelo: json['modelo'] ?? 'Modelo Desconhecido',
      marca: json['marca'] ?? 'Marca Desconhecida',
      ano: json['ano'] ?? 0,
    );
  }
}


👉 B. Datasource
Local: lib/data/datasources/carro_remote_datasource.dart
O endpoint da prova (/carros) entra aqui no dio.get.

import 'package:dio/dio.dart';
import '../models/carro_model.dart';

class CarroRemoteDatasource {
  final Dio dio;
  CarroRemoteDatasource(this.dio);

  Future<List<CarroModel>> getCarrosFromApi() async {
    try {
      final response = await dio.get('/carros'); // ROTA DA PROVA AQUI
      final list = response.data as List;
      return list.map((item) => CarroModel.fromJson(item)).toList();
    } on DioException catch (e) {
      throw Exception('Erro na API: ${e.message}');
    }
  }
}


👉 C. Repository Impl
Local: lib/data/repositories/carro_repository_impl.dart

import '../../domain/entities/carro_entity.dart';
import '../../domain/repositories/carro_repository.dart';
import '../datasources/carro_remote_datasource.dart';

class CarroRepositoryImpl implements CarroRepository {
  final CarroRemoteDatasource datasource;
  CarroRepositoryImpl(this.datasource);

  @override
  Future<List<CarroEntity>> getCarros() async {
    return await datasource.getCarrosFromApi();
  }
}


___________________________________________________________________


🟣 4. CAMADA PRESENTATION (A Tela)

👉 A. Controller
Local: lib/presentation/controllers/carro_controller.dart

import 'package:flutter/material.dart';
import '../../domain/entities/carro_entity.dart';
import '../../domain/usecases/get_carros_usecase.dart';

class CarroController extends ChangeNotifier {
  final GetCarrosUseCase usecase;
  CarroController(this.usecase);

  List<CarroEntity> carros = [];
  bool isLoading = false;
  String? error;

  Future<void> fetchCarros() async {
    isLoading = true;
    error = null;
    notifyListeners(); 

    try {
      carros = await usecase();
    } catch (e) {
      error = e.toString();
    }

    isLoading = false;
    notifyListeners(); 
  }
}


👉 B. Page
Local: lib/presentation/pages/carro_page.dart
A tela agora exibe marca, modelo e ano.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/carro_controller.dart';

class CarroPage extends StatefulWidget {
  const CarroPage({Key? key}) : super(key: key);
  @override
  State<CarroPage> createState() => _CarroPageState();
}

class _CarroPageState extends State<CarroPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CarroController>().fetchCarros();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Catálogo de Carros')),
      body: Consumer<CarroController>(
        builder: (context, controller, child) {
          if (controller.isLoading) return const Center(child: CircularProgressIndicator());
          if (controller.error != null) return Center(child: Text('Erro: ${controller.error}'));
          if (controller.carros.isEmpty) return const Center(child: Text('Nenhum carro encontrado.'));

          return ListView.builder(
            itemCount: controller.carros.length,
            itemBuilder: (context, index) {
              final carro = controller.carros[index];
              return ListTile(
                leading: const Icon(Icons.directions_car),
                title: Text('${carro.marca} ${carro.modelo}'), // Ex: Toyota Corolla
                subtitle: Text('Ano: ${carro.ano}'),
              );
            },
          );
        },
      ),
    );
  }
}


___________________________________________________________________

🔴 5. O MAIN (Ponto de Partida)
Local: lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/http_client.dart';
import 'data/datasources/carro_remote_datasource.dart';
import 'data/repositories/carro_repository_impl.dart';
import 'domain/usecases/get_carros_usecase.dart';
import 'presentation/controllers/carro_controller.dart';
import 'presentation/pages/carro_page.dart';

void main() {
  final httpClient = HttpClient();
  final datasource = CarroRemoteDatasource(httpClient.dio);
  final repository = CarroRepositoryImpl(datasource);
  final usecase = GetCarrosUseCase(repository);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CarroController(usecase)),
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
      title: 'Prova CP01 - Carros',
      home: const CarroPage(),
    );
  }
}


FINAL: RODE COM "flutter run"