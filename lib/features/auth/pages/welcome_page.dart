import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? size.width * 0.2 : 24.0,
            vertical: 20.0,
          ),
          child: Column(
            children: [
              // Skip Button
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: () => authController.continueAsGuest(),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey.shade600,
                  ),
                  child: const Text('Skip'),
                ),
              ),

              SizedBox(height: size.height * 0.05),

              // App Logo
              Container(
                width: isTablet ? 150 : 120,
                height: isTablet ? 150 : 120,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Icon(
                  Icons.school,
                  size: isTablet ? 80 : 60,
                  color: Colors.white,
                ),
              ),

              SizedBox(height: size.height * 0.05),

              // Welcome Text
              Text(
                'Welcome to My Pi',
                style: TextStyle(
                  fontSize: isTablet ? 32 : 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              Text(
                'Your personal student assistant for better academic management',
                style: TextStyle(
                  fontSize: isTablet ? 18 : 16,
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: size.height * 0.06),

              // Benefits Section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.blue.shade100),
                ),
                child: Column(
                  children: [
                    Text(
                      'Why create an account?',
                      style: TextStyle(
                        fontSize: isTablet ? 22 : 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                      ),
                    ),

                    const SizedBox(height: 20),

                    _BenefitItem(
                      icon: Icons.cloud_sync,
                      title: 'Sync Across Devices',
                      description: 'Access your data from any device, anywhere',
                      isTablet: isTablet,
                    ),

                    const SizedBox(height: 16),

                    _BenefitItem(
                      icon: Icons.backup,
                      title: 'Automatic Backup',
                      description: 'Never lose your important academic data',
                      isTablet: isTablet,
                    ),

                    const SizedBox(height: 16),

                    _BenefitItem(
                      icon: Icons.notifications,
                      title: 'Smart Reminders',
                      description:
                          'Get notified about assignments and deadlines',
                      isTablet: isTablet,
                    ),
                  ],
                ),
              ),

              SizedBox(height: size.height * 0.06),

              // Action Buttons
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => authController.goToRegisterFromWelcome(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: Text(
                    'Get Started',
                    style: TextStyle(
                      fontSize: isTablet ? 18 : 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: () => authController.goToLoginFromWelcome(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.blue,
                    side: const BorderSide(color: Colors.blue),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'I Already Have an Account',
                    style: TextStyle(
                      fontSize: isTablet ? 18 : 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Continue Without Account - Prominently Displayed
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.arrow_forward,
                          color: Colors.grey.shade600,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Continue without account',
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w500,
                            fontSize: isTablet ? 16 : 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => authController.continueAsGuest(),
                      child: Text(
                        'You can always sign up later',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: isTablet ? 14 : 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _BenefitItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final bool isTablet;

  const _BenefitItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: isTablet ? 50 : 40,
          height: isTablet ? 50 : 40,
          decoration: BoxDecoration(
            color: Colors.blue.shade100,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: Colors.blue.shade600,
            size: isTablet ? 28 : 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: isTablet ? 18 : 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: isTablet ? 16 : 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
