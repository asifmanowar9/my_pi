import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';
import '../controllers/auth_controller.dart';
import '../../../shared/themes/app_text_styles.dart';

class EmailVerificationPage extends StatefulWidget {
  const EmailVerificationPage({super.key});

  @override
  State<EmailVerificationPage> createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  final AuthController _authController = Get.find<AuthController>();
  Timer? _verificationCheckTimer;
  int _resendCountdown = 0;
  Timer? _resendTimer;

  @override
  void initState() {
    super.initState();
    // Auto-check verification status every 3 seconds
    _startVerificationCheckTimer();
  }

  void _startVerificationCheckTimer() {
    _verificationCheckTimer = Timer.periodic(const Duration(seconds: 3), (
      timer,
    ) async {
      if (_authController.isEmailVerified) {
        timer.cancel();
        await _onEmailVerified();
      } else {
        // Check if email is verified
        final isVerified = await _authController.checkEmailVerification();
        if (isVerified) {
          timer.cancel();
          await _onEmailVerified();
        }
      }
    });
  }

  Future<void> _onEmailVerified() async {
    // Perform first-time login setup after email verification
    await _authController.performFirstTimeLogin();
    // Navigate to main screen
    Get.offAllNamed('/main');
  }

  void _startResendCountdown() {
    setState(() {
      _resendCountdown = 60; // 60 seconds cooldown
    });

    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_resendCountdown > 0) {
          _resendCountdown--;
        } else {
          timer.cancel();
        }
      });
    });
  }

  Future<void> _resendVerificationEmail() async {
    if (_resendCountdown > 0) return;

    await _authController.sendEmailVerification();
    _startResendCountdown();
  }

  @override
  void dispose() {
    _verificationCheckTimer?.cancel();
    _resendTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = _authController.user;

    return Scaffold(
      appBar: AppBar(
        title: Text('Verify Email', style: AppTextStyles.appBarTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () async {
            await _authController.signOut();
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Email icon
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.email_outlined,
                  size: 80,
                  color: theme.colorScheme.primary,
                ),
              ),

              const SizedBox(height: 32),

              // Title
              Text(
                'Verify Your Email',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // Message
              Text(
                'We\'ve sent a verification link to',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              // Email address
              Text(
                user?.email ?? '',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 24),

              // Instructions
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: theme.colorScheme.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Next Steps:',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildInstructionStep(
                        context,
                        '1',
                        'Check your email inbox',
                      ),
                      const SizedBox(height: 8),
                      _buildInstructionStep(
                        context,
                        '2',
                        'Click the verification link',
                      ),
                      const SizedBox(height: 8),
                      _buildInstructionStep(
                        context,
                        '3',
                        'Return here to continue',
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Tip: Check your spam folder if you don\'t see the email',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Check verification button
              Obx(
                () => SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _authController.isCheckingVerification
                        ? null
                        : () async {
                            final isVerified = await _authController
                                .checkEmailVerification();
                            if (isVerified) {
                              await _onEmailVerified();
                            } else {
                              Get.snackbar(
                                'Not Verified Yet',
                                'Please check your email and click the verification link first.',
                                backgroundColor: Colors.orange,
                                colorText: Colors.white,
                                snackPosition: SnackPosition.BOTTOM,
                              );
                            }
                          },
                    icon: _authController.isCheckingVerification
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Icon(Icons.check_circle_outline),
                    label: Text(
                      _authController.isCheckingVerification
                          ? 'Checking...'
                          : 'I\'ve Verified My Email',
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Resend email button
              Obx(
                () => SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed:
                        _authController.isSendingVerification ||
                            _resendCountdown > 0
                        ? null
                        : _resendVerificationEmail,
                    icon: _authController.isSendingVerification
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.refresh),
                    label: Text(
                      _authController.isSendingVerification
                          ? 'Sending...'
                          : _resendCountdown > 0
                          ? 'Resend in ${_resendCountdown}s'
                          : 'Resend Verification Email',
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Sign out option
              TextButton(
                onPressed: () async {
                  await _authController.signOut();
                },
                child: const Text('Sign Out'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInstructionStep(
    BuildContext context,
    String number,
    String text,
  ) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(text, style: theme.textTheme.bodyMedium)),
      ],
    );
  }
}
