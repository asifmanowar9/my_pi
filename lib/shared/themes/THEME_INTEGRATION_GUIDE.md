# Theme System Integration Guide

## 🎨 My Pi App Theme System

Your comprehensive theme system is now ready for use! Here's how to integrate it into your app.

## 📁 Files Created

```
lib/shared/themes/
├── app_theme.dart           # Main theme configuration
├── app_colors.dart          # Color system and status indicators
├── app_text_styles.dart     # Typography system
└── theme_usage_examples.dart # Usage examples
```

## 🚀 Quick Integration

### 1. Update your main.dart

```dart
import 'package:get/get.dart';
import 'shared/themes/app_theme.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'My Pi',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system, // Or use ThemeController
      home: YourHomeScreen(),
    );
  }
}
```

### 2. Register ThemeController (if not already done)

```dart
void main() {
  // Initialize GetStorage
  await GetStorage.init();
  
  // Register ThemeController
  Get.put(ThemeController());
  
  runApp(MyApp());
}
```

### 3. Use ThemeController for dynamic theme switching

```dart
class YourWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(themeController.isDarkMode 
                ? Icons.light_mode 
                : Icons.dark_mode),
            onPressed: () => themeController.toggleTheme(),
          ),
        ],
      ),
      body: GetBuilder<ThemeController>(
        builder: (controller) {
          return YourContent();
        },
      ),
    );
  }
}
```

## 🎯 Key Features

### Colors
- **Brand Colors**: Primary, Secondary, Accent
- **Status Indicators**: Pending, Completed, Overdue, In Progress, Draft, Archived
- **Grade Colors**: A (Excellent) to F (Fail)
- **Priority Colors**: High, Medium, Low
- **Semantic Colors**: Success, Warning, Error, Info

### Typography
- **Complete hierarchy**: Display, Headline, Title, Label, Body styles
- **App-specific styles**: Course codes, assignment titles, due dates
- **Status and grade text**: Specialized text for indicators

### Components
- **Buttons**: Elevated, Outlined, Text buttons with consistent styling
- **Cards**: Proper elevation, shadows, and spacing
- **Forms**: Input fields with proper decoration and validation styling
- **Navigation**: App bar, bottom navigation, drawer styling

## 📖 Usage Examples

### Using Colors
```dart
// Status colors
Container(
  color: AppColors.getStatusContainerColor('pending'),
  child: Text(
    'Pending',
    style: TextStyle(color: AppColors.getStatusColor('pending')),
  ),
)

// Grade colors
Container(
  color: AppColors.getGradeColor('A'),
  child: Text('A+', style: AppTextStyles.gradeText),
)

// Priority colors
Icon(
  Icons.priority_high,
  color: AppColors.getPriorityColor('high'),
)
```

### Using Text Styles
```dart
Text('CS 101', style: AppTextStyles.courseCode),
Text('Assignment Title', style: AppTextStyles.assignmentTitle),
Text('Due: Dec 15, 2025', style: AppTextStyles.dueDate),
Text('Status', style: AppTextStyles.statusChip),
```

### Using Theme Controller
```dart
final themeController = Get.find<ThemeController>();

// Toggle theme
themeController.toggleTheme();

// Set specific theme
themeController.setTheme(true); // Dark mode
themeController.setTheme(false); // Light mode

// Get adaptive colors
Color textColor = themeController.adaptiveTextColor;
Color surfaceColor = themeController.adaptiveSurfaceColor;

// Get status colors
Color statusColor = themeController.getStatusColor('completed');
Color containerColor = themeController.getStatusContainerColor('overdue');
```

## 🔧 Customization

### Adding New Status Types
```dart
// In app_colors.dart, add to getStatusColor() method
case 'your_new_status':
  return const Color(0xFF9C27B0); // Your color

// Add container color variant
case 'your_new_status':
  return const Color(0xFFF3E5F5); // Light variant
```

### Adding New Text Styles
```dart
// In app_text_styles.dart
static TextStyle get yourCustomStyle => TextStyle(
  fontSize: 14,
  fontWeight: FontWeight.w500,
  color: AppColors.primary,
);
```

### Modifying Color Scheme
```dart
// In app_theme.dart, modify the ColorScheme
static const ColorScheme lightColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: Color(0xFF1976D2), // Change primary color
  // ... other colors
);
```

## 🎨 Design System Benefits

1. **Consistency**: All components follow the same design language
2. **Accessibility**: Proper contrast ratios and text scaling
3. **Maintainability**: Centralized theme management
4. **Dark Mode**: Full dark theme support with automatic switching
5. **Responsive**: Adapts to different screen sizes and densities
6. **Performance**: Optimized theme switching with GetX

## 📱 Testing Your Theme

Run the theme usage examples:
```dart
// Add to your app for testing
MaterialPageRoute(
  builder: (context) => ThemeUsageExamples(),
)
```

## 🐛 Troubleshooting

### Common Issues:
1. **Theme not applying**: Ensure ThemeController is registered before app starts
2. **Colors not showing**: Check if you're using the correct color methods
3. **Text styles not working**: Import app_text_styles.dart in your widgets
4. **Storage errors**: Initialize GetStorage before registering ThemeController

### Debug Mode:
```dart
// Add to see current theme state
print('Current theme: ${Get.find<ThemeController>().isDarkMode ? "Dark" : "Light"}');
```

Your theme system is production-ready! 🚀