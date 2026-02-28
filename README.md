# My Pi - Student Assistant App 📚

My Pi is a comprehensive student management application built with Flutter, designed to help students organize their academic life efficiently. The app provides a complete suite of tools for managing courses, assignments, grades, and academic performance tracking.

## 🎯 About the Project

My Pi is an all-in-one student productivity application that simplifies academic management. Whether you're tracking assignments, monitoring grades, or generating transcripts, My Pi provides an intuitive interface with powerful features to keep students organized and on top of their studies.

## ✨ Features

### 🔐 Authentication & User Management
- **Secure Authentication**: Sign in with email/password or Google Sign-In
- **Firebase Integration**: Secure cloud-based authentication and data storage
- **User Profiles**: Personalized user profiles with customizable settings

### 📖 Course Management
- **Course Organization**: Create and manage multiple courses
- **Course Details**: Track course information, credits, and schedules
- **Assessment Tracking**: Monitor all course assessments and evaluations

### 📝 Assignment Management
- **Assignment Tracking**: Create, edit, and track all your assignments
- **Due Date Reminders**: Never miss a deadline with smart notifications
- **Status Monitoring**: Track assignment progress (pending, completed, overdue)
- **Priority Organization**: Organize assignments by priority and due dates

### 📊 Grade Management
- **Grade Tracking**: Record and monitor grades for all assignments and courses
- **GPA Calculator**: Automatic GPA calculation with real-time updates
- **Performance Analytics**: Visual charts and graphs showing academic performance
- **Grade Statistics**: Detailed statistics and insights into your academic progress

### 📄 Transcript Generation
- **PDF Transcripts**: Generate professional academic transcripts
- **Export & Share**: Print or share transcripts easily
- **Comprehensive Reports**: Detailed reports including all courses and grades

### 🔔 Notifications
- **Smart Reminders**: Timely notifications for upcoming assignments and deadlines
- **Local Notifications**: Receive alerts even when offline
- **Customizable Alerts**: Configure notification preferences

### 🎨 User Experience
- **Modern UI**: Clean and intuitive Material Design interface
- **Dark/Light Theme**: Choose your preferred theme
- **Responsive Design**: Works seamlessly on phones and tablets
- **Offline Support**: Continue working even without internet connectivity

### 💾 Data Management
- **Cloud Sync**: Automatic cloud backup with Firebase Firestore
- **Local Database**: SQLite database for offline access
- **Data Security**: Encrypted storage for sensitive information

## 📱 Screenshots

### Authentication
<table>
  <tr>
    <td><img src="screenshots/login.png" width="250" alt="Login Screen"/></td>
    <td><img src="screenshots/register.png" width="250" alt="Register Screen"/></td>
    <td><img src="screenshots/google_signin.png" width="250" alt="Google Sign-In"/></td>
  </tr>
  <tr>
    <td align="center">Login Screen</td>
    <td align="center">Register Screen</td>
    <td align="center">Google Sign-In</td>
  </tr>
</table>

### Home & Dashboard
<table>
  <tr>
    <td><img src="screenshots/home.png" width="250" alt="Home Screen"/></td>
    <td><img src="screenshots/dashboard.png" width="250" alt="Dashboard"/></td>
    <td><img src="screenshots/profile.png" width="250" alt="Profile"/></td>
  </tr>
  <tr>
    <td align="center">Home Screen</td>
    <td align="center">Dashboard</td>
    <td align="center">Profile</td>
  </tr>
</table>

### Course Management
<table>
  <tr>
    <td><img src="screenshots/courses.png" width="250" alt="Courses List"/></td>
    <td><img src="screenshots/course_detail.png" width="250" alt="Course Details"/></td>
    <td><img src="screenshots/add_course.png" width="250" alt="Add Course"/></td>
  </tr>
  <tr>
    <td align="center">Courses List</td>
    <td align="center">Course Details</td>
    <td align="center">Add Course</td>
  </tr>
</table>

### Assignment Tracking
<table>
  <tr>
    <td><img src="screenshots/assignments.png" width="250" alt="Assignments"/></td>
    <td><img src="screenshots/assignment_detail.png" width="250" alt="Assignment Details"/></td>
    <td><img src="screenshots/add_assignment.png" width="250" alt="Add Assignment"/></td>
  </tr>
  <tr>
    <td align="center">Assignments</td>
    <td align="center">Assignment Details</td>
    <td align="center">Add Assignment</td>
  </tr>
</table>

### Grades & Analytics
<table>
  <tr>
    <td><img src="screenshots/grades.png" width="250" alt="Grades"/></td>
    <td><img src="screenshots/analytics.png" width="250" alt="Performance Analytics"/></td>
    <td><img src="screenshots/transcript.png" width="250" alt="Transcript"/></td>
  </tr>
  <tr>
    <td align="center">Grades</td>
    <td align="center">Performance Analytics</td>
    <td align="center">Transcript</td>
  </tr>
</table>

## 📥 Installation

### Download from GitHub Releases

1. **Visit the Releases Page**
   - Go to the [Releases](https://github.com/asifmanowar9/my_pi/releases) page of this repository
   - Find the latest release version

2. **Download the App**
   
   **For Android:**
   - Download the `my_pi-v1.0.0-android.apk` file from the latest release
   - Transfer the APK file to your Android device if downloaded on a computer

3. **Install on Your Device**

   - Open the downloaded APK file on your Android device
   - If prompted, enable "Install from Unknown Sources" in your device settings
   - Follow the on-screen instructions to complete the installation
   - Once installed, you'll find My Pi in your app drawer

4. **Launch the App**
   - Open My Pi from your device
   - Sign up for a new account or sign in with your existing credentials
   - Start organizing your academic life!

## 🛠️ Development Setup

If you want to build the app from source or contribute to development:

### Prerequisites
- Flutter SDK (>=3.8.1)
- Dart SDK (>=3.8.1)
- Android Studio (for Android development)
- Firebase account (for cloud features)

### Setup Instructions

1. **Clone the Repository**
   ```bash
   git clone https://github.com/YOUR_USERNAME/my_pi.git
   cd my_pi
   ```

2. **Install Dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**
   - Create a new Firebase project at [Firebase Console](https://console.firebase.google.com/)
   - Add your Android app to the Firebase project
   - Download and place the configuration file:
     - Android: `google-services.json` in `android/app/`
   - Run the FlutterFire configuration:
     ```bash
     flutterfire configure
     ```
   
   **⚠️ SECURITY WARNING:**
   - **NEVER commit `google-services.json` to version control!**
   - This file is already in `.gitignore` to prevent accidental commits
   - If you accidentally commit it, remove it from Git history immediately and regenerate your Firebase API keys

4. **Run the App**
   ```bash
   flutter run
   ```

5. **Build for Production**
   
   ```bash
   flutter build apk --release
   # or for app bundle
   flutter build appbundle --release
   ```

## 🧪 Testing

Run the test suite:
```bash
flutter test
```

## 📦 Dependencies

Key packages used in this project:
- **get**: State management and navigation
- **firebase_core** & **firebase_auth**: Authentication
- **cloud_firestore**: Cloud database
- **sqflite**: Local database
- **flutter_local_notifications**: Local notifications
- **pdf** & **printing**: PDF generation and printing
- **fl_chart**: Charts and analytics
- **google_sign_in**: Google authentication
- **get_storage**: Local storage

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📧 Contact

For questions, suggestions, or issues, please open an issue on GitHub or contact the development team.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Firebase for cloud services
- All open-source contributors whose packages made this project possible

---

Made with ❤️ by the My Pi Team
