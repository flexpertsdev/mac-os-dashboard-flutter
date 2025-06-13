# MacOS Dashboard - Flutter Analytics Dashboard

A comprehensive Flutter-based analytics dashboard application with cross-platform support for iOS, Android, and Web. Features modern Material Design 3, responsive layouts, and advanced data visualization capabilities.

## ✨ Features

- **📊 Advanced Analytics**: Interactive charts and real-time data visualization
- **📱 Cross-Platform**: Native iOS, Android, and Web deployment
- **🎨 Modern UI**: Material Design 3 with light/dark theme support
- **📐 Responsive Design**: Adaptive layouts for mobile, tablet, and desktop
- **⚡ State Management**: Efficient Provider-based architecture
- **🔄 Real-time Updates**: Live dashboard data and metrics
- **🌐 PWA Ready**: Progressive Web App capabilities for web deployment

## 🚀 Quick Start

### Prerequisites

- Flutter SDK 3.0.0 or higher
- Dart SDK (included with Flutter)
- For iOS development: Xcode and iOS Simulator
- For Android development: Android Studio and Android SDK
- For Web development: Chrome browser

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd mac_o_s_dashboard
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the application**
   ```bash
   # Run on default platform
   flutter run
   
   # Or specify platform
   flutter run -d chrome    # Web
   flutter run -d ios       # iOS Simulator
   flutter run -d android   # Android Emulator
   ```

## 🛠️ Development

### Project Structure

```
lib/
├── main.dart                    # Application entry point
├── theme.dart                   # Theme configuration
├── models/                      # Data models
│   ├── app_models.dart         # Core application models
│   └── dashboard_data.dart     # Dashboard data structures
├── pages/                       # Screen components
│   ├── main_layout.dart        # Main app layout
│   ├── dashboard_page.dart     # Dashboard view
│   ├── analytics_page.dart     # Analytics screen
│   ├── reports_page.dart       # Reports interface
│   ├── settings_page.dart      # Settings page
│   └── users_page.dart         # User management
├── services/                    # Business logic
│   ├── dashboard_service.dart  # Dashboard data service
│   ├── navigation_service.dart # Navigation management
│   └── users_service.dart      # User service
├── utils/                       # Utilities
│   └── responsive_helper.dart  # Responsive design helpers
└── widgets/                     # Reusable components
    ├── analytics_grid.dart     # Analytics grid layout
    ├── bottom_navigation.dart  # Bottom navigation bar
    ├── chart_card.dart         # Chart components
    ├── metric_card.dart        # Metric display cards
    ├── sidebar_navigation.dart # Sidebar navigation
    └── top_navigation.dart     # Top navigation bar
```

### Key Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| flutter | SDK | Core Flutter framework |
| provider | 6.1.2 | State management |
| fl_chart | 0.68.0 | Chart and data visualization |
| google_fonts | 6.1.0 | Typography and fonts |
| shared_preferences | 2.3.2 | Local data storage |
| http | latest | Network requests |

### State Management

The app uses the Provider pattern for state management with three main services:

- **NavigationService**: Manages app navigation state and routing
- **DashboardService**: Handles dashboard data, analytics, and metrics
- **UsersService**: Manages user data and preferences

### Responsive Design

The app implements adaptive layouts that respond to different screen sizes:

- **Mobile** (< 768px): Bottom navigation, compact layouts
- **Tablet** (768px - 1024px): Expanded layouts, hybrid navigation
- **Desktop** (> 1024px): Sidebar navigation, full-width layouts

## 📱 Platform-Specific Setup

### Web Deployment

```bash
# Build for web
flutter build web

# Serve locally
flutter run -d chrome
```

The web version includes PWA capabilities with offline support.

### iOS Development

```bash
# Run on iOS simulator
flutter run -d ios

# Build for iOS
flutter build ios
```

Requires Xcode and iOS development setup.

### Android Development

```bash
# Run on Android emulator
flutter run -d android

# Build APK
flutter build apk

# Build App Bundle
flutter build appbundle
```

## 🎨 Theming

The app supports both light and dark themes with automatic system detection:

```dart
// In main.dart
MaterialApp(
  theme: lightTheme,
  darkTheme: darkTheme,
  themeMode: ThemeMode.system, // Follows system preference
)
```

Custom theme configurations are defined in `theme.dart`.

## 📊 Analytics & Charts

The dashboard uses `fl_chart` for data visualization:

- **Line Charts**: Time series data and trends
- **Bar Charts**: Comparative metrics
- **Pie Charts**: Distribution analysis
- **Custom Metrics**: KPI cards and indicators

## 🧪 Testing

```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage
```

## 🚀 Building for Production

### Web
```bash
flutter build web --release
```

### Android
```bash
flutter build apk --release
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

## 📦 Deployment

### Web Hosting
The built web app can be deployed to:
- Firebase Hosting
- Netlify
- Vercel
- GitHub Pages
- Any static hosting service

### Mobile App Stores
- **Google Play Store**: Use the generated `.aab` file
- **Apple App Store**: Build and submit through Xcode

## 🔧 Configuration

### Environment Variables
Create environment-specific configurations in:
- `lib/config/dev_config.dart`
- `lib/config/prod_config.dart`

### API Configuration
Update API endpoints and keys in the respective service files.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🐛 Troubleshooting

### Common Issues

**Flutter not found**
```bash
flutter doctor
```

**Dependencies issues**
```bash
flutter clean
flutter pub get
```

**iOS build issues**
```bash
cd ios && pod install
```

**Web build issues**
```bash
flutter clean
flutter pub get
flutter build web
```

## 📞 Support

For support and questions:
- Create an issue in the repository
- Check existing documentation
- Review Flutter's official documentation

---

Built with ❤️ using Flutter