# BluBubb: Bluetooth Proximity Chat

## Authors
- Alejandro White (PTK406)
- Mack Tully (WUJ591)

## Overview
**BluBubb** is a Bluetooth-based proximity chat app that allows users to send messages and estimate how far apart they are using signal strength — all without the need for Wi-Fi or cellular data. It’s a lightweight solution for short-range communication in areas where connectivity is limited or unavailable.

## Purpose / Problem
Traditional messaging apps rely heavily on internet access, making them unusable in many outdoor or low-signal environments. **BluBubb** solves this by enabling peer-to-peer Bluetooth messaging with real-time distance estimation based on RSSI (Received Signal Strength Indicator). This provides a private, offline way to communicate and locate others within range.

## Target Audience
- Students on campus
- Attendees at large events or festivals
- Hikers, campers, and outdoor adventurers
- Professionals working in warehouses, construction zones, or underground facilities
- Anyone who needs quick, localized communication without internet

## Core Features
- **Bluetooth Messaging**: Connect two nearby devices to send and receive short messages.
- **Distance Estimation**: Display an approximate distance between users based on Bluetooth signal strength (RSSI).
- **Persistent Connection**: Maintain an ongoing Bluetooth connection for real-time chatting and tracking as long as Bluetooth remains active.

## Use Case Example
At a crowded outdoor festival, two friends split up to explore. Both open BluBubb and connect their phones via Bluetooth. They send messages back and forth without using data. Later, when one friend gets lost, they use the app’s distance feature to estimate how far the other is and begin walking in the right direction, watching the distance decrease until they reunite.

## Platform
- Currently Supported: iOS (via Flutter)
- Under Development: Cross-platform support for Android
- Tech Stack: Flutter, Dart, [flutter_blue_plus](https://pub.dev/packages/flutter_blue_plus)
