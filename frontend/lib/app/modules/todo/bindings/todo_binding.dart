import 'package:get/get.dart';
import '../../../data/services/api_client.dart';
import '../../../data/services/todo_api_service.dart';
import '../../auth/controllers/auth_controller.dart';
import '../controllers/todo_controller.dart';

class TodoBinding extends Bindings {
  @override
  void dependencies() {
    final authController = Get.find<AuthController>();
    final dio = ApiClient.createDio(
      tokenProvider: () => authController.getToken(),
    );

    Get.lazyPut<TodoApiService>(() => TodoApiService(dio));
    Get.lazyPut<TodoController>(
      () => TodoController(apiService: Get.find<TodoApiService>()),
    );
  }
}
