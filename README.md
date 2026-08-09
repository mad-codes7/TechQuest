# 🪑 FrameKart - AR & 3D Interactive Furniture App

**FrameKart** is a cutting-edge cross-platform Flutter application designed to revolutionize online furniture shopping. By leveraging Augmented Reality (AR) previewing, dynamic 3D room scanning, real-time Supabase cloud database integration, and a comprehensive dual-interface (User & Admin Portal), FrameKart delivers an immersive spatial commerce experience.

---

## ✨ Key Features

### 🛍️ User Experience
- **Interactive Home & Product Catalog**: Browse furniture curated by categories (Chairs, Desks, Doors, Gates, Lamps, Shelves, Sofas, Tables, Windows).
- **👓 AR Spatial View**: Place and view 3D furniture models directly inside your living environment before purchasing.
- **📷 3D Room Reconstruction & Scanning**: Capture room dimensions and reconstruct 3D environments for precise spatial planning.
- **🛒 Shopping Cart & Favorites**: Save desired furniture items, manage cart items, calculate live order subtotals, and place orders seamlessly.
- **👤 User Authentication & Profile Management**: Secure Sign Up, Login, and Phone OTP verification backed by Supabase Auth and location auto-detection.

### 🛡️ Admin Dashboard
- **📊 Real-time Analytics**: Overview of platform sales, order metrics, and user management.
- **🏷️ Dynamic Price Management**: Edit furniture base pricing, apply category-wide discounts, and manage promotional offers live.
- **📦 Order Fulfillment Tracker**: Process incoming user orders, update dispatch statuses, and monitor delivery logistics.
- **🔐 Admin Auth & Security**: Separate secure role-based login and OTP verification for administrative staff.

---

## 🛠️ Tech Stack & Architecture

- **Frontend Framework**: Flutter (Dart) - Material 3 Design
- **State & Service Layer**: Reactive Service Pattern (Auth, Cart, Favorites, Orders, Price Controls, Spatial Reconstruction)
- **Backend & Database**: Supabase (PostgreSQL, Realtime SQL Subscriptions, Supabase Auth)
- **3D & AR Engine**: Flutter AR & Model Viewer (`.glb` 3D rendering pipeline)
- **Device Services**: Location Detection & Camera 3D Mesh Reconstruction

---

## 📁 Project Structure

```
lib/
├── config/             # App secrets and API keys
├── models/             # Data models (FurnitureItem, ReconstructionJob)
├── screens/            # Application Screens
│   ├── admin_*.dart    # Admin Dashboard, Orders, Price & OTP screens
│   ├── app_shell.dart  # Main Navigation Shell
│   ├── ar_view_screen.dart # 3D AR Furniture Viewer
│   ├── home_screen.dart    # Main Product Showcase
│   ├── scan_3d_screen.dart # 3D Room Scanning
│   └── ...             # Auth, Cart, Favorites, Profile screens
└── services/           # Business logic & API communication
    ├── auth_service.dart
    ├── cart_service.dart
    ├── favorites_service.dart
    ├── order_service.dart
    ├── admin_price_service.dart
    └── reconstruction_service.dart
```

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (v3.19.0 or higher recommended)
- Dart SDK
- Android Studio / Xcode for emulators or physical device deployment

### Installation & Run

1. **Clone the Repository**:
   ```bash
   git clone https://github.com/mad-codes7/TechQuest.git
   cd TechQuest
   ```

2. **Install Dependencies**:
   ```bash
   flutter pub get
   ```

3. **Database Setup**:
   - Execute the SQL schema located at `supabase_orders_table.sql` inside your Supabase SQL Editor to initialize orders and product tables.

4. **Run the Application**:
   ```bash
   flutter run
   ```

---

## 📄 License & Credits
Built for **TechQuest** hackathon / project submission. All rights reserved.
