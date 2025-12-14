// File 2: /lib/app/modules/auth/login/controllers/login_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../services/auth_service.dart';

class LoginController extends GetxController {
  // Text Controllers
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // Observable
  final isPasswordHidden = true.obs;
  final isLoading = false.obs;

  @override
  void onClose() {
    fullNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  // Toggle Password Visibility
  void togglePasswordVisibility() {
    isPasswordHidden.toggle();
  }

  // Login Method
  Future<void> login() async {
    final fullName = fullNameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    // Validation
    if (fullName.isEmpty || email.isEmpty || password.isEmpty) {
      Get.snackbar(
        'Error',
        'All fields are required',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (!email.contains('@')) {
      Get.snackbar(
        'Error',
        'Please enter a valid email',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (password.length < 6) {
      Get.snackbar(
        'Error',
        'Password must be at least 6 characters',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;
    final auth = Get.find<AuthService>();
    try {
      final ok = await auth.login(email, password);
      if (ok) {
        Get.snackbar(
          'Success',
          'Login Successful!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        // Navigate to homepage on success
        Get.offAllNamed('/homepage');
      } else {
        Get.snackbar(
          'Error',
          'Invalid credentials. Please check your email or password.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      // Show friendly error on exceptions (e.g., 401/422)
      Get.snackbar(
        'Error',
        'Invalid credentials. Please check your email or password.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Google Login
  void loginWithGoogle() {
    // TODO: Implement Google login
    Get.snackbar('Info', 'Google login not implemented yet');
  }

  // LinkedIn Login
  void loginWithLinkedIn() {
    // TODO: Implement LinkedIn login
    Get.snackbar('Info', 'LinkedIn login not implemented yet');
  }

  // Twitter Login
  void loginWithTwitter() {
    // TODO: Implement Twitter login
    Get.snackbar('Info', 'Twitter login not implemented yet');
  }

  // Go to Sign Up Page
  void goToSignUp() {
    // TODO: Navigate to signup page
    // Get.toNamed(Routes.SIGN_UP);
    Get.snackbar('Info', 'Navigate to Sign Up page');
  }

  // Go to Forgot Password
  void goToForgotPassword() {
    // TODO: Navigate to forgot password page
    // Get.toNamed(Routes.FORGOT_PASSWORD);
    Get.snackbar('Info', 'Navigate to Forgot Password page');
  }
}
