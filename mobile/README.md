# 📱 CogniCart Mobile — Flutter Android Application

CogniCart Mobile is the official cross-platform client for the CogniCart smart price-comparison platform. Built with Flutter & Dart, it brings the complete dark glassmorphic shopping experience, real-time price monitoring, and multi-store deal intelligence directly to Android devices.

---

## 🌟 Key Features

- **🎨 4 Dynamic Background Themes:**
  - Cycles across `Solar Flare`, `Cyber Amber`, `Neon Matrix`, and `Deep Oceanic`.
  - Automatically randomizes theme on launch matching the web app.
  - Interactive theme switcher in the top navigation bar (palette icon 🎨).
  - All UI elements (primary buttons, active tab icons, card borders, badge gradients, floating AI button) dynamically shift their color palette to match the active background theme.
- **🖼️ Official Custom App Icon:**
  - Customized launcher icons across all mipmap density buckets derived from `logo.png`.
- **⚡ Instant Optimistic UI Deletions:**
  - Removing items from **Cart**, **Watchlist**, or **Price Radar** updates the UI immediately without waiting for server response.
- **🔍 Multi-Store Price Comparison:**
  - Query Amazon, Flipkart, Google Shopping simultaneously.
- **🤖 Floating AI Shopping Advisor:**
  - Access Groq-powered CogniBot directly from any screen.
- **📦 Cart & Order Tracking:**
  - Manage cart items, perform simulated 1-click checkout, and review past orders.

---

## 🚀 Development & Build

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (v3.24+ recommended)
- [Android SDK](https://developer.android.com/studio) with NDK 28+

### Setup
```bash
flutter pub get
```

### Run Locally
```bash
flutter run
```

### Build Production Release APK
```bash
flutter build apk --release
```
The output file is generated at:
```
build/app/outputs/flutter-apk/app-release.apk
```
