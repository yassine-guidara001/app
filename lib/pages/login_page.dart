import 'package:flutter/material.dart';
import 'package:flutter_getx_app/app/modules/home/contollers/auth_controller.dart';
import 'package:get/get.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  final AuthController controller = Get.put(AuthController());

  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: const Color(0xFFE8EEF5),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 24,
                      ),
                      child: Container(
                        width: 400,
                        padding: const EdgeInsets.fromLTRB(24, 32, 24, 28),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFAFAFA),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE8E8E8)),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x140F172A),
                              blurRadius: 18,
                              offset: Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Center(
                              child: Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(9),
                                  gradient: const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color(0xFF6EA8FF),
                                      Color(0xFF3576E8),
                                    ],
                                  ),
                                ),
                                child: const Center(
                                  child: Text(
                                    'S',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 22,
                                      height: 1,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'SUNSPACE',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFF0F172A),
                                fontWeight: FontWeight.w800,
                                fontSize: 28,
                                letterSpacing: -0.2,
                                height: 1,
                              ),
                            ),
                            const SizedBox(height: 7),
                            const Text(
                              'Connexion a votre compte',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFFB45309),
                                fontWeight: FontWeight.w500,
                                fontSize: 18,
                                height: 1,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Adresse email',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 6),
                            _LoginInput(
                              controller: emailCtrl,
                              hintText: 'vous@example.com',
                              icon: Icons.email_outlined,
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                const Text(
                                  'Mot de passe',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                  ),
                                ),
                                const Spacer(),
                                TextButton(
                                  onPressed: () {},
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: Size.zero,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: const Text(
                                    'Mot de passe oublie?',
                                    style: TextStyle(
                                      color: Color(0xFF2764DB),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            _LoginInput(
                              controller: passwordCtrl,
                              hintText: '••••••',
                              icon: Icons.lock_outline,
                              obscureText: true,
                            ),
                            const SizedBox(height: 12),
                            Obx(
                              () => SizedBox(
                                height: 41,
                                child: controller.isLoading.value
                                    ? const Center(
                                        child: SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.5,
                                          ),
                                        ),
                                      )
                                    : ElevatedButton(
                                        onPressed: () {
                                          controller.loginUser(
                                            emailCtrl.text.trim(),
                                            passwordCtrl.text.trim(),
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          elevation: 0,
                                          backgroundColor:
                                              const Color(0xFF196CE6),
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                        ),
                                        child: const Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              'Se connecter',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 16,
                                              ),
                                            ),
                                            SizedBox(width: 8),
                                            Icon(Icons.arrow_forward, size: 18),
                                          ],
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            const Row(
                              children: [
                                Expanded(
                                  child: Divider(
                                    thickness: 1,
                                    color: Color(0xFFD1D5DB),
                                    height: 1,
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 10),
                                  child: Text(
                                    'Ou',
                                    style: TextStyle(
                                      color: Color(0xFF6B7280),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Divider(
                                    thickness: 1,
                                    color: Color(0xFFD1D5DB),
                                    height: 1,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Center(
                              child: TextButton(
                                onPressed: () => Get.toNamed('/register'),
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: const Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text: 'Pas encore de compte? ',
                                        style: TextStyle(
                                          color: Color(0xFF4B5563),
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14,
                                        ),
                                      ),
                                      TextSpan(
                                        text: 'S\'inscrire',
                                        style: TextStyle(
                                          color: Color(0xFF145BDE),
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _LoginInput extends StatelessWidget {
  const _LoginInput({
    required this.controller,
    required this.hintText,
    required this.icon,
    this.obscureText = false,
  });

  final TextEditingController controller;
  final String hintText;
  final IconData icon;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
            color: Color(0xFF708090),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Icon(icon, size: 18, color: const Color(0xFF6B7280)),
          isDense: true,
          filled: true,
          fillColor: const Color(0xFFF3F4F6),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF93C5FD), width: 1.2),
          ),
        ),
      ),
    );
  }
}
