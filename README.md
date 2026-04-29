# 🏠 Smart Home App

A Flutter mobile application for managing smart home devices by room, integrated with Firebase Realtime Database for real-time device state synchronization.

---

## 📌 Overview

Smart Home App allows users to control smart devices such as lights and fans in different rooms.  
The app supports real-time updates, activity history, room/device search, dashboard statistics, and Firebase cloud data synchronization.

This project was built as a practical Flutter mobile app to demonstrate mobile UI development, Firebase integration, state management, and Git/GitHub workflow.

---

## 🚀 Features

- 🔘 Turn smart devices on/off
- 🏠 Manage devices by room:
  - Living Room
  - Bedroom
  - Kitchen
- 🔄 Real-time device state synchronization with Firebase Realtime Database
- 📊 Dashboard showing total devices and active devices by room
- 🔍 Search rooms and devices
- 📜 Activity history logging
- ♻️ Reset devices by room or reset all devices
- 🌙 Supports system light/dark mode
- 🔧 Git & GitHub version control
- 📱 Runs on Android devices

---

## 🎥 Demo Video

Watch demo video here: [Smart Home App Demo](https://www.youtube.com/watch?si=QYW2TgJS3N2DyW0B&v=nXXrJ43maxo&feature=youtu.be)

---

## 📱 Screenshots

### Home Dashboard
![Home Dashboard](assets/images/home.jpg)

### Room Device Control
![Room Device Control](assets/images/room.jpg)

### Activity History
![Activity History](assets/images/history.jpg)

### Firebase Realtime Database
![Firebase Realtime Database](assets/images/firebase.jpg)

---

## 🛠 Tech Stack

- Flutter
- Dart
- Firebase Core
- Firebase Realtime Database
- SharedPreferences
- Git
- GitHub

---

## 📂 Project Structure

```text
lib/
├── main.dart
├── models/
│   └── device_model.dart
├── pages/
│   ├── room_detail_page.dart
│   └── activity_history_page.dart
└── services/
    ├── firebase_realtime_service.dart
    └── fake_api_service.dart