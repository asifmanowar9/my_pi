import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../shared/themes/app_text_styles.dart';
import '../../shared/themes/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Settings', style: AppTextStyles.appBarTitle)),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _AppearanceSection(),
            SizedBox(height: 24),
            _NotificationSection(),
            SizedBox(height: 24),
            _PrivacySection(),
            SizedBox(height: 24),
            _AboutSection(),
          ],
        ),
      ),
    );
  }
}

class _AppearanceSection extends StatelessWidget {
  const _AppearanceSection();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Appearance', style: AppTextStyles.cardTitle),
            const SizedBox(height: 16),
            GetBuilder<ThemeController>(
              builder: (controller) {
                return Column(
                  children: [
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        'Dark Mode',
                        style: AppTextStyles.cardSubtitle,
                      ),
                      subtitle: Text(
                        'Use dark theme',
                        style: AppTextStyles.caption,
                      ),
                      value: controller.isDarkMode,
                      onChanged: (value) => controller.setTheme(value),
                      secondary: Icon(
                        controller.isDarkMode
                            ? Icons.dark_mode
                            : Icons.light_mode,
                        color: Get.theme.colorScheme.primary,
                      ),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        Icons.auto_mode,
                        color: Get.theme.colorScheme.primary,
                      ),
                      title: Text(
                        'Follow System Theme',
                        style: AppTextStyles.cardSubtitle,
                      ),
                      subtitle: Text(
                        'Automatically switch based on system settings',
                        style: AppTextStyles.caption,
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        controller.setSystemTheme();
                        Get.snackbar(
                          'Theme Updated',
                          'Following system theme preference',
                          snackPosition: SnackPosition.BOTTOM,
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationSection extends StatelessWidget {
  const _NotificationSection();

  @override
  Widget build(BuildContext context) {
    return Card(
      // child: Padding(
      //   padding: const EdgeInsets.all(16),
      //   // child: Column(
      //   //   crossAxisAlignment: CrossAxisAlignment.start,
      //   //   children: [
      //   //     // Text('Notifications', style: AppTextStyles.cardTitle),
      //   //     // const SizedBox(height: 16),
      //   //     // _NotificationTile(
      //   //     //   icon: Icons.assignment,
      //   //     //   title: 'Assignment Reminders',
      //   //     //   subtitle: 'Get notified about upcoming assignments',
      //   //     //   value: true,
      //   //     //   onChanged: (value) {
      //   //     //     // TODO: Implement notification setting
      //   //     //   },
      //   //     // ),
      //   //     // _NotificationTile(
      //   //     //   icon: Icons.grade,
      //   //     //   title: 'Grade Updates',
      //   //     //   subtitle: 'Get notified when grades are posted',
      //   //     //   value: true,
      //   //     //   onChanged: (value) {
      //   //     //     // TODO: Implement notification setting
      //   //     //   },
      //   //     // ),
      //   //     // _NotificationTile(
      //   //     //   icon: Icons.schedule,
      //   //     //   title: 'Class Reminders',
      //   //     //   subtitle: 'Get notified before classes start',
      //   //     //   value: false,
      //   //     //   onChanged: (value) {
      //   //     //     // TODO: Implement notification setting
      //   //     //   },
      //   //     // ),
      //   //     // ListTile(
      //   //     //   contentPadding: EdgeInsets.zero,
      //   //     //   leading: Icon(Icons.tune, color: Get.theme.colorScheme.primary),
      //   //     //   title: Text(
      //   //     //     'Advanced Notification Settings',
      //   //     //     style: AppTextStyles.cardSubtitle,
      //   //     //   ),
      //   //     //   subtitle: Text(
      //   //     //     'Customize notification timing and frequency',
      //   //     //     style: AppTextStyles.caption,
      //   //     //   ),
      //   //     //   trailing: const Icon(Icons.chevron_right),
      //   //     //   onTap: () => Get.toNamed('/profile/notifications'),
      //   //     // ),
      //   //     // const Divider(),
      //   //     // ListTile(
      //   //     //   contentPadding: EdgeInsets.zero,
      //   //     //   leading: Icon(Icons.bug_report, color: Colors.orange),
      //   //     //   title: Text(
      //   //     //     'Notification Debugger',
      //   //     //     style: AppTextStyles.cardSubtitle,
      //   //     //   ),
      //   //     //   subtitle: Text(
      //   //     //     'Test and troubleshoot notifications',
      //   //     //     style: AppTextStyles.caption,
      //   //     //   ),
      //   //     //   trailing: const Icon(Icons.chevron_right),
      //   //     //   onTap: () => Get.toNamed('/debug/notifications'),
      //   //     // ),
      //   //   ],
      //   // ),
      // ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _NotificationTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      secondary: Icon(icon, color: Get.theme.colorScheme.primary),
      title: Text(title, style: AppTextStyles.cardSubtitle),
      subtitle: Text(subtitle, style: AppTextStyles.caption),
      value: value,
      onChanged: onChanged,
    );
  }
}

class _PrivacySection extends StatelessWidget {
  const _PrivacySection();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Privacy & Security', style: AppTextStyles.cardTitle),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.lock, color: Get.theme.colorScheme.primary),
              title: Text('Change Password', style: AppTextStyles.cardSubtitle),
              subtitle: Text(
                'Update your account password',
                style: AppTextStyles.caption,
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Get.toNamed('/profile/password'),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                Icons.privacy_tip,
                color: Get.theme.colorScheme.primary,
              ),
              title: Text('Privacy Policy', style: AppTextStyles.cardSubtitle),
              subtitle: Text(
                'Read our privacy policy',
                style: AppTextStyles.caption,
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // TODO: Show privacy policy
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                Icons.description,
                color: Get.theme.colorScheme.primary,
              ),
              title: Text(
                'Terms of Service',
                style: AppTextStyles.cardSubtitle,
              ),
              subtitle: Text(
                'Read our terms of service',
                style: AppTextStyles.caption,
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // TODO: Show terms of service
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _AboutSection extends StatelessWidget {
  const _AboutSection();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('About', style: AppTextStyles.cardTitle),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.info, color: Get.theme.colorScheme.primary),
              title: Text('App Version', style: AppTextStyles.cardSubtitle),
              subtitle: Text('1.0.1 (Build 1.1)', style: AppTextStyles.caption),
            ),
            // ListTile(
            //   contentPadding: EdgeInsets.zero,
            //   leading: Icon(Icons.update, color: Get.theme.colorScheme.primary),
            //   title: Text(
            //     'Check for Updates',
            //     style: AppTextStyles.cardSubtitle,
            //   ),
            //   subtitle: Text(
            //     'You are using the latest version',
            //     style: AppTextStyles.caption,
            //   ),
            //   trailing: const Icon(Icons.chevron_right),
            //   onTap: () {
            //     Get.snackbar(
            //       'Up to Date',
            //       'You are using the latest version of My Pi',
            //       snackPosition: SnackPosition.BOTTOM,
            //     );
            //   },
            // ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.help, color: Get.theme.colorScheme.primary),
              title: Text('Help & Support', style: AppTextStyles.cardSubtitle),
              subtitle: Text(
                'Get help and contact support',
                style: AppTextStyles.caption,
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                _showHelpDialog();
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                Icons.feedback,
                color: Get.theme.colorScheme.primary,
              ),
              title: Text('Send Feedback', style: AppTextStyles.cardSubtitle),
              subtitle: Text(
                'Help us improve the app',
                style: AppTextStyles.caption,
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                _showFeedbackDialog();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showHelpDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Help & Support'),
        content: const Text(
          'For help and support, please contact:\n\n'
          'Email: asifpc2022@gmail.com\n'
          'Phone: (+88) 01726288836\n'
          'Hours: Sat-Thu 9AM-5PM',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Close')),
        ],
      ),
    );
  }

  void _showFeedbackDialog() {
    final TextEditingController feedbackController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('Send Feedback'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('We\'d love to hear your thoughts!'),
            const SizedBox(height: 16),
            TextField(
              controller: feedbackController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Enter your feedback here...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.snackbar(
                'Feedback Sent',
                'Thank you for your feedback!',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }
}
