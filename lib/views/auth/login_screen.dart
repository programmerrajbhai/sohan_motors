import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../utils/app_colors.dart';
import '../../utils/responsive_layout.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // কন্ট্রোলার ইনিশিয়ালাইজ করা হলো
    final AuthController authController = Get.put(AuthController());

    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      body: Center(
        child: ResponsiveLayout(
          mobile: _buildMobileLogin(authController),
          web: _buildWebLogin(context, authController),
        ),
      ),
    );
  }

  Widget _buildMobileLogin(AuthController authController) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Card(
        elevation: 8,
        color: AppColors.pureWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: _loginForm(authController),
        ),
      ),
    );
  }

  Widget _buildWebLogin(BuildContext context, AuthController authController) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.7,
      height: 550,
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 20)],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.primaryBlue,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                ),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.two_wheeler, size: 100, color: AppColors.pureWhite),
                  SizedBox(height: 20),
                  Text("Sohan Motors", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.pureWhite)),
                  SizedBox(height: 10),
                  Text("Smart Showroom Management", style: TextStyle(fontSize: 16, color: Colors.white70)),
                ],
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 40),
              child: _loginForm(authController),
            ),
          ),
        ],
      ),
    );
  }

  Widget _loginForm(AuthController authController) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Welcome Back,", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.solidBlack)),
        const Text("Login to your account", style: TextStyle(color: AppColors.textGray)),
        const SizedBox(height: 30),

        TextField(
          controller: authController.emailCtrl,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: "Email or Username",
            prefixIcon: const Icon(Icons.person, color: AppColors.primaryBlue),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        const SizedBox(height: 20),

        TextField(
          controller: authController.passwordCtrl,
          obscureText: true,
          decoration: InputDecoration(
            labelText: "Password",
            prefixIcon: const Icon(Icons.lock, color: AppColors.primaryBlue),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        const SizedBox(height: 30),

        Obx(() => SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: authController.isLoading.value ? null : () => authController.login(),
            child: authController.isLoading.value
                ? const CircularProgressIndicator(color: AppColors.pureWhite)
                : const Text("LOGIN", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.pureWhite)),
          ),
        )),
      ],
    );
  }
}