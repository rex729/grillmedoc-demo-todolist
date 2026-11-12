import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../dtos/todo_dto.dart';

part 'todo_api_service.g.dart';

@RestApi()
abstract class TodoApiService {
  factory TodoApiService(Dio dio, {String baseUrl}) = _TodoApiService;

  @GET('/api/v1/todos')
  Future<List<TodoDto>> getTodos();

  @POST('/api/v1/todos')
  Future<TodoDto> createTodo(@Body() Map<String, dynamic> body);

  @PUT('/api/v1/todos/{id}')
  Future<TodoDto> updateTodo(
    @Path('id') String id,
    @Body() Map<String, dynamic> body,
  );

  @DELETE('/api/v1/todos/{id}')
  Future<Map<String, dynamic>> deleteTodo(@Path('id') String id);
}
