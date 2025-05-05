

```markdown
# 🔹 ChatApp1 - One-to-One Chat Application (Flutter + Firebase)

A feature-rich one-to-one chat application built using **Flutter** and **Firebase**, supporting real-time text and image messaging with typing indicators, user presence status, and a sleek modern UI.

---

## 📱 Objective

To build a **One-to-One Chat Application** that supports:

- Text and image messaging
- User authentication via  Email/Password
- Real-time user presence and typing indicators
- A clean and scalable MVVM architecture using state management

---

## 🚀 Features

### 🧱 Architecture

- Follows **MVVM architecture**
- Utilizes **Riverpod**  for state management
- Utilizes **Streams**  for chats and auth management
- Modular and clean folder structure

### 🔐 Authentication

- **Google Sign-In** or **Email & Password**
- Stores user profile info (name, photo) in **Firestore**

### 💬 Chat System

- **One-to-One chat** with users
- Recent chat list with:
  - Profile picture
  - Last message
  - Timestamp
- Real-time sync using **Firestore Streams**

### 📤 Messages

- Supports:
  - **Text messages**
  - **Image messages** from camera/gallery
- Stores:
  - Text → **Firestore**
  - Images → **Firebase Storage**

### 👀 Typing & Presence

- Shows "Typing..." when the user is typing
- Displays:
  - **"Online"**
  - **"Last seen"** timestamp using Firestore presence logic

### 🎨 UI & UX

- Chat bubbles styled based on sender/receiver
- Auto-scroll to latest message
- Basic emoji support
- Responsive design

### 💡 Bonus (Optional)

- Delete message (via long press)
- Push notifications for new messages (via Firebase Cloud Messaging)

---

## 📁 Folder Structure (MVVM + Riverpod)

```

lib/
├── core/
├── models/
├── view\_models/
├── views/
├── services/
├── utils/
└── main.dart

````

---

## 📸 Screenshots

| Login Screen | Chat List | One-to-One Chat |
|--------------|-----------|-----------------|
| ![Login Screen](screenshots/login.png) | ![Chat List](screenshots/chatlist.png) | ![Chat](screenshots/chat.png) |

> 📌 _Replace image paths with your actual screenshots._

---

## 🔗 APK Download

[Download APK Here](#)  
> 📌 https://drive.google.com/file/d/10PBqSsE2Qsr7oCfvE9DWy9buWMN-ain0/view?usp=drive_link

---

## 📽 Demo

> Coming soon! 

---

## 🛠️ Getting Started

### 🔧 Prerequisites

- Flutter (3.x recommended)
- Firebase account
- Android/iOS setup

### ⚙️ Setup Instructions

1. **Clone the repository**  
   ```bash
   git clone https://github.com/HMKazmi/ChatApp1.git
   cd ChatApp1
````

2. **Install dependencies**

   ```bash
   flutter pub get
   ```

3. **Configure Firebase**

   * Add `google-services.json` (Android) & `GoogleService-Info.plist` (iOS) in appropriate folders
   * Enable **Authentication**, **Firestore**, **Storage** in Firebase console

4. **Run the app**

   ```bash
   flutter run
   ```

---

## 📦 Dependencies

* `flutter_riverpod` / `provider`
* `firebase_auth`
* `cloud_firestore`
* `firebase_storage`
* `image_picker`
* `emoji_picker_flutter`
* `firebase_messaging` *(optional)*

---

## 🙌 Contributions

Pull requests are welcome! If you have suggestions or features to add, feel free to open an issue.

---

## 📄 License

[MIT](LICENSE)

---

## 💬 Contact

For queries or support, feel free to reach out via [GitHub Issues](https://github.com/HMKazmi/ChatApp1/issues).

```

---
