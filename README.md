# Zello — Flutter E-Commerce Mobile Application

A full-stack mobile e-commerce application built with **Flutter** and **Firebase**, supporting dual user roles (Customer & Admin) with real-time data sync, push notifications, and a seamless shopping experience.

---

## ✨ Features

### 🛍️ Customer Features
- **Authentication** — Email/password and Google Sign-In via Firebase Auth with persistent sessions
- **Home Dashboard** — Category cards, promotional banner carousel, and new arrivals section
- **Browse & Search** — Real-time search with filter (category, price, rating, stock) and sort options
- **Product Detail** — Swipeable image gallery, variants (size/color), live stock count via Firestore stream
- **Stock Alerts** — "Out of Stock" badge, low stock warning, and "Notify Me" push notification
- **Cart** — Persistent cart stored in Firestore with live badge count and swipe-to-remove
- **Wishlist** — Save products and move to cart in one tap
- **Checkout** — Editable delivery address, payment summary, SSLCommerz payment integration
- **Order Tracking** — Live step indicator (Pending → Confirmed → Shipped → Delivered)
- **Reviews & Ratings** — Verified buyer reviews with star rating, comment, and photo upload
- **User Profile** — Edit name, profile photo, saved addresses, and notification preferences
- **Dark Mode** — System-aware with manual override in settings

### 🔧 Admin Features
- **Dashboard** — Summary stats: total users, products, today's orders, and revenue
- **Category Management** — Create, edit, delete categories with cover images
- **Product Management** — Add/edit products with multi-image upload, variants, price, and stock
- **Quick Edit** — Rapid price and stock updates directly from the product list
- **Order Management** — View all orders, filter by status, update stages, trigger customer notifications
- **User Management** — View all users, disable accounts, or remove users from the system

---

## 🛠️ Tech Stack

| Layer | Technology |
|---|---|
| **Frontend** | Flutter (Dart) — Android & iOS |
| **Authentication** | Firebase Authentication |
| **Database** | Cloud Firestore (NoSQL, real-time) |
| **Storage** | Firebase Storage |
| **State Management** | Riverpod (AsyncNotifier / StateNotifier) |
| **Navigation** | GoRouter with role-based redirect guards |
| **Push Notifications** | Firebase Cloud Messaging (FCM) |
| **Server-side Logic** | Firebase Cloud Functions |
| **Payment** | SSLCommerz |

---

## 🗂️ Project Structure

```
zello/
├── lib/
│   ├── features/
│   │   ├── auth/
│   │   ├── home/
│   │   ├── products/
│   │   ├── cart/
│   │   ├── orders/
│   │   ├── wishlist/
│   │   ├── reviews/
│   │   ├── admin/
│   │   └── profile/
│   ├── shared/
│   │   ├── components/     # Reusable widgets
│   │   ├── models/
│   │   └── services/
│   └── main.dart
├── functions/              # Firebase Cloud Functions
├── android/
├── ios/
└── pubspec.yaml
```

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK `>=3.0.0`
- Dart SDK
- Firebase project set up
- Android Studio or VS Code

### Installation

1. **Clone the repository**
```bash
git clone https://github.com/Ashiq0101/zello-e-commerce-android-app-.git
cd zello-e-commerce-android-app-
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Configure Firebase**
- Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
- Add Android/iOS apps and download `google-services.json` / `GoogleService-Info.plist`
- Place them in `android/app/` and `ios/Runner/` respectively

4. **Set up Firestore Security Rules**
- Deploy the rules from `firestore.rules` in your Firebase console

5. **Run the app**
```bash
flutter run
```

---

## 🔥 Firebase Collections

| Collection | Description |
|---|---|
| `users` | User profiles and roles |
| `products` | Product catalog |
| `categories` | Product categories |
| `orders` | Customer orders |
| `carts` | Per-user cart items |
| `reviews` | Product ratings and reviews |
| `notifications` | Push notification records |

---

## ☁️ Cloud Functions

| Function | Trigger |
|---|---|
| `recalculateRating` | On new review — updates product average rating |
| `sendOrderNotification` | On order status change — notifies customer via FCM |
| `notifyRestock` | On stock update — notifies users who tapped "Notify Me" |
| `deleteUser` | Admin-triggered — removes user via Admin SDK |

---

## 📦 Key Dependencies

```yaml
dependencies:
  flutter_riverpod: ^2.x
  go_router: ^12.x
  firebase_core: ^2.x
  firebase_auth: ^4.x
  cloud_firestore: ^4.x
  firebase_storage: ^11.x
  firebase_messaging: ^14.x
  cached_network_image: ^3.x
  image_picker: ^1.x
```

---

## 👤 Author

**Ashiqul Islam**  
[GitHub](https://github.com/Ashiq0101) · [LinkedIn](#)

---

## 📄 License

This project is for educational and portfolio purposes.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
