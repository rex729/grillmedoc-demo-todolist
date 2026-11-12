part of 'todo_api_service.dart';

// **************************************************************************
// RetrofitGenerator
// **************************************************************************

class _TodoApiService implements TodoApiService {
  _TodoApiService(this._dio, {this.baseUrl});

  final Dio _dio;
  String? baseUrl;

  @override
  Future<List<TodoDto>> getTodos() async {
    final response = await _dio.get(
      '/api/v1/todos',
      options: Options(responseType: ResponseType.json),
    );
    final list = response.data as List<dynamic>;
    return list.map((e) => TodoDto.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<TodoDto> createTodo(Map<String, dynamic> body) async {
    final response = await _dio.post(
      '/api/v1/todos',
      data: body,
      options: Options(responseType: ResponseType.json),
    );
    return TodoDto.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<TodoDto> updateTodo(String id, Map<String, dynamic> body) async {
    final response = await _dio.put(
      '/api/v1/todos/$id',
      data: body,
      options: Options(responseType: ResponseType.json),
    );
    return TodoDto.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<Map<String, dynamic>> deleteTodo(String id) async {
    final response = await _dio.delete(
      '/api/v1/todos/$id',
      options: Options(responseType: ResponseType.json),
    );
    return response.data as Map<String, dynamic>;
  }
}
