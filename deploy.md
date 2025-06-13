# Deployment Instructions for Flutter Web App

## Quick Netlify Deployment

Since the Flutter CLI isn't available locally, you can deploy this Flutter web app to Netlify in two ways:

### Option 1: Netlify Web Interface (Recommended)

1. **Go to Netlify Dashboard**: https://app.netlify.com/
2. **Click "New site from Git"**
3. **Connect to GitHub**: Choose the repository `flexpertsdev/mac-os-dashboard-flutter`
4. **Configure Build Settings**:
   - **Build command**: `flutter build web --release`
   - **Publish directory**: `build/web`
   - **Environment variables** (if needed):
     - `FLUTTER_VERSION`: `3.16.0`
     - `FLUTTER_WEB`: `true`

5. **Deploy**: Click "Deploy site"

Netlify will automatically install Flutter and build your web app!

### Option 2: Manual Build & Deploy

If you have Flutter installed locally:

```bash
# Build the web app
flutter build web --release

# The built files will be in build/web/
# You can then drag and drop the build/web folder to Netlify's manual deploy
```

### Build Configuration

The `netlify.toml` file is already configured with:

```toml
[build]
  publish = "build/web"
  command = "flutter build web --release"

[build.environment]
  FLUTTER_VERSION = "3.16.0"

[[redirects]]
  from = "/*"
  to = "/index.html"
  status = 200
```

This ensures proper Single Page Application (SPA) routing for Flutter web.

## Expected Build Process

1. **Netlify detects**: Flutter project with `pubspec.yaml`
2. **Installs Flutter**: Based on FLUTTER_VERSION environment variable
3. **Runs**: `flutter pub get` to install dependencies
4. **Builds**: `flutter build web --release` to create production build
5. **Publishes**: Contents of `build/web` directory
6. **Configures**: SPA redirects for proper routing

## Post-Deployment

Once deployed, you'll get a URL like: `https://mac-os-dashboard-flutter.netlify.app`

The Flutter web app will be fully functional with:
- ✅ Analytics dashboard with interactive charts
- ✅ Responsive design (mobile + desktop)
- ✅ Material Design UI components
- ✅ Cross-platform navigation
- ✅ PWA capabilities
- ✅ Proper SPA routing

## Repository Information

- **GitHub**: https://github.com/flexpertsdev/mac-os-dashboard-flutter
- **Branch**: main
- **Framework**: Flutter 3.0+ with Dart
- **UI Library**: Material Design with Google Fonts
- **Charts**: fl_chart for data visualization
- **State Management**: Provider pattern

## Troubleshooting

If the build fails:
1. Check Flutter version compatibility
2. Ensure all dependencies are compatible with web platform
3. Review build logs for specific errors
4. Some Flutter packages may not support web - check pubspec.yaml

The app is designed to work across all platforms (iOS, Android, Web) with this deployment focusing on the web version.