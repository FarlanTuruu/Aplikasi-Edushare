// File 1: /lib/app/modules/auth/forgot_password/controllers/forget_password_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../services/auth_service.dart';

class ForgetPasswordController extends GetxController {
  // Text Controllers
  final emailController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmNewPasswordController = TextEditingController();
  final resetTokenController = TextEditingController();
  // Reactive hint for email parsed from reset link
  final resetEmailHint = ''.obs;

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
    resetTokenController.dispose();
    super.onClose();
  }

  // ============= FORGOT PASSWORD SCREEN =============

  // Send Reset Email
  Future<void> sendResetEmail() async {
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
    final auth = Get.find<AuthService>();
    try {
      // Ambil raw response untuk mendapatkan reset_link dan tokennya
      final res = await auth.forgotPasswordRaw(email);
      final apiMessage = res['message']?.toString();
      final link = res['reset_link']?.toString() ?? '';
      if (link.isNotEmpty) {
        // Coba ekstrak token dari URL (Laravel sering kirim /reset-password/{token}?email=...)
        final uri = Uri.tryParse(link);
        String? token;
        if (uri != null) {
          // Prefer token from query param
          final tokenParam = uri.queryParameters['token'];
          if (tokenParam != null && tokenParam.isNotEmpty) {
            token = Uri.decodeComponent(tokenParam);
          } else if (uri.pathSegments.length >= 2) {
            // Fallback: token as last path segment if link format is /reset-password/{token}
            token = uri.pathSegments.last;
          }
          // Auto-fill email from reset link if provided
          final emailFromLink = uri.queryParameters['email'];
          if (emailFromLink != null && emailFromLink.isNotEmpty) {
            emailController.text = Uri.decodeComponent(emailFromLink);
            resetEmailHint.value = emailController.text;
          }
        }
        if (token != null && token.isNotEmpty) {
          resetTokenController.text = token;
        }
      }

      Get.snackbar(
        'Success',
        apiMessage?.isNotEmpty == true
            ? apiMessage!
            : 'Reset email sent! Check your inbox.',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      isResetStep.value = true;
      update();
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
  Future<void> submitNewPassword() async {
    final newPassword = newPasswordController.text.trim();
    final confirmNewPassword = confirmNewPasswordController.text.trim();
    final token = resetTokenController.text.trim();

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

    // Token required by Laravel's reset endpoint; ensure present
    if (token.isEmpty) {
      Get.snackbar(
        'Error',
        'Reset token is missing. Please use the reset link sent to your email.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;
    final auth = Get.find<AuthService>();
    try {
      final ok = await auth.resetPassword(
        email: emailController.text.trim(),
        newPassword: newPassword,
        token: token,
      );
      // Debug: show parts of token and email to verify values being sent
      final maskedToken = token.length > 12
          ? token.substring(0, 6) + '...' + token.substring(token.length - 6)
          : token;
      Get.snackbar(
        'Info',
        'Submitting reset for ' +
            emailController.text.trim() +
            ' with token ' +
            maskedToken,
        backgroundColor: Colors.black87,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
      if (ok) {
        Get.snackbar(
          'Success',
          'Password reset successfully!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        resetState();
        // Navigate to login page after successful reset
        Get.offAllNamed('/login');
      } else {
        Get.snackbar(
          'Error',
          'Reset password gagal. Coba lagi.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      // Show server-provided message (e.g., Invalid or expired reset token)
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

  // Go Back to Forgot Password Screen
  void goBackToForgotPassword() {
    isResetStep.value = false;
    newPasswordController.clear();
    confirmNewPasswordController.clear();
    resetTokenController.clear();
    update();
  }

  // Resend reset email (fallback)
  Future<void> resendResetEmail() async {
    final email = emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      Get.snackbar(
        'Error',
        'Please enter a valid email before resending.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
    isLoading.value = true;
    try {
      await sendResetEmail();
    } finally {
      isLoading.value = false;
    }
  }

  // Reset all state
  void resetState() {
    isResetStep.value = false;
    emailController.clear();
    resetEmailHint.value = '';
    newPasswordController.clear();
    confirmNewPasswordController.clear();
    resetTokenController.clear();
    isNewPasswordHidden.value = true;
    isConfirmNewPasswordHidden.value = true;
    update();
  }
}
