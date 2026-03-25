# 📘 GUIA DEFINITIVO: PROVA DE FLUTTER (ARQUITETURA LIMPA + DIO)

## ⚠️ DICAS DE OURO ANTES DE COMEÇAR
1. **Sempre use imports relativos** dentro da pasta `lib/` (Ex: `import '../models/aluno_model.dart';`). Isso evita que o código quebre se o nome do projeto mudar.
2. Se o terminal travar, rode: `flutter clean` seguido de `flutter pub get`.
3. **Mude o Tema:** Se a prova não for sobre "Product" e sim sobre "Pet", "Carro" ou "Aluno", dê um `Ctrl + F` (ou `Cmd + F`) no VS Code e substitua a palavra `Product` pelo nome pedido. Ajuste os campos (id, name, age) conforme o JSON que o professor passar na lousa.

___________________________________________________________________

## 🚀 PASSO 1: CONFIGURAÇÃO INICIAL (pubspec.yaml)
Adicione as dependências. **Atenção:** Mantenha estas versões estáveis (LTS) para evitar breaking changes durante a prova.

```yaml
dependencies:
  flutter:
    sdk: flutter
  dio: ^5.9.2
  provider: ^6.1.5+1


## Rode flutter pub get

___________________________________________________________________

📁 PASSO 2: ESTRUTURA DE PASTAS (Obrigatório)
Crie exatamente esta árvore dentro de lib/:

lib/
 ┣ core/               -> Arquivos globais (http_client.dart)
 ┣ data/               -> Comunicação externa e JSON
 ┃ ┣ datasources/
 ┃ ┣ models/
 ┃ ┗ repositories/
 ┣ domain/             -> Regras de negócio puras (sem Flutter/Dio)
 ┃ ┣ entities/
 ┃ ┣ repositories/
 ┃ ┗ usecases/
 ┣ presentation/       -> Telas e UI
 ┃ ┣ controllers/
 ┃ ┗ pages/
 ┗ main.dart           -> Injeção de dependências e Provider

 __________________________________________________________________


🧠 PASSO 3: FLUXO DE CÓDIGO (Copie, cole e adapte)
Abaixo estão os códigos de cada arquivo, separados por camada.

___________________________________________________________________


🟢 1. CAMADA CORE (Acesso à Internet)
Local: lib/core/http_client.dart
Onde você cola a URL que o professor passar.

import 'package:dio/dio.dart';

class HttpClient {
  final Dio dio;
  HttpClient() : dio = Dio(
    BaseOptions(
      baseUrl: 'COLE_A_URL_DA_PROVA_AQUI', 
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );
}

___________________________________________________________________


🔵 2. CAMADA DOMAIN (A Regra)
👉 A. Entity
Local: lib/domain/entities/item_entity.dart
O que faz: O objeto principal. Altere as variáveis para bater com o que a prova pedir (ex: titulo, preco, nome).

class ItemEntity {
  final int id;
  final String title;

  ItemEntity({required this.id, required this.title});
}


👉 B. Repository (Interface)
Local: lib/domain/repositories/item_repository.dart
O que faz: O Contrato do que deve ser feito.

import '../entities/item_entity.dart';

abstract class ItemRepository {
  Future<List<ItemEntity>> getItems();
}


👉 C. UseCase
Local: lib/domain/usecases/get_items_usecase.dart
O que faz: A Ação do sistema.

import '../entities/item_entity.dart';
import '../repositories/item_repository.dart';

class GetItemsUseCase {
  final ItemRepository repository;
  GetItemsUseCase(this.repository);

  Future<List<ItemEntity>> call() async {
    return await repository.getItems();
  }
}

___________________________________________________________________

🟠 3. CAMADA DATA (Conversão e API)

👉 A. Model
Local: lib/data/models/item_model.dart
O que faz: Onde a mágica de ler o JSON acontece. Mude as chaves json['...'] para o formato que o professor der.

import '../../domain/entities/item_entity.dart';

class ItemModel extends ItemEntity {
  ItemModel({required int id, required String title}) : super(id: id, title: title);

  factory ItemModel.fromJson(Map<String, dynamic> json) {
    return ItemModel(
      id: json['id'],
      title: json['title'] ?? 'Sem nome', // Valor padrão caso venha nulo
    );
  }
}


👉 B. Datasource
Local: lib/data/datasources/item_remote_datasource.dart
O que faz: Onde o Dio atua. Lembre-se do try/catch exigido na avaliação.

import 'package:dio/dio.dart';
import '../models/item_model.dart';

class ItemRemoteDatasource {
  final Dio dio;
  ItemRemoteDatasource(this.dio);

  Future<List<ItemModel>> getItemsFromApi() async {
    try {
      // Se a rota for /alunos, mude aqui.
      final response = await dio.get('/rota_da_prova'); 
      final list = response.data as List;
      return list.map((item) => ItemModel.fromJson(item)).toList();
    } on DioException catch (e) {
      throw Exception('Erro na API: ${e.message}');
    }
  }
}


👉 C. Repository Impl
Local: lib/data/repositories/item_repository_impl.dart
O que faz: A implementação do contrato, chamando a API.

import '../../domain/entities/item_entity.dart';
import '../../domain/repositories/item_repository.dart';
import '../datasources/item_remote_datasource.dart';

class ItemRepositoryImpl implements ItemRepository {
  final ItemRemoteDatasource datasource;
  ItemRepositoryImpl(this.datasource);

  @override
  Future<List<ItemEntity>> getItems() async {
    return await datasource.getItemsFromApi();
  }
}

___________________________________________________________________


🟣 4. CAMADA PRESENTATION (A Tela)

👉 A. Controller
Local: lib/presentation/controllers/item_controller.dart
O que faz: O Gerenciador de Estado (avisa a tela para carregar).

import 'package:flutter/material.dart';
import '../../domain/entities/item_entity.dart';
import '../../domain/usecases/get_items_usecase.dart';

class ItemController extends ChangeNotifier {
  final GetItemsUseCase usecase;
  ItemController(this.usecase);

  List<ItemEntity> items = [];
  bool isLoading = false;
  String? error;

  Future<void> fetchItems() async {
    isLoading = true;
    error = null;
    notifyListeners(); 

    try {
      items = await usecase();
    } catch (e) {
      error = e.toString();
    }

    isLoading = false;
    notifyListeners(); 
  }
}


👉 B. Page
Local: lib/presentation/pages/item_page.dart
O que faz: A Tela que o usuário vê (desenha a lista).

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/item_controller.dart';

class ItemPage extends StatefulWidget {
  const ItemPage({Key? key}) : super(key: key);
  @override
  State<ItemPage> createState() => _ItemPageState();
}

class _ItemPageState extends State<ItemPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ItemController>().fetchItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Prova Flutter')),
      body: Consumer<ItemController>(
        builder: (context, controller, child) {
          if (controller.isLoading) return const Center(child: CircularProgressIndicator());
          if (controller.error != null) return Center(child: Text('Erro: ${controller.error}'));
          if (controller.items.isEmpty) return const Center(child: Text('Nenhum dado encontrado.'));

          return ListView.builder(
            itemCount: controller.items.length,
            itemBuilder: (context, index) {
              final item = controller.items[index];
              return ListTile(
                title: Text(item.title),
                subtitle: Text('ID: ${item.id}'),
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
O que faz: Montagem do Lego (Injeção de dependência de fora para dentro).

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/http_client.dart';
import 'data/datasources/item_remote_datasource.dart';
import 'data/repositories/item_repository_impl.dart';
import 'domain/usecases/get_items_usecase.dart';
import 'presentation/controllers/item_controller.dart';
import 'presentation/pages/item_page.dart';

void main() {
  final httpClient = HttpClient();
  final datasource = ItemRemoteDatasource(httpClient.dio);
  final repository = ItemRepositoryImpl(datasource);
  final usecase = GetItemsUseCase(repository);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ItemController(usecase)),
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
      title: 'Prova CP01',
      home: const ItemPage(),
    );
  }
}