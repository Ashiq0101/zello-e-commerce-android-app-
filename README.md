Project Title: Zello A Flutter-Based E-Commerce Mobile Application
Project Features:
Zello is a full-stack mobile e-commerce application built with Flutter and powered by the
Firebase platform. It supports two distinct user roles Customer and Admin each with a dedicated
dashboard and feature set. The following features have been implemented in this project:
A. User / Customer Features
a) User Registration & Login: Users can create an account with email and password
or sign in with Google. Firebase Authentication manages sessions so users remain
logged in across app restarts.
b) Home Dashboard with Categories: After login, users see a home screen displaying
product categories created by the admin (e.g., Electronics, Clothing, Grocery) as
scrollable cards, along with a promotional banner carousel and new arrivals section.
c) Browse & Search Products: Users can browse the full product catalog displayed as
a grid or list, and search products by name. Results update in real time as the user
types.
d) Filter & Sort: A filter bottom sheet allows users to narrow results by category, price
range, minimum star rating, and in-stock availability. Sort options include price
(low/high), newest, and top-rated.
e) Product Detail Page: Tapping a product opens a full detail view with a swipeable
image gallery, name, price, description, available variants (size/color), stock status,
and average rating. Stock count is a live Firestore stream, updating without manual
refresh.
f) Stock Status & Out-of-Stock Handling: Products with zero stock display a
prominent “Out of Stock” badge and the Add to Cart button is disabled. When stock
is between 1 and 5, an amber “Only N left!” warning is shown. Users can tap “Notify
Me” to receive a push notification when the product is restocked.
g) Cart Management: Users can add products to cart with selected variant and
quantity. The cart is stored in Firestore and persists across devices. The app bar shows
a live badge count. Items can be removed with a swipe gesture.
h) Wishlist: A heart icon on product cards and detail pages allows users to save
products to a wishlist stored in Firestore. Saved items can be moved to cart in a single
tap.
i) Checkout: The checkout screen displays the delivery address (editable), selected
payment method, item summary, and order total including shipping. Payment is
2
processed via SSLCommerz (to be integrated). An order document is created in
Firestore only upon confirmed payment success.
j) Order Tracking: Users can view all their past and active orders. A visual step
indicator shows the current status (Pending → Confirmed → Shipped → Delivered)
and updates live via a Firestore stream listener whenever the admin changes the
status.
k) Product Ratings & Reviews: After an order is delivered, users are prompted to leave
a 1–5 star rating with an optional text comment and photo. Only verified buyers can
submit reviews, preventing fake feedback. Average ratings are recalculated
automatically via a Firebase Cloud Function.
l) User Profile: Users can view and edit their name, upload a profile photo (stored in
Firebase Storage), manage saved delivery addresses, and configure notification
preferences.
m) Dark Mode: The app supports a system-aware dark mode using Flutter’s
ThemeData. It automatically follows the device’s light or dark system preference,
with a manual override option available in the profile settings screen.
B. Admin Features
n) Admin Dashboard: After login with an admin account, the admin is routed to a
dedicated panel showing summary statistics: total registered users, total products,
orders placed today, and revenue today.
o) Category Management: Admins can create, edit, and delete product categories.
Each category has a name and a cover image uploaded to Firebase Storage.
Categories appear immediately on the user’s home screen upon creation.
p) Add & Edit Products: Admins can add new products by entering name, description,
price, stock quantity, category (selected from a Firestore dropdown), product images
(multi-upload to Firebase Storage), and optional variants such as size or color.
Existing products can be fully edited at any time.
q) Update Price & Stock: A quick-edit button on each product card in the admin list
allows rapid price and stock updates without opening the full product edit form. Outof-stock products are flagged with a red badge for easy identification.
r) Order Management & Status Updates: Admins can view all orders, filter by status,
and update each order through the stages: Pending → Confirmed → Shipped →
Delivered or Cancelled. Status changes trigger a Firebase Cloud Function that sends a
push notification to the customer.
s) User List & Management: The admin panel includes a User List showing all
registered customers with name, email, join date, and order count. Admins can
disable an account (blocking login) or fully remove a user from the system.
C. Technical Implementation
t) Flutter UI: A single Dart codebase runs natively on both Android and iOS.
Navigation is handled by GoRouter with role-based redirect guards. Reusable widgets
(product card, status badge, shimmer loader) are organized in a shared components
folder.
u) Firebase Authentication: Handles all identity management including
email/password login, Google Sign-In, password reset, and persistent sessions. A role
field in each user’s Firestore document determines whether they are routed to the user
dashboard or admin panel.
v) Cloud Firestore Database: A NoSQL real-time database used to store all application
data. Key collections include: users, products, categories, orders, carts, reviews,
coupons, and notifications. Security rules restrict read/write access based on user role.
3
w) Firebase Storage: Used to store all binary files including product images, category
images, promotional banners, user profile photos, and review photos. Download
URLs are saved in corresponding Firestore documents.
x) State Management (Riverpod): Riverpod is used for global state management
across the app. Each feature (auth, cart, products, filters) has its own AsyncNotifier or
StateNotifier, ensuring compile-time safety and clean separation of concerns.
y) Firebase Cloud Functions & FCM: Server-side Cloud Functions handle automated
tasks such as recalculating product ratings after a review, sending push notifications
via Firebase Cloud Messaging (FCM) on order status changes and restock events, and
user deletion using the Admin SDK

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
