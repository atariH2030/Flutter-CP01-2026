import 'package:dio/dio.dart';

class HttpClient {
  final Dio dio;

  HttpClient() : dio = Dio(
    BaseOptions(
      baseUrl: 'https://api-que-o-professor-passar.com/', // A URL principal da prova vai aqui
      connectTimeout: const Duration(seconds: 10), // Tempo máximo tentando conectar
      receiveTimeout: const Duration(seconds: 10), // Tempo máximo esperando a resposta
      headers: {
        'Content-Type': 'application/json',
      },
    ),
  );

  // Se o professor pedir para adicionar algum Token de autenticação (Interceptors),
  // é neste arquivo que você faria isso!
}