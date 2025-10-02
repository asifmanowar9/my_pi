import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../shared/themes/app_text_styles.dart';
import '../../shared/themes/app_theme.dart';
import '../../core/controllers/navigation_controller.dart';

class CustomAppDrawer extends StatelessWidget {
  const CustomAppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    return Drawer(
      child: Column(
        children: [
          // Drawer header with profile info
          _DrawerHeader(),

          // Navigation items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _DrawerSection(
                  title: 'Academic',
                  items: [
                    _DrawerItem(
                      icon: Icons.home,
                      title: 'Home',
                      onTap: () {
                        Get.back();
                        Get.find<NavigationController>().changeTab(0);
                      },
                    ),
                    _DrawerItem(
                      icon: Icons.book,
                      title: 'Courses',
                      onTap: () {
                        Get.back();
                        Get.find<NavigationController>().changeTab(1);
                      },
                    ),
                    _DrawerItem(
                      icon: Icons.assignment,
                      title: 'Assignments',
                      onTap: () {
                        Get.back();
                        Get.find<NavigationController>().changeTab(2);
                      },
                    ),
                    _DrawerItem(
                      icon: Icons.grade,
                      title: 'Grades',
                      onTap: () {
                        Get.back();
                        Get.find<NavigationController>().changeTab(3);
                      },
                    ),
                    _DrawerItem(
                      icon: Icons.description,
                      title: 'Transcript',
                      onTap: () {
                        Get.back();
                        Get.toNamed('/transcript');
                      },
                    ),
                  ],
                ),

                const Divider(),

                _DrawerSection(
                  title: 'Tools',
                  items: [
                    _DrawerItem(
                      icon: Icons.calculate,
                      title: 'GPA Calculator',
                      onTap: () {
                        Get.back();
                        _showGPACalculator();
                      },
                    ),
                    _DrawerItem(
                      icon: Icons.schedule,
                      title: 'Class Schedule',
                      onTap: () {
                        Get.back();
                        _showClassSchedule();
                      },
                    ),
                    _DrawerItem(
                      icon: Icons.calendar_today,
                      title: 'Academic Calendar',
                      onTap: () {
                        Get.back();
                        _showAcademicCalendar();
                      },
                    ),
                  ],
                ),

                const Divider(),

                _DrawerSection(
                  title: 'Account',
                  items: [
                    _DrawerItem(
                      icon: Icons.person,
                      title: 'Profile',
                      onTap: () {
                        Get.back();
                        Get.find<NavigationController>().changeTab(4);
                      },
                    ),
                    _DrawerItem(
                      icon: Icons.notifications,
                      title: 'Notifications',
                      onTap: () {
                        Get.back();
                        Get.toNamed('/profile/notifications');
                      },
                    ),
                    _DrawerItem(
                      icon: Icons.settings,
                      title: 'Settings',
                      onTap: () {
                        Get.back();
                        Get.toNamed('/settings');
                      },
                    ),
                  ],
                ),

                const Divider(),

                // Theme toggle
                GetBuilder<ThemeController>(
                  builder: (controller) {
                    return SwitchListTile(
                      secondary: Icon(
                        controller.isDarkMode
                            ? Icons.dark_mode
                            : Icons.light_mode,
                        color: Get.theme.colorScheme.primary,
                      ),
                      title: Text(
                        'Dark Mode',
                        style: AppTextStyles.cardSubtitle,
                      ),
                      subtitle: Text(
                        controller.isDarkMode ? 'Enabled' : 'Disabled',
                        style: AppTextStyles.caption,
                      ),
                      value: controller.isDarkMode,
                      onChanged: (value) => controller.setTheme(value),
                    );
                  },
                ),

                const Divider(),

                // Help and Support
                _DrawerItem(
                  icon: Icons.help,
                  title: 'Help & Support',
                  onTap: () {
                    Get.back();
                    _showHelpDialog();
                  },
                ),

                _DrawerItem(
                  icon: Icons.info,
                  title: 'About My Pi',
                  onTap: () {
                    Get.back();
                    _showAboutDialog();
                  },
                ),
              ],
            ),
          ),

          // Footer with app version
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Divider(),
                Text(
                  'My Pi v1.0.0',
                  style: AppTextStyles.caption.copyWith(
                    color: Get.theme.colorScheme.onSurfaceVariant.withOpacity(
                      0.7,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '© 2025 University',
                  style: AppTextStyles.caption.copyWith(
                    color: Get.theme.colorScheme.onSurfaceVariant.withOpacity(
                      0.7,
                    ),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showGPACalculator() {
    Get.dialog(
      AlertDialog(
        title: const Text('GPA Calculator'),
        content: const Text('GPA Calculator feature coming soon!'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Close')),
        ],
      ),
    );
  }

  void _showClassSchedule() {
    Get.dialog(
      AlertDialog(
        title: const Text('Class Schedule'),
        content: const Text('Class Schedule feature coming soon!'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Close')),
        ],
      ),
    );
  }

  void _showAcademicCalendar() {
    Get.dialog(
      AlertDialog(
        title: const Text('Academic Calendar'),
        content: const Text('Academic Calendar feature coming soon!'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Close')),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Help & Support'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Need help? Contact us:'),
            SizedBox(height: 12),
            Text('📧 support@mypi.edu'),
            Text('📞 (555) 123-4567'),
            Text('🕒 Mon-Fri 9AM-5PM'),
            SizedBox(height: 12),
            Text('Or visit our help center online.'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Close')),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('About My Pi'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('My Pi - Your Personal Academic Assistant'),
            SizedBox(height: 12),
            Text('Version: 1.0.0'),
            Text('Build: 1'),
            SizedBox(height: 12),
            Text(
              'Developed for students to manage their academic life efficiently.',
            ),
            SizedBox(height: 12),
            Text('Features:'),
            Text('• Course management'),
            Text('• Assignment tracking'),
            Text('• Grade monitoring'),
            Text('• Progress analytics'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Close')),
        ],
      ),
    );
  }
}

class _DrawerHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 50, 16, 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Get.theme.colorScheme.primary,
            Get.theme.colorScheme.primaryContainer,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white,
            child: Text(
              'JD',
              style: AppTextStyles.cardTitle?.copyWith(
                color: Get.theme.colorScheme.primary,
                fontSize: 20,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'John Doe',
            style: AppTextStyles.cardTitle?.copyWith(
              color: Colors.white,
              fontSize: 18,
            ),
          ),
          Text(
            'Computer Science',
            style: AppTextStyles.cardSubtitle.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'GPA: 3.78',
              style: AppTextStyles.caption.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawerSection extends StatelessWidget {
  final String title;
  final List<Widget> items;

  const _DrawerSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: AppTextStyles.caption.copyWith(
              color: Get.theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
        ...items,
      ],
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool selected;

  const _DrawerItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: selected
            ? Get.theme.colorScheme.primary
            : Get.theme.colorScheme.onSurfaceVariant,
      ),
      title: Text(
        title,
        style: AppTextStyles.cardSubtitle.copyWith(
          color: selected ? Get.theme.colorScheme.primary : null,
          fontWeight: selected ? FontWeight.w600 : null,
        ),
      ),
      onTap: onTap,
      selected: selected,
      selectedTileColor: Get.theme.colorScheme.primaryContainer.withOpacity(
        0.1,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}
