import 'package:get/get.dart';
import '../modules/auth/bindings/auth_binding.dart';
import '../modules/auth/views/auth_view.dart';
import '../modules/todo/bindings/todo_binding.dart';
import '../modules/todo/views/todo_view.dart';
import 'app_routes.dart';

class AppPages {
  static const initial = AppRoutes.auth;

  static final routes = [
    GetPage(
      name: AppRoutes.auth,
      page: () => const AuthView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.todo,
      page: () => const TodoView(),
      binding: TodoBinding(),
    ),
  ];
}
