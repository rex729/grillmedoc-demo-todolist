import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../routes/app_routes.dart';

class AuthController extends GetxController {
  final FirebaseAuth? _injectedAuth;
  final GoogleSignIn? _injectedGoogleSignIn;

  AuthController({
    FirebaseAuth? auth,
    GoogleSignIn? googleSignIn,
  })  : _injectedAuth = auth,
        _injectedGoogleSignIn = googleSignIn;

  FirebaseAuth get _auth => _injectedAuth ?? FirebaseAuth.instance;
  GoogleSignIn get _googleSignIn =>
      _injectedGoogleSignIn ??
      GoogleSignIn(
        serverClientId:
            '590561728933-fjn1uljkjagqhftnbjaq62btm6q8g87k.apps.googleusercontent.com',
      );

  final isLoggedIn = false.obs;
  final userName = ''.obs;
  final userEmail = ''.obs;
  final userPhotoUrl = ''.obs;
  final idToken = ''.obs;
  final isSigningIn = false.obs;

  @override
  void onInit() {
    super.onInit();
    _checkInitialAuthState();
  }

  void _checkInitialAuthState() {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        currentUser.getIdToken().then((token) {
          if (token != null && token.isNotEmpty) {
            idToken.value = token;
            userName.value = currentUser.displayName ?? '使用者';
            userEmail.value = currentUser.email ?? '';
            userPhotoUrl.value = currentUser.photoURL ?? '';
            isLoggedIn.value = true;
          }
        });
      } else {
        isLoggedIn.value = false;
      }
    } catch (e) {
      debugPrint('[Auth] 檢查初始認證狀態: $e');
    }
  }

  /// 遵循 ADR-001: 原生 Google 登入換取 Firebase ID Token
  Future<void> signInWithGoogle() async {
    try {
      isSigningIn.value = true;

      // 1. 喚起原生 Google 帳號授權
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // 使用者取消授權流程
        return;
      }

      // 2. 獲取 Google 驗證憑證
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 3. 呼叫 Firebase Auth 進行身分鑑權
      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        // 4. 由 Firebase 官方簽發合法 JWT ID Token 作為後端無狀態鑑權憑證
        final token = await user.getIdToken();
        idToken.value = token ?? '';
        userName.value = user.displayName ?? '使用者';
        userEmail.value = user.email ?? '';
        userPhotoUrl.value = user.photoURL ?? '';
        isLoggedIn.value = true;

        if (Get.testMode != true) {
          Get.offAllNamed(AppRoutes.todo);
        }
      }
    } catch (e) {
      Get.snackbar('登入失敗', 'Google 登入發生錯誤: $e');
    } finally {
      isSigningIn.value = false;
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      debugPrint('[Auth] 登出錯誤: $e');
    }
    idToken.value = '';
    userName.value = '';
    userEmail.value = '';
    userPhotoUrl.value = '';
    isLoggedIn.value = false;
    if (Get.testMode != true) {
      Get.offAllNamed(AppRoutes.auth);
    }
  }

  Future<String?> getToken() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final token = await user.getIdToken();
        if (token != null && token.isNotEmpty) {
          idToken.value = token;
          return token;
        }
      }
    } catch (_) {}
    return idToken.value.isNotEmpty ? idToken.value : null;
  }
}
