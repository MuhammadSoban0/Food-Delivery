# 🍔 Food Delivery App

A modern Flutter food delivery application with features like product browsing, cart management, payment processing, and delivery tracking.

## ✨ Features

- **Product Catalog**: Browse food items with search functionality
- **Smart Search**: TypeAhead search with real-time suggestions
- **Shopping Cart**: Add/remove items with quantity management  
- **Payment Processing**: Secure payments via Stripe integration
- **Delivery Tracking**: Real-time order status updates
- **User Authentication**: Google Sign-In integration
- **Push Notifications**: Order updates and promotional messages
- **Modern UI**: Clean, responsive design with smooth animations

## 📱 Screenshots

[Add screenshots of your app here]

## 🛠️ Setup Instructions

### Prerequisites
- Flutter SDK (3.0 or higher)
- Android Studio / VS Code
- Firebase account
- Stripe account

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/food-delivery-app.git
   cd food-delivery-app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Environment Variables**
   ```bash
   cp .env.example .env
   ```
   Edit `.env` and add your configuration:
   ```env
   # Firebase Configuration
   FIREBASE_API_KEY=your_firebase_api_key
   FIREBASE_APP_ID=your_firebase_app_id
   FIREBASE_MESSAGING_SENDER_ID=your_messaging_sender_id
   FIREBASE_PROJECT_ID=your_project_id
   FIREBASE_STORAGE_BUCKET=your_storage_bucket

   # Stripe Configuration
   STRIPE_PUBLISHABLE_KEY=pk_test_your_publishable_key
   STRIPE_SECRET_KEY=sk_test_your_secret_key
   ```

4. **Configure Firebase**
   - Create a new Firebase project
   - Download `google-services.json` and place it in `android/app/`
   - Enable Authentication and Firestore in Firebase Console

5. **Configure Stripe**
   - Create a Stripe account
   - Get your API keys from Stripe Dashboard
   - Add keys to your `.env` file

6. **Run the app**
   ```bash
   flutter run
   ```

## 🏗️ Project Structure

```
lib/
├── core/                 # Core app functionality
│   ├── app_state.dart   # Global state management
│   ├── app_theme.dart   # App theming
│   └── utils/           # Utility functions
├── models/              # Data models
├── services/            # External services (Stripe, etc.)
├── ui/                  # User interface
│   ├── home/           # Home screen & product browsing
│   ├── cart/           # Shopping cart & checkout
│   ├── delivery/       # Delivery tracking
│   ├── profile/        # User profile & settings
│   └── auth/           # Authentication screens
└── data/               # Data sources & dummy data
```

## 🔧 Technologies Used

- **Flutter & Dart**: Cross-platform mobile development
- **Firebase**: Authentication, Database, Analytics
- **Stripe**: Payment processing
- **Provider**: State management
- **Google Sign-In**: User authentication
- **Flutter Animate**: Smooth animations
- **TypeAhead**: Smart search functionality

## 🚀 Deployment

### Android
1. Build release APK:
   ```bash
   flutter build apk --release
   ```

2. Build App Bundle for Play Store:
   ```bash
   flutter build appbundle --release
   ```

### iOS
1. Build iOS release:
   ```bash
   flutter build ios --release
   ```

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## ⚠️ Security Notes

- Never commit real API keys or credentials
- Use environment variables for sensitive configuration
- Keep `google-services.json` out of version control for production apps
- Use Stripe test keys during development

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Firebase for backend services
- Stripe for payment processing
- All contributors and testers

---

**Note**: This is a demo application. For production use, ensure proper security audits, testing, and compliance with relevant regulations.