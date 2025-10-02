import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/controllers/navigation_controller.dart';
import 'custom_app_drawer.dart';
import '../../features/home/home_screen.dart';
import '../../features/courses/courses_screen.dart';
import '../../features/assignments/assignments_screen.dart';
import '../../features/grades/grades_screen.dart';
import '../../features/profile/profile_screen.dart';

class MainScaffold extends StatelessWidget {
  const MainScaffold({super.key});

  @override
  Widget build(BuildContext context) {
    final navigationController = Get.find<NavigationController>();

    return WillPopScope(
      onWillPop: navigationController.onWillPop,
      child: Scaffold(
        drawer: const CustomAppDrawer(),
        body: GetBuilder<NavigationController>(
          builder: (controller) {
            return PageView(
              controller: controller.pageController,
              onPageChanged: controller.updatePageIndex,
              children: const [
                HomeScreen(),
                CoursesScreen(),
                AssignmentsScreen(),
                GradesScreen(),
                ProfileScreen(),
              ],
            );
          },
        ),
        bottomNavigationBar: GetBuilder<NavigationController>(
          builder: (controller) {
            return BottomNavigationBar(
              currentIndex: controller.currentIndex,
              onTap: controller.changeTab,
              type: BottomNavigationBarType.fixed,
              elevation: 8,
              items: controller.tabs.asMap().entries.map((entry) {
                final index = entry.key;
                final tab = entry.value;
                final isSelected = index == controller.currentIndex;
                final hasBadge = controller.hasBadge(index);

                return BottomNavigationBarItem(
                  icon: _buildTabIcon(
                    icon: isSelected ? tab.activeIcon : tab.icon,
                    hasBadge: hasBadge,
                    badgeCount: controller.getBadgeCount(index),
                  ),
                  label: tab.label,
                  tooltip: tab.label,
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTabIcon({
    required IconData icon,
    required bool hasBadge,
    required int badgeCount,
  }) {
    if (!hasBadge) {
      return Icon(icon);
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(icon),
        if (badgeCount > 0)
          Positioned(
            right: -6,
            top: -6,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Get.theme.colorScheme.error,
                borderRadius: BorderRadius.circular(8),
              ),
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              child: Text(
                badgeCount > 99 ? '99+' : badgeCount.toString(),
                style: Get.textTheme.labelSmall?.copyWith(
                  color: Get.theme.colorScheme.onError,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}

// Alternative implementation using NavigationBar (Material 3)
class MainScaffoldMaterial3 extends StatelessWidget {
  const MainScaffoldMaterial3({super.key});

  @override
  Widget build(BuildContext context) {
    final navigationController = Get.find<NavigationController>();

    return WillPopScope(
      onWillPop: navigationController.onWillPop,
      child: Scaffold(
        drawer: const CustomAppDrawer(),
        body: GetBuilder<NavigationController>(
          builder: (controller) {
            return PageView(
              controller: controller.pageController,
              onPageChanged: controller.updatePageIndex,
              children: const [
                HomeScreen(),
                CoursesScreen(),
                AssignmentsScreen(),
                GradesScreen(),
                ProfileScreen(),
              ],
            );
          },
        ),
        bottomNavigationBar: GetBuilder<NavigationController>(
          builder: (controller) {
            return NavigationBar(
              selectedIndex: controller.currentIndex,
              onDestinationSelected: controller.changeTab,
              destinations: controller.tabs.asMap().entries.map((entry) {
                final index = entry.key;
                final tab = entry.value;
                final isSelected = index == controller.currentIndex;
                final hasBadge = controller.hasBadge(index);

                return NavigationDestination(
                  icon: _buildTabIcon(
                    icon: tab.icon,
                    hasBadge: hasBadge,
                    badgeCount: controller.getBadgeCount(index),
                  ),
                  selectedIcon: _buildTabIcon(
                    icon: tab.activeIcon,
                    hasBadge: hasBadge,
                    badgeCount: controller.getBadgeCount(index),
                  ),
                  label: tab.label,
                  tooltip: tab.label,
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTabIcon({
    required IconData icon,
    required bool hasBadge,
    required int badgeCount,
  }) {
    if (!hasBadge) {
      return Icon(icon);
    }

    return Badge(
      label: Text(badgeCount > 99 ? '99+' : badgeCount.toString()),
      isLabelVisible: badgeCount > 0,
      child: Icon(icon),
    );
  }
}

// Animated page transition wrapper
class AnimatedTabView extends StatelessWidget {
  final Widget child;
  final bool isActive;

  const AnimatedTabView({
    super.key,
    required this.child,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position:
                Tween<Offset>(
                  begin: const Offset(0.1, 0),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(parent: animation, curve: Curves.easeInOut),
                ),
            child: child,
          ),
        );
      },
      child: isActive ? child : const SizedBox.shrink(),
    );
  }
}
