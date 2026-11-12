import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:frontend/app/modules/auth/controllers/auth_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  Get.testMode = true;

  group('AuthController 身分驗證控制器測試', () {
    late AuthController controller;

    setUp(() {
      controller = AuthController();
    });

    test('初始狀態應為未登入且 Token 為空', () {
      expect(controller.isLoggedIn.value, false);
      expect(controller.idToken.value, isEmpty);
      expect(controller.userName.value, isEmpty);
    });

    test('signOut - 清除登入狀態與使用者資料', () async {
      controller.idToken.value = 'fake_token';
      controller.userName.value = 'Rex Chen';
      controller.userEmail.value = 'hi.chuntachen@gmail.com';
      controller.isLoggedIn.value = true;

      await controller.signOut();

      expect(controller.isLoggedIn.value, false);
      expect(controller.idToken.value, isEmpty);
      expect(controller.userName.value, isEmpty);
      expect(controller.userEmail.value, isEmpty);
    });

    test('getToken - 取得有效 Token 字串', () async {
      controller.idToken.value = 'sample_firebase_id_token';
      final token = await controller.getToken();
      expect(token, 'sample_firebase_id_token');
    });
  });
}
