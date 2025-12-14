// File 1: /lib/app/modules/auth/register/controllers/register_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../services/auth_service.dart';

class RegisterController extends GetxController {
  // Text Controllers
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final fakultasProdiController = TextEditingController();

  // Observable
  final isPasswordHidden = true.obs;
  final isConfirmPasswordHidden = true.obs;
  final isLoading = false.obs;

  @override
  void onClose() {
    fullNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    fakultasProdiController.dispose();
    super.onClose();
  }

  // Toggle Password Visibility
  void togglePasswordVisibility() {
    isPasswordHidden.toggle();
  }

  // Toggle Confirm Password Visibility
  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordHidden.toggle();
  }

  // Register Method
  Future<void> register() async {
    final fullName = fullNameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();
    final fakultasProdi = fakultasProdiController.text.trim();

    // Validation
    if (fullName.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty ||
        fakultasProdi.isEmpty) {
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

    if (password != confirmPassword) {
      Get.snackbar(
        'Error',
        'Passwords do not match',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;
    final auth = Get.find<AuthService>();
    try {
      final ok = await auth.register({
        'name': fullName,
        'email': email,
        'password': password,
        'password_confirmation': confirmPassword,
        'fakultas_prodi': fakultasProdi,
      });
      if (ok) {
        Get.snackbar(
          'Success',
          'Registration Successful! Please login',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        // Navigate to login page after successful registration
        Get.offAllNamed('/login');
      } else {
        Get.snackbar(
          'Error',
          'Registrasi gagal. Coba lagi.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Google Registration
  void registerWithGoogle() {
    // TODO: Implement Google registration
    Get.snackbar('Info', 'Google registration not implemented yet');
  }

  // LinkedIn Registration
  void registerWithLinkedIn() {
    // TODO: Implement LinkedIn registration
    Get.snackbar('Info', 'LinkedIn registration not implemented yet');
  }

  // Twitter Registration
  void registerWithTwitter() {
    // TODO: Implement Twitter registration
    Get.snackbar('Info', 'Twitter registration not implemented yet');
  }

  // Go to Login Page
  void goToLogin() {
    // TODO: Navigate to login page
    // Get.toNamed(Routes.LOGIN);
    Get.snackbar('Info', 'Navigate to Login page');
  }
}
