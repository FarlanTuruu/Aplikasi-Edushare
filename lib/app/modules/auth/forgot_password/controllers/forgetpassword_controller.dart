// File 1: /lib/app/modules/auth/forgot_password/controllers/forget_password_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ForgetPasswordController extends GetxController {
  // Text Controllers
  final emailController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmNewPasswordController = TextEditingController();

  // Observable
  final isResetStep =
      false.obs; // false = forgot password, true = reset password
  final isNewPasswordHidden = true.obs;
  final isConfirmNewPasswordHidden = true.obs;
  final isLoading = false.obs;



  @override
  void onClose() {
    emailController.dispose();
    newPasswordController.dispose();
    confirmNewPasswordController.dispose();
    super.onClose();
  }

  // ============= FORGOT PASSWORD SCREEN =============

  // Send Reset Email
  void sendResetEmail() {
    final email = emailController.text.trim();

    // Validation
    if (email.isEmpty) {
      Get.snackbar(
        'Error',
        'Email is required',
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

    isLoading.value = true;

    // TODO: Implement actual API call to send reset email
    // Example:
    // try {
    //   await authService.sendResetPasswordEmail(email);
    //   isResetStep.value = true;
    // } catch (e) {
    //   Get.snackbar('Error', e.toString());
    // } finally {
    //   isLoading.value = false;
    // }

    Future.delayed(const Duration(seconds: 2), () {
      isLoading.value = false;
      Get.snackbar(
        'Success',
        'Reset email sent! Check your inbox.',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      // Move to reset password screen
      isResetStep.value = true;
    });
  }

  // ============= RESET PASSWORD SCREEN =============

  // Toggle New Password Visibility
  void toggleNewPasswordVisibility() {
    isNewPasswordHidden.toggle();
  }

  // Toggle Confirm New Password Visibility
  void toggleConfirmNewPasswordVisibility() {
    isConfirmNewPasswordHidden.toggle();
  }

  // Submit New Password
  void submitNewPassword() {
    final newPassword = newPasswordController.text.trim();
    final confirmNewPassword = confirmNewPasswordController.text.trim();

    // Validation
    if (newPassword.isEmpty || confirmNewPassword.isEmpty) {
      Get.snackbar(
        'Error',
        'All fields are required',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (newPassword.length < 6) {
      Get.snackbar(
        'Error',
        'Password must be at least 6 characters',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (newPassword != confirmNewPassword) {
      Get.snackbar(
        'Error',
        'Passwords do not match',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;

    // TODO: Implement actual API call to reset password
    // Example:
    // try {
    //   await authService.resetPassword(
    //     email: emailController.text,
    //     newPassword: newPassword,
    //     resetToken: resetToken, // Get from email or intent
    //   );
    //   Get.offAllNamed(Routes.LOGIN);
    // } catch (e) {
    //   Get.snackbar('Error', e.toString());
    // } finally {
    //   isLoading.value = false;
    // }

    Future.delayed(const Duration(seconds: 2), () {
      isLoading.value = false;
      Get.snackbar(
        'Success',
        'Password reset successfully!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      // Navigate back to login or reset state
      resetState();
      Get.back();
    });
  }

  // Go Back to Forgot Password Screen
  void goBackToForgotPassword() {
    isResetStep.value = false;
    newPasswordController.clear();
    confirmNewPasswordController.clear();
  }

  // Reset all state
  void resetState() {
    isResetStep.value = false;
    emailController.clear();
    newPasswordController.clear();
    confirmNewPasswordController.clear();
    isNewPasswordHidden.value = true;
    isConfirmNewPasswordHidden.value = true;
  }
}
