# BluBubb: Bluetooth Proximity Chat

## Authors
- Alejandro White (PTK406)
- Mack Tully (WUJ591)

---

## Overview

**BluBubb** is a Bluetooth-based proximity chat app that allows users to send messages to nearby peers — all without the need for Wi-Fi or cellular data. It’s a lightweight solution for short-range communication in areas where connectivity is limited or unavailable.

---

## Purpose / Problem

Traditional messaging apps rely heavily on internet access, making them unusable in many outdoor or low-signal environments. **BluBubb** solves this by enabling peer-to-peer Bluetooth messaging between nearby devices. This provides a private, offline way to communicate in real time.

---

## Target Audience

- Students on campus
- Attendees at large events or festivals
- Hikers, campers, and outdoor adventurers
- Professionals working in warehouses, construction zones, or underground facilities
- Anyone who needs quick, localized communication without internet

---

## Core Features

- **Bluetooth Messaging:** Connect two nearby devices to send and receive short messages.
- **Persistent Connection:** Maintain an ongoing Bluetooth connection for real-time chatting as long as Bluetooth remains active.
- **Device Discoverability:** Devices advertise and browse for nearby peers to establish communication.
- **Username Customization:** Users can input their preferred username, which is displayed during the connection process.
- **Local Chat History:** Conversations are saved locally using the Hive database and organized by username, allowing users to view past messages even after disconnection.

---

## Use Case Example

Two campers at a remote group campsite have no internet or cellular service. They’re in separate tents and need to communicate without leaving their shelters. With BluBubb, they connect their iPhones via Bluetooth and exchange messages instantly, staying in touch even without network coverage.

---

## Platform

- Currently Supported: iOS (via Flutter)
- Under Development: Cross-platform support for Android
- Tech Stack: Flutter, Dart, [flutter_nearby_connections](https://pub.dev/packages/flutter_nearby_connections)

---

## Current Development

- **iOS Bluetooth communication:** Fully functional for iOS, with device discovery and real-time messaging.
- **Username selection:** Each device can set and display a custom username.
- **Chat persistence:** Chats are saved locally on the device using Hive and tied to usernames for later retrieval.
- **Functional testing:** Confirmed working between iPhone 11 and iPhone 15 devices.

---

## Running the Application

### Preequisites
- macOS with Xcode installed
- Flutter SDK installed (Flutter installation guide)
- Physical iOS device with Bluetooth enabled
- Apple ID (free developer account sufficient for personal testing)

### Setup Instructions
1. Clone the Repository
   ```
   git clone https://github.com/yourusername/blububb.git
   cd blububb
   ```
2. Install Dependencies
   ```
   flutter pub get
   ```
3. Open in Xcode
   - Navigate to ios/ directory and open Runner.xcworkspace with Xcode.
   - In Xcode, set your development team under `Signing & Capabilities`.
   - Connect your iOS device via USB and select it as the build target.
4. Run in Release Mode (Optional, but Recommended)
   ```
   flutter build ios --release
   ```
   Then run the app on your device using Xcode (Product > Run).<br>
   
**Note:** You may need to trust the developer profile in your device settings (Settings > General > VPN & Device Management) if using a free Apple developer account.
   
---

## File Structure Overview

Here’s a high-level look at the core files and their responsibilities:
```
lib/
├── main.dart                        # App entry point and route configuration
├── messages/
│   ├── chat_message.dart            # Message model (content, timestamp, sender)
│   ├── chat_message.g.dart          # Generated code for Hive type adapter
│   └── chat_storage.dart            # Handles saving and loading messages using Hive
├── screens/
│   ├── chat_screen.dart             # Handles live messaging between connected devices
│   ├── chat_history_screen.dart     # Displays list of past conversations of selected user
│   ├── device_scan_screen.dart      # Finds nearby devices and handles Bluetooth connections
│   ├── home_screen.dart             # Username input and home navigation
│   └── user_history_screen.dart     # Displays users with a past chat history
```

### Other Notable Files and Directories
- **ios/:** Contains iOS-specific configuration files for building and deploying via Xcode.
- **assets/:** Static files (e.g., icons or images) if used.
- **pubspec.yaml:** Contains the needed dependencies for the project
