import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../shared/themes/app_text_styles.dart';
import '../../core/controllers/navigation_controller.dart';
import '../../shared/themes/app_theme.dart';
import '../auth/controllers/auth_controller.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final isAuthenticated = authController.isAuthenticated;

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile', style: AppTextStyles.appBarTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Get.toNamed('/settings'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ProfileHeader(authController: authController),
            const SizedBox(height: 24),
            // Only show academic info and quick actions if authenticated
            if (isAuthenticated) ...[
              const _AcademicInfo(),
              const SizedBox(height: 24),
              _QuickActions(authController: authController),
              const SizedBox(height: 24),
            ],
            const _PreferencesSection(),
          ],
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final AuthController authController;

  const _ProfileHeader({required this.authController});

  @override
  Widget build(BuildContext context) {
    // Check if user is authenticated
    if (!authController.isAuthenticated) {
      return _GuestProfileCard();
    }

    // Show authenticated user profile
    final user = authController.user;
    final displayName =
        user?.displayName ?? user?.email?.split('@')[0] ?? 'User';
    final email = user?.email ?? 'No email';
    final initials = displayName
        .split(' ')
        .map((n) => n[0])
        .take(2)
        .join()
        .toUpperCase();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Get.theme.colorScheme.primary,
              backgroundImage: user?.photoURL != null
                  ? NetworkImage(user!.photoURL!)
                  : null,
              child: user?.photoURL == null
                  ? Text(
                      initials,
                      style: Get.textTheme.headlineMedium?.copyWith(
                        color: Get.theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
            const SizedBox(height: 16),
            Text(
              displayName,
              style: AppTextStyles.cardTitle.copyWith(fontSize: 24),
            ),
            const SizedBox(height: 4),
            Text(email, style: AppTextStyles.cardSubtitle),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ProfileStat(label: 'Semester', value: '6th'),
                _ProfileStat(label: 'Major', value: 'Computer Science'),
                _ProfileStat(label: 'GPA', value: '3.78'),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => Get.toNamed('/profile/edit'),
                icon: const Icon(Icons.edit),
                label: const Text('Edit Profile'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  final String label;
  final String value;

  const _ProfileStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: AppTextStyles.cardTitle),
        const SizedBox(height: 4),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }
}

class _AcademicInfo extends StatelessWidget {
  const _AcademicInfo();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Academic Information', style: AppTextStyles.cardTitle),
            const SizedBox(height: 16),
            _InfoRow(
              icon: Icons.school,
              label: 'Student ID',
              value: '20210001',
            ),
            _InfoRow(
              icon: Icons.calendar_today,
              label: 'Expected Graduation',
              value: 'May 2027',
            ),
            _InfoRow(
              icon: Icons.location_on,
              label: 'Campus',
              value: 'Main Campus',
            ),
            _InfoRow(
              icon: Icons.person,
              label: 'Academic Advisor',
              value: 'Dr. Sarah Wilson',
            ),
            _InfoRow(
              icon: Icons.group,
              label: 'Class Standing',
              value: 'Junior',
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Get.theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: AppTextStyles.caption)),
          Text(
            value,
            style: AppTextStyles.cardSubtitle.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  final AuthController authController;

  const _QuickActions({required this.authController});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Quick Actions', style: AppTextStyles.cardTitle),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2.5,
              children: [
                _ActionButton(
                  icon: Icons.description,
                  label: 'Transcript',
                  onTap: () => Get.toNamed('/transcript'),
                ),
                _ActionButton(
                  icon: Icons.notifications,
                  label: 'Notifications',
                  onTap: () => Get.toNamed('/profile/notifications'),
                ),
                _ActionButton(
                  icon: Icons.lock,
                  label: 'Password',
                  onTap: () => Get.toNamed('/profile/password'),
                ),
                _ActionButton(
                  icon: Icons.help,
                  label: 'Help & Support',
                  onTap: () {
                    // TODO: Implement help
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Get.theme.colorScheme.outline.withOpacity(0.3),
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Get.theme.colorScheme.primary, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _PreferencesSection extends StatelessWidget {
  const _PreferencesSection();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Preferences', style: AppTextStyles.cardTitle),
            const SizedBox(height: 16),
            GetBuilder<ThemeController>(
              builder: (controller) {
                return SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Dark Mode', style: AppTextStyles.cardSubtitle),
                  subtitle: Text(
                    'Use dark theme for better viewing in low light',
                    style: AppTextStyles.caption,
                  ),
                  value: controller.isDarkMode,
                  onChanged: (value) => controller.setTheme(value),
                  secondary: Icon(
                    controller.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                    color: Get.theme.colorScheme.primary,
                  ),
                );
              },
            ),
            const Divider(),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                Icons.notifications_outlined,
                color: Get.theme.colorScheme.primary,
              ),
              title: Text(
                'Notification Settings',
                style: AppTextStyles.cardSubtitle,
              ),
              subtitle: Text(
                'Manage your notification preferences',
                style: AppTextStyles.caption,
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Get.toNamed('/profile/notifications'),
            ),
            const Divider(),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.logout, color: Colors.red),
              title: Text(
                'Sign Out',
                style: AppTextStyles.cardSubtitle.copyWith(color: Colors.red),
              ),
              subtitle: Text(
                'Sign out of your account',
                style: AppTextStyles.caption,
              ),
              onTap: () {
                _showSignOutDialog(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showSignOutDialog(BuildContext context) {
    final authController = Get.find<AuthController>();

    Get.dialog(
      AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              // Sign out using AuthController
              await authController.signOut();

              // Reset to home tab
              final navigationController = Get.find<NavigationController>();
              navigationController.resetToHome();
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}

// Guest Profile Card - shown when user is not logged in
class _GuestProfileCard extends StatelessWidget {
  const _GuestProfileCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.account_circle_outlined,
              size: 80,
              color: Get.theme.colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Guest Mode',
              style: AppTextStyles.cardTitle.copyWith(fontSize: 24),
            ),
            const SizedBox(height: 8),
            Text(
              'You\'re using the app locally',
              style: AppTextStyles.cardSubtitle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Get.theme.colorScheme.primaryContainer.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Get.theme.colorScheme.primary.withOpacity(0.3),
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.cloud_off_outlined,
                    color: Get.theme.colorScheme.primary,
                    size: 32,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Your data is stored locally on this device',
                    style: AppTextStyles.caption.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Login or register to save your data to the cloud and access it from any device',
                    style: AppTextStyles.caption.copyWith(
                      color: Get.theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Get.toNamed('/login'),
                    icon: const Icon(Icons.login),
                    label: const Text('Login'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Get.toNamed('/register'),
                    icon: const Icon(Icons.person_add),
                    label: const Text('Register'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
