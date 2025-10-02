import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NavigationController extends GetxController {
  // Current tab index
  final RxInt _currentIndex = 0.obs;

  // Page controller for smooth transitions
  late PageController pageController;

  // Tab items configuration
  final List<NavigationItem> tabs = [
    NavigationItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      label: 'Home',
      route: '/home',
    ),
    NavigationItem(
      icon: Icons.book_outlined,
      activeIcon: Icons.book,
      label: 'Courses',
      route: '/courses',
    ),
    NavigationItem(
      icon: Icons.assignment_outlined,
      activeIcon: Icons.assignment,
      label: 'Assignments',
      route: '/assignments',
    ),
    NavigationItem(
      icon: Icons.grade_outlined,
      activeIcon: Icons.grade,
      label: 'Grades',
      route: '/grades',
    ),
    NavigationItem(
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      label: 'Profile',
      route: '/profile',
    ),
  ];

  // Getters
  int get currentIndex => _currentIndex.value;
  NavigationItem get currentTab => tabs[_currentIndex.value];

  @override
  void onInit() {
    super.onInit();
    pageController = PageController(initialPage: _currentIndex.value);
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  // Change tab with animation
  void changeTab(int index) {
    if (index == _currentIndex.value) return;

    _currentIndex.value = index;

    // Animate to the selected page
    pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );

    // Notify UI to rebuild
    update();

    // Don't use GetX navigation for tab switching within MainScaffold
    // The PageView handles the actual UI navigation
    // This prevents "Route id not found" errors
  }

  // Navigate to specific route
  void navigateToRoute(String route) {
    final index = tabs.indexWhere((tab) => tab.route == route);
    if (index != -1) {
      changeTab(index);
    } else {
      // Handle non-tab routes
      Get.toNamed(route);
    }
  }

  // Navigate back
  void goBack() {
    if (Navigator.canPop(Get.context!)) {
      Get.back();
    } else {
      // If can't go back, go to home
      changeTab(0);
    }
  }

  // Check if current tab can pop
  bool canPopCurrentTab() {
    return Get.nestedKey(1)?.currentState?.canPop() ?? false;
  }

  // Handle back button on Android
  Future<bool> onWillPop() async {
    // If current tab has pages to pop, pop them first
    if (canPopCurrentTab()) {
      Get.back(id: 1);
      return false;
    }

    // If not on home tab, go to home
    if (_currentIndex.value != 0) {
      changeTab(0);
      return false;
    }

    // Allow app to exit
    return true;
  }

  // Reset to home tab
  void resetToHome() {
    changeTab(0);
  }

  // Get badge count for tab (for notifications, etc.)
  int getBadgeCount(int index) {
    // This can be customized based on your app's logic
    // For example, return number of unread assignments for assignments tab
    switch (index) {
      case 2: // Assignments tab
        // Return number of pending assignments
        return 0; // TODO: Implement actual logic
      default:
        return 0;
    }
  }

  // Check if tab has badge
  bool hasBadge(int index) {
    return getBadgeCount(index) > 0;
  }

  // Update page from PageView
  void updatePageIndex(int index) {
    if (_currentIndex.value != index) {
      _currentIndex.value = index;
      // Notify UI to rebuild
      update();
    }
  }
}

class NavigationItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String route;

  NavigationItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.route,
  });
}
